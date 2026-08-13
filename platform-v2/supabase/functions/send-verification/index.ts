/**
 * Equity24.io — send a verification request to one person.
 *
 * Called by a signed-in applicant from the verification screen. Mints a token,
 * writes the invite under the service role, and emails the person a link.
 *
 * The token is returned to nobody. It exists in exactly two places: the email,
 * and — as a SHA-256 — the invite row. Re-sending overwrites the row, so the
 * previous link stops working the moment a new one is issued.
 *
 * Without RESEND_API_KEY the function still does everything except deliver:
 * the invite is real, the link is real, and the link is written to the log so
 * the flow can be walked end to end before email is switched on.
 *
 * Environment
 *   RESEND_API_KEY   optional — absent means log-only
 *   VERIFY_FROM      default 'Equity24 <kyc@equity24.io>'
 *   SITE_URL         default 'https://equity24.io'
 */
import { createClient } from 'jsr:@supabase/supabase-js@2';

const SITE = Deno.env.get('SITE_URL') ?? 'https://equity24.io';
const FROM = Deno.env.get('VERIFY_FROM') ?? 'Equity24 <kyc@equity24.io>';
const RESEND = Deno.env.get('RESEND_API_KEY');

const CORS = {
  'Access-Control-Allow-Origin': SITE,
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...CORS, 'Content-Type': 'application/json' } });

