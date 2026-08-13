/**
 * Equity24.io — the endpoint behind /verify.
 *
 * The person arriving here has no account and no password. The token in their
 * link is the whole credential, which is why it is 256 bits, single-purpose,
 * expiring, and stored only as a hash: this function is the only thing that can
 * turn it back into a name.
 *
 * It deliberately gives the same answer for a token that never existed, a token
 * that expired and a token that was replaced by a re-send — 'this link is not
 * valid' — so the endpoint cannot be used to test whether an address is on an
 * application.
 *
 * Actions
 *   open           resolve the token, mark it opened, return what to display
 *   start-kyc      open an identity check (needs DIDIT_WORKFLOW_ID)
 *   upload-url     signed URL for the criminal-record extract
 *   record-upload  register the uploaded file
 */
import { createClient } from 'jsr:@supabase/supabase-js@2';

const SITE = Deno.env.get('SITE_URL') ?? 'https://equity24.io';
const DIDIT_KEY = Deno.env.get('DIDIT_API_KEY');
const DIDIT_WORKFLOW = Deno.env.get('DIDIT_WORKFLOW_ID');
const DIDIT_KYB_WORKFLOW = Deno.env.get('DIDIT_KYB_WORKFLOW_ID');
const BUCKET = 'verification-documents';

const CORS = {
  'Access-Control-Allow-Origin': SITE,
  'Access-Control-Allow-Headers': 'content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};
const json = (b: unknown, s = 200) =>
  new Response(JSON.stringify(b), { status: s, headers: { ...CORS, 'Content-Type': 'application/json' } });

/** One message for every way a token can fail to resolve. */
const DEAD_LINK = {
  error: 'This link is not valid any more. It may have expired, or a newer link may have been sent to you. Ask the company to send it again.'
};

async function sha256Hex(s: string) {
  const d = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(s));
  return [...new Uint8Array(d)].map(x => x.toString(16).padStart(2, '0')).join('');
}

const admin = () => createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  { auth: { persistSession: false } }
);

/** Nothing here identifies anyone but the recipient themselves. */
function present(inv: any) {
  return {
    name: inv.declared_name,
    email: inv.declared_email,
    company: inv.company_name,
    roles: inv.roles ?? [],
    equityPct: inv.equity_pct,
    isEntity: inv.is_entity,
    needsCriminalRecord: inv.needs_criminal_record,
    idVerified: !!inv.id_verified_at,
    recordsReceived: !!inv.records_received_at,
    complete: inv.status === 'complete',
    expiresAt: inv.expires_at
  };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return json({ error: 'POST only' }, 405);

  let body: any;
  try { body = await req.json(); } catch { return json({ error: 'Bad request' }, 400); }

  const token = String(body.token ?? '');
  const action = String(body.action ?? 'open');
  if (!token || token.length < 20) return json(DEAD_LINK, 404);

  const db = admin();
  const { data: inv, error } = await db
    .from('verification_invites')
    .select('*')
    .eq('token_hash', await sha256Hex(token))
    .maybeSingle();

  if (error) { console.error('lookup failed', error); return json({ error: 'Something went wrong. Please try again.' }, 500); }
  if (!inv) return json(DEAD_LINK, 404);
  if (inv.status === 'revoked') return json(DEAD_LINK, 404);
  if (new Date(inv.expires_at) < new Date()) return json(DEAD_LINK, 404);

  /* ------------------------------------------------------------------ open --- */
  if (action === 'open') {
    if (!inv.opened_at) {
      await db.from('verification_invites')
        .update({ opened_at: new Date().toISOString() }).eq('id', inv.id);
    }
    return json({ ok: true, invite: present(inv) });
  }

  /* ------------------------------------------------------------- start-kyc --- */
  if (action === 'start-kyc') {
    const workflow = inv.is_entity ? DIDIT_KYB_WORKFLOW : DIDIT_WORKFLOW;
    if (!DIDIT_KEY || !workflow) {
      // Said out loud rather than dressed up as a technical error: the identity
      // provider is not connected yet, and the person should not be left
      // clicking a button that silently does nothing.
      return json({ error: 'not-configured', message: 'Identity checks are not switched on yet. You will get another email when this step is ready.' }, 503);
    }

    const res = await fetch('https://verification.didit.me/v2/session/', {
      method: 'POST',
      headers: { 'x-api-key': DIDIT_KEY, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        workflow_id: workflow,
        // The only thing tying the provider's answer back to this row.
        vendor_data: inv.id,
        callback: `${SITE}/verify/?t=${token}&done=1`,
        contact_details: { email: inv.declared_email }
      })
    });
    const out = await res.json().catch(() => ({}));
    if (!res.ok || !out?.url) {
      console.error('didit session failed', res.status, out);
      return json({ error: 'Could not open the identity check just now. Please try again in a few minutes.' }, 502);
    }

    const { data: sess } = await db.from('kyc_sessions').insert({
      provider: 'didit',
      provider_session_id: out.session_id ?? out.id,
      kind: inv.is_entity ? 'business' : 'user',
      status: 'in_progress',
      vendor_data: inv.id
    }).select('id').single();

    if (sess) await db.from('verification_invites').update({ kyc_session_id: sess.id }).eq('id', inv.id);
    return json({ ok: true, url: out.url });
  }

  /* ------------------------------------------------------------ upload-url --- */
  if (action === 'upload-url') {
    if (!inv.needs_criminal_record) return json({ error: 'No document is needed from you.' }, 400);
    const original = String(body.filename ?? 'extract.pdf');
    const ext = (original.match(/\.[a-z0-9]{1,5}$/i)?.[0] ?? '.pdf').toLowerCase();
    if (!['.pdf', '.jpg', '.jpeg', '.png', '.heic'].includes(ext)) {
      return json({ error: 'Please upload a PDF or a photo (JPG, PNG or HEIC).' }, 400);
    }
    const path = `${inv.id}/${crypto.randomUUID()}${ext}`;
    const { data, error: upErr } = await db.storage.from(BUCKET).createSignedUploadUrl(path);
    if (upErr || !data) {
      console.error('signed upload url failed', upErr);
      return json({ error: 'Could not start the upload. Please try again.' }, 500);
    }
    return json({ ok: true, path, token: data.token, url: data.signedUrl });
  }

  /* --------------------------------------------------------- record-upload --- */
  if (action === 'record-upload') {
    const path = String(body.path ?? '');
    // The path is minted above and always begins with this invite's id — so a
    // caller cannot register a file that belongs to somebody else's invite.
    if (!path.startsWith(`${inv.id}/`)) return json({ error: 'Bad request' }, 400);

    const { error: docErr } = await db.from('verification_documents').insert({
      invite_id: inv.id,
      kind: 'criminal_record',
      storage_path: path,
      original_name: String(body.filename ?? '').slice(0, 200) || null,
      bytes: Number.isFinite(Number(body.bytes)) ? Number(body.bytes) : null,
      content_type: String(body.contentType ?? '').slice(0, 100) || null
    });
    if (docErr) {
      console.error('document insert failed', docErr);
      return json({ error: 'The file uploaded but could not be recorded. Please tell us at kyc@equity24.io.' }, 500);
    }

    const { data: updated } = await db.from('verification_invites')
      .update({ records_received_at: new Date().toISOString() })
      .eq('id', inv.id).select('*').single();

    return json({ ok: true, invite: present(updated ?? inv) });
  }

  return json({ error: 'Unknown action' }, 400);
});
