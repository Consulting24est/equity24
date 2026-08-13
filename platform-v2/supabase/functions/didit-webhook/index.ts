/**
 * Equity24.io — identity-check results from Didit.
 *
 * This is where the loop closes. The link proved which slot on the application
 * the person was filling; the document proves who they actually are. Comparing
 * the two is the only real control in the flow — everything before it is
 * self-declared by the applicant.
 *
 * A name that does not match is NOT rejected here. It is nearly always an
 * ordinary human variation — a married name, a middle name the applicant left
 * out, a transliterated passport, Estonian diacritics — and refusing those
 * automatically would strand honest people with no way forward. But it is also
 * exactly what a forwarded link looks like, so it is flagged for a person to
 * look at and the invite does not complete on its own.
 *
 * Environment
 *   DIDIT_WEBHOOK_SECRET   required — unsigned requests are refused
 */
import { createClient } from 'jsr:@supabase/supabase-js@2';

const SECRET = Deno.env.get('DIDIT_WEBHOOK_SECRET');

/** Didit's vocabulary, in its own casing, mapped to the kyc_status enum. */
const STATUS: Record<string, string> = {
  'not started': 'not_started', 'in progress': 'in_progress',
  'awaiting user': 'awaiting_user', 'in review': 'in_review',
  approved: 'approved', declined: 'declined', abandoned: 'abandoned',
  'resubmission requested': 'resubmitted', resubmitted: 'resubmitted',
  expired: 'expired', 'kyc expired': 'kyc_expired'
};

/** Constant-time compare — a fast reject leaks the signature one byte at a time. */
function safeEqual(a: string, b: string) {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

async function hmacHex(secret: string, body: string) {
  const key = await crypto.subtle.importKey(
    'raw', new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const sig = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(body));
  return [...new Uint8Array(sig)].map(x => x.toString(16).padStart(2, '0')).join('');
}

/** The provider has moved this field between releases; try the known homes. */
function nameFromPayload(p: any): string | null {
  const candidates = [
    p?.decision?.kyc?.full_name,
    p?.decision?.kyc?.name,
    p?.kyc?.full_name,
    p?.decision?.id_verification?.full_name,
    [p?.decision?.kyc?.first_name, p?.decision?.kyc?.last_name].filter(Boolean).join(' '),
    p?.full_name
  ];
  for (const c of candidates) {
    const s = String(c ?? '').trim();
    if (s) return s;
  }
  return null;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('POST only', { status: 405 });

  const raw = await req.text();

  if (!SECRET) {
    console.error('DIDIT_WEBHOOK_SECRET is not set — refusing an unverifiable webhook');
    return new Response('not configured', { status: 503 });
  }

  const sig = req.headers.get('x-signature') ?? '';
  const ts = Number(req.headers.get('x-timestamp') ?? '0');
  if (!safeEqual(sig, await hmacHex(SECRET, raw))) {
    console.warn('bad webhook signature');
    return new Response('bad signature', { status: 401 });
  }
  // Five minutes. A valid body with a valid signature is still a replay if it
  // arrives an hour later.
  if (ts && Math.abs(Date.now() / 1000 - ts) > 300) {
    return new Response('stale', { status: 401 });
  }

  let p: any;
  try { p = JSON.parse(raw); } catch { return new Response('bad json', { status: 400 }); }

  const db = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false } }
  );

  const providerSession = String(p.session_id ?? p.id ?? '');
  const status = STATUS[String(p.status ?? '').toLowerCase()] ?? 'in_progress';
  const inviteId = String(p.vendor_data ?? '');

  // Record the event first and unconditionally. provider_event is unique, so a
  // retry lands here and stops — the status write below stays idempotent.
  const { data: sess } = await db.from('kyc_sessions')
    .select('id').eq('provider_session_id', providerSession).maybeSingle();

  if (sess) {
    const { error: evErr } = await db.from('kyc_status_events').insert({
      session_id: sess.id, status,
      provider_event: String(p.event_id ?? `${providerSession}:${p.status}:${ts}`),
      webhook_type: String(p.webhook_type ?? p.type ?? ''),
      verified_via: 'x-signature', raw: p
    });
    if (evErr && !/duplicate key/i.test(evErr.message)) console.error('event insert failed', evErr);
    await db.from('kyc_sessions').update({ status }).eq('id', sess.id);
  }

  if (!inviteId) return new Response('ok', { status: 200 });

  const { data: inv } = await db.from('verification_invites')
    .select('id, declared_name, id_verified_at').eq('id', inviteId).maybeSingle();
  if (!inv) return new Response('ok', { status: 200 });

  if (status !== 'approved') {
    await db.from('verification_invites')
      .update({ review_note: `identity check: ${status}` }).eq('id', inv.id);
    return new Response('ok', { status: 200 });
  }

  const verifiedName = nameFromPayload(p);

  // No name on an approved check means the comparison could not be made — which
  // is a reason for someone to look, not a reason to pass it.
  let grade = 'mismatch';
  if (verifiedName) {
    const { data: g } = await db.rpc('name_match_grade', {
      p_declared: inv.declared_name, p_verified: verifiedName
    });
    grade = String(g ?? 'mismatch');
  }

  const clean = grade === 'exact' || grade === 'close';
  await db.from('verification_invites').update({
    verified_name: verifiedName,
    name_match: grade,
    review_required: !clean,
    review_note: clean ? null
      : verifiedName
        ? `Declared "${inv.declared_name}", document says "${verifiedName}" — needs a human.`
        : 'Identity check approved but returned no name to compare.',
    // Only a name we could match completes the step on its own. A flagged one
    // still needs the check to have happened, so the timestamp is set either
    // way; review_required is what holds it back on our side.
    id_verified_at: inv.id_verified_at ?? new Date().toISOString()
  }).eq('id', inv.id);

  return new Response('ok', { status: 200 });
});