/** 256 bits, URL-safe. Long enough that the link is the credential. */
function mintToken(): string {
  const b = crypto.getRandomValues(new Uint8Array(32));
  return btoa(String.fromCharCode(...b)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

async function sha256Hex(s: string): Promise<string> {
  const d = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(s));
  return [...new Uint8Array(d)].map(x => x.toString(16).padStart(2, '0')).join('');
}

const ROLE_WORDS: Record<string, string> = {
  board: 'a member of the board',
  shareholder: 'a shareholder',
  ubo: 'a beneficial owner'
};

/** "a member of the board and a beneficial owner (50%)" */
function describeRoles(roles: string[], pct: number | null): string {
  const words = roles.map(r => ROLE_WORDS[r]).filter(Boolean);
  let s = words.length === 0 ? 'connected to the company'
        : words.length === 1 ? words[0]
        : words.slice(0, -1).join(', ') + ' and ' + words[words.length - 1];
  if (pct != null && roles.includes('shareholder')) s += ` (${pct}%)`;
  return s;
}

function emailBody(o: {
  name: string; company: string; roles: string[]; pct: number | null;
  link: string; needsRecord: boolean; isEntity: boolean;
}) {
  const what = o.isEntity
    ? 'a company verification (KYB), covering the company’s own directors and owners'
    : 'an identity check — you will need your passport or national ID card';
  const record = o.needsRecord
    ? '<li>a criminal-record extract, no older than three months, from the country where you live and the country of your citizenship</li>'
    : '';

  const text = [
    `${o.company} has listed you as ${describeRoles(o.roles, o.pct)}.`,
    '',
    'Equity24.io is applying for a crowdfunding-service-provider licence in Estonia.',
    'A licence application has to identify the people behind the company, so we need to',
    'verify you before that application can go forward.',
    '',
    'Start here:',
    o.link,
    '',
    `You will complete ${o.isEntity ? 'a company verification (KYB)' : 'an identity check (passport or ID card)'}.`,
    o.needsRecord ? 'You will also be asked for a criminal-record extract, no older than three months.' : '',
    '',
    'It takes about five minutes. The link is personal to you and expires in 30 days.',
    '',
    'Your documents go to Equity24.io and are not shared with the company that listed you.',
    `If you think this is a mistake, reply to this message and we will remove you.`,
    '',
    'AureviaFund OÜ — equity24.io'
  ].filter(Boolean).join('\n');

  const html = `<div style="font-family:-apple-system,Segoe UI,Helvetica,Arial,sans-serif;font-size:15px;line-height:1.55;color:#14181f;max-width:560px">
  <p style="margin:0 0 16px"><b>${esc(o.company)}</b> has listed you as ${esc(describeRoles(o.roles, o.pct))}.</p>
  <p style="margin:0 0 16px">Equity24.io is applying for a crowdfunding-service-provider licence in Estonia. A licence application has to identify the people behind the company, so we need to verify you before that application can go forward.</p>
  <p style="margin:0 0 8px">You will complete:</p>
  <ul style="margin:0 0 20px;padding-left:20px">
    <li>${what}</li>
    ${record}
  </ul>
  <p style="margin:0 0 24px">
    <a href="${esc(o.link)}" style="display:inline-block;background:#14181f;color:#fff;text-decoration:none;padding:12px 22px;border-radius:8px;font-weight:600">Start verification</a>
  </p>
  <p style="margin:0 0 16px;color:#5b6472;font-size:13px">Takes about five minutes. This link is personal to you and expires in 30 days.</p>
  <p style="margin:0 0 16px;color:#5b6472;font-size:13px">Your documents go to Equity24.io and are <b>not</b> shared with the company that listed you. If you think this is a mistake, reply to this message and we will remove you.</p>
  <p style="margin:0;color:#5b6472;font-size:13px">AureviaFund OÜ — equity24.io</p>
</div>`;
  return { text, html };
}

const esc = (s: string) => String(s).replace(/[&<>"]/g, c =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c] as string));

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return json({ error: 'POST only' }, 405);

  const authHeader = req.headers.get('Authorization') ?? '';
  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false } }
  );

  // Who is asking. The applicant's own JWT decides whose invite this is —
  // owner_profile is never taken from the request body.
  const { data: userData, error: authError } =
    await admin.auth.getUser(authHeader.replace(/^Bearer\s+/i, ''));
  if (authError || !userData?.user) return json({ error: 'Please sign in again.' }, 401);
  const owner = userData.user.id;

  let body: any;
  try { body = await req.json(); } catch { return json({ error: 'Bad request' }, 400); }

  const name = String(body.name ?? '').trim();
  const email = String(body.email ?? '').trim().toLowerCase();
  const companyName = String(body.companyName ?? '').trim();
  const roles: string[] = Array.isArray(body.roles) ? body.roles.filter((r: unknown) => typeof r === 'string') : [];
  const pct = body.equityPct == null ? null : Number(body.equityPct);
  const isEntity = !!body.isEntity;
  const needsRecord = body.needsCriminalRecord !== false;

  if (!name) return json({ error: 'This person needs a name before they can be verified.' }, 400);
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    return json({ error: 'That does not look like an email address.' }, 400);
  }
  if (!companyName) return json({ error: 'The company name is missing.' }, 400);

  const token = mintToken();
  const tokenHash = await sha256Hex(token);
  const personKey = email;

  // Upsert on (owner_profile, person_key): a resend replaces the token, which
  // is what invalidates the link that went out before.
  const { data: invite, error: dbError } = await admin
    .from('verification_invites')
    .upsert({
      owner_profile: owner,
      company_name: companyName,
      person_key: personKey,
      declared_name: name,
      declared_email: email,
      roles,
      equity_pct: Number.isFinite(pct as number) ? pct : null,
      is_entity: isEntity,
      needs_criminal_record: needsRecord,
      token_hash: tokenHash,
      status: 'sent',
      sent_at: new Date().toISOString(),
      expires_at: new Date(Date.now() + 30 * 864e5).toISOString(),
      opened_at: null, id_verified_at: null, records_received_at: null, completed_at: null,
      verified_name: null, name_match: null, review_required: false, email_error: null
    }, { onConflict: 'owner_profile,person_key' })
    .select('id')
    .single();

  if (dbError) {
    console.error('invite upsert failed', dbError);
    return json({ error: 'Could not create the verification just now.' }, 500);
  }

  const link = `${SITE}/verify/?t=${token}`;
  const mail = emailBody({ name, company: companyName, roles, pct: pct ?? null, link, needsRecord, isEntity });

  if (!RESEND) {
    // Log mode. Everything above is real; only delivery is missing, so the
    // whole flow can be walked by pasting this line into a browser.
    console.log(`[send-verification] NO RESEND_API_KEY — would email ${email}\n${link}`);
    await admin.from('verification_invites')
      .update({ email_error: 'not sent: email provider not configured' })
      .eq('id', invite.id);
    return json({ ok: true, delivered: false, reason: 'email-not-configured' });
  }

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: { Authorization: `Bearer ${RESEND}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      from: FROM,
      to: [email],
      reply_to: 'kyc@equity24.io',
      subject: `${companyName} has listed you — please verify your identity`,
      text: mail.text,
      html: mail.html
    })
  });

  const out = await res.json().catch(() => ({}));
  if (!res.ok) {
    console.error('resend failed', res.status, out);
    await admin.from('verification_invites')
      .update({ email_error: `resend ${res.status}: ${out?.message ?? 'unknown'}` })
      .eq('id', invite.id);
    // The invite exists and the link works; only delivery failed. Say so
    // plainly rather than reporting a send that did not happen.
    return json({ error: 'The verification was created but the email could not be sent. Try Resend again in a moment.' }, 502);
  }

  await admin.from('verification_invites')
    .update({ email_provider_id: out?.id ?? null, email_error: null })
    .eq('id', invite.id);

  return json({ ok: true, delivered: true });
});
