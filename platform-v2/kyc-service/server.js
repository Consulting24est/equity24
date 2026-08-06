/**
 * Equity24.io — KYC service (Didit) + static host
 *
 * Zero dependencies. Node 18+ (uses built-in fetch and crypto).
 *
 * WHY A SERVER AT ALL: the Didit API key grants full access to your account.
 * It must never appear in the browser bundle, so every Didit call happens here
 * and the client only ever sees a session id and a hosted verification URL.
 *
 *   node server.js
 */

const http = require('http');
const https = require('https');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

/* ------------------------------------------------------------------ config */
const ENV_PATH = path.join(__dirname, '.env');
const env = {};
if (fs.existsSync(ENV_PATH)) {
  for (const line of fs.readFileSync(ENV_PATH, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (m) env[m[1]] = m[2];
  }
}
const API_KEY = process.env.DIDIT_API_KEY || env.DIDIT_API_KEY || '';
const WORKFLOW_ID = process.env.DIDIT_WORKFLOW_ID || env.DIDIT_WORKFLOW_ID || '';
const KYB_WORKFLOW_ID = process.env.DIDIT_KYB_WORKFLOW_ID || env.DIDIT_KYB_WORKFLOW_ID || '';
const WEBHOOK_SECRET = process.env.DIDIT_WEBHOOK_SECRET || env.DIDIT_WEBHOOK_SECRET || '';
const PORT = Number(process.env.PORT || env.PORT || 8787);
const PUBLIC_BASE_URL = process.env.PUBLIC_BASE_URL || env.PUBLIC_BASE_URL || `http://localhost:${PORT}`;

const DIDIT_BASE = 'https://verification.didit.me';
// Serve the built site when there is one — its paths (/app/, /js/) are the ones
// production actually serves, so local testing exercises the real URLs.
// STATIC_ROOT overrides both.
const STATIC_ROOT = path.resolve(__dirname, process.env.STATIC_ROOT || env.STATIC_ROOT ||
  (fs.existsSync(path.join(__dirname, '..', '..', 'dist', 'index.html')) ? '../../dist' : '../deploy'));
const STORE_PATH = path.join(__dirname, 'kyc-store.json');

/* ------------------------------------------------------------------- store */
/* A JSON file is fine for a prototype. Production: Postgres, one row per
   session, append-only status history — ECSPR art 26 wants a 5-year trail. */
function readStore() {
  try { return JSON.parse(fs.readFileSync(STORE_PATH, 'utf8')); } catch { return { sessions: {}, events: [] }; }
}
function writeStore(s) { fs.writeFileSync(STORE_PATH, JSON.stringify(s, null, 2)); }

/* --------------------------------------------------------------- didit api */
async function didit(pathname, { method = 'GET', body } = {}) {
  const res = await fetch(DIDIT_BASE + pathname, {
    method,
    headers: {
      'x-api-key': API_KEY,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: body ? JSON.stringify(body) : undefined
  });
  const text = await res.text();
  let json = null;
  try { json = text ? JSON.parse(text) : null; } catch { /* non-JSON error page */ }
  return { ok: res.ok, status: res.status, json, text };
}

/* --------------------------------------------------------------- webhooks */
/** Constant-time hex compare that tolerates length mismatch. */
function safeEqualHex(a, b) {
  if (typeof a !== 'string' || typeof b !== 'string') return false;
  const ba = Buffer.from(a, 'utf8'), bb = Buffer.from(b, 'utf8');
  if (ba.length !== bb.length) return false;
  return crypto.timingSafeEqual(ba, bb);
}
function hmac(payload) {
  return crypto.createHmac('sha256', WEBHOOK_SECRET).update(payload).digest('hex');
}
/** Stable JSON: keys sorted recursively, Unicode preserved (matches X-Signature-V2). */
function canonical(value) {
  if (Array.isArray(value)) return '[' + value.map(canonical).join(',') + ']';
  if (value && typeof value === 'object') {
    return '{' + Object.keys(value).sort()
      .map(k => JSON.stringify(k) + ':' + canonical(value[k])).join(',') + '}';
  }
  return JSON.stringify(value);
}
/**
 * Verify a Didit webhook. Accepts any of the three signature variants, and
 * always enforces the 5-minute replay window first.
 */
function verifyWebhook(headers, rawBody, parsed) {
  if (!WEBHOOK_SECRET) return { ok: false, reason: 'DIDIT_WEBHOOK_SECRET not configured' };

  const ts = Number(headers['x-timestamp']);
  if (!ts || Math.abs(Math.floor(Date.now() / 1000) - ts) > 300) {
    return { ok: false, reason: 'timestamp outside the 5-minute window' };
  }
  const raw = headers['x-signature'];
  const v2 = headers['x-signature-v2'];
  const simple = headers['x-signature-simple'];

  if (raw && safeEqualHex(raw, hmac(rawBody))) return { ok: true, via: 'x-signature' };
  if (v2 && safeEqualHex(v2, hmac(canonical(parsed)))) return { ok: true, via: 'x-signature-v2' };
  if (simple) {
    const envelope = `${parsed.timestamp ?? ts}:${parsed.session_id}:${parsed.status}:${parsed.webhook_type}`;
    if (safeEqualHex(simple, hmac(envelope))) return { ok: true, via: 'x-signature-simple' };
  }
  return { ok: false, reason: 'signature mismatch' };
}

/* ------------------------------------------------------------------ helpers */
function json(res, code, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(code, {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body),
    'Cache-Control': 'no-store'
  });
  res.end(body);
}
function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let size = 0;
    req.on('data', c => {
      size += c.length;
      if (size > 1_000_000) { reject(new Error('body too large')); req.destroy(); return; }
      chunks.push(c);
    });
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}
const MIME = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8', '.json': 'application/json', '.svg': 'image/svg+xml',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.txt': 'text/plain; charset=utf-8' };

function serveStatic(req, res, urlPath) {
  const rel = decodeURIComponent(urlPath.split('?')[0]);
  const base = path.normalize(path.join(STATIC_ROOT, rel));
  if (!base.startsWith(STATIC_ROOT)) { res.writeHead(403); return res.end('Forbidden'); }

  // Clean URLs: /risks resolves to risks.html or risks/index.html.
  const candidates = rel.endsWith('/')
    ? [path.join(base, 'index.html')]
    : path.extname(base)
      ? [base]
      : [base + '.html', path.join(base, 'index.html')];
  const full = candidates.find(c => c.startsWith(STATIC_ROOT) && fs.existsSync(c)) || base;

  fs.readFile(full, (err, data) => {
    if (err) { res.writeHead(404, { 'Content-Type': 'text/plain' }); return res.end('Not found'); }
    res.writeHead(200, {
      'Content-Type': MIME[path.extname(full)] || 'application/octet-stream',
      'X-Robots-Tag': 'noindex, nofollow',
      'Cache-Control': 'no-cache'
    });
    res.end(data);
  });
}

/* -------------------------------------------------------------------- routes */
const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, PUBLIC_BASE_URL);
  const p = url.pathname;

  /* ---- health / config visibility (never leaks the key itself) ---- */
  if (p === '/api/kyc/health') {
    return json(res, 200, {
      service: 'equity24-kyc',
      provider: 'didit',
      api_key: API_KEY ? 'configured' : 'MISSING',
      kyc_workflow_id: WORKFLOW_ID ? 'configured' : 'MISSING — set DIDIT_WORKFLOW_ID in .env',
      kyb_workflow_id: KYB_WORKFLOW_ID ? 'configured' : 'MISSING — set DIDIT_KYB_WORKFLOW_ID in .env (company verification)',
      webhook_secret: WEBHOOK_SECRET ? 'configured' : 'MISSING — set DIDIT_WEBHOOK_SECRET in .env',
      webhook_url: `${PUBLIC_BASE_URL}/api/kyc/webhook`,
      sessions_stored: Object.keys(readStore().sessions).length
    });
  }

  /* ---- create a verification session ---- */
  if (p === '/api/kyc/session' && req.method === 'POST') {
    if (!API_KEY) return json(res, 500, { error: 'DIDIT_API_KEY is not configured' });

    let payload = {};
    try { payload = JSON.parse((await readBody(req)).toString() || '{}'); } catch { /* empty body is fine */ }

    // Company accounts get the KYB workflow; individuals get KYC. The workflow
    // itself decides the session kind at Didit's end — same endpoint either way.
    const isBusiness = payload.account_type === 'raise' || payload.kind === 'business';
    const wf = isBusiness ? KYB_WORKFLOW_ID : WORKFLOW_ID;
    if (!wf) {
      return json(res, 500, {
        error: isBusiness
          ? 'DIDIT_KYB_WORKFLOW_ID is not configured. Copy the KYB workflow id from the Didit console → Workflows.'
          : 'DIDIT_WORKFLOW_ID is not configured. Copy the KYC workflow id from the Didit console → Workflows.'
      });
    }

    const body = {
      workflow_id: wf,
      // vendor_data is our own user id — it comes back on the webhook so we can
      // attach the decision to the right account.
      vendor_data: String(payload.user_id || 'anonymous'),
      callback: payload.callback || `${PUBLIC_BASE_URL}/app/#/kyc-return`,
      language: payload.language || 'en',
      metadata: {
        platform: 'equity24',
        account_type: payload.account_type || 'private',
        kind: isBusiness ? 'business' : 'user'
      }
    };
    if (payload.email) body.contact_details = { email: payload.email, send_notification_emails: false };
    // Pre-filling what we already know shortens the applicant's journey.
    if (isBusiness && (payload.company_name || payload.registry_code || payload.country)) {
      body.expected_details = {};
      if (payload.company_name) body.expected_details.company_name = payload.company_name;
      if (payload.registry_code) body.expected_details.registration_number = payload.registry_code;
      if (payload.country) body.expected_details.country = payload.country;
    }

    const r = await didit('/v3/session/', { method: 'POST', body });
    if (!r.ok) {
      console.error('[didit] create session failed', r.status, r.text.slice(0, 400));
      return json(res, 502, { error: 'Could not start verification', provider_status: r.status, detail: r.json || r.text.slice(0, 200) });
    }
    const store = readStore();
    store.sessions[r.json.session_id] = {
      session_id: r.json.session_id,
      user_id: body.vendor_data,
      account_type: body.metadata.account_type,
      kind: isBusiness ? 'business' : 'user',
      status: r.json.status || 'Not Started',
      created_at: new Date().toISOString(),
      url: r.json.url
    };
    writeStore(store);
    console.log('[didit] session created', r.json.session_id, `(${isBusiness ? 'KYB' : 'KYC'})`, 'for', body.vendor_data);
    return json(res, 201, { session_id: r.json.session_id, url: r.json.url, status: r.json.status, kind: isBusiness ? 'business' : 'user' });
  }

  /* ---- poll a session (client-side status refresh) ---- */
  if (p.startsWith('/api/kyc/session/') && req.method === 'GET') {
    const id = p.split('/')[4];
    if (!id) return json(res, 400, { error: 'session id required' });
    const r = await didit(`/v3/session/${encodeURIComponent(id)}/decision/`);
    if (!r.ok) return json(res, r.status, { error: 'lookup failed', detail: r.json || r.text.slice(0, 200) });

    const store = readStore();
    if (store.sessions[id]) {
      store.sessions[id].status = r.json.status;
      store.sessions[id].updated_at = new Date().toISOString();
      writeStore(store);
    }
    // Only the fields the front-end needs — never proxy the full decision
    // document (it holds document images and personal data).
    return json(res, 200, {
      session_id: r.json.session_id,
      status: r.json.status,
      // "user" for KYC, "business" for KYB
      session_kind: r.json.session_kind,
      vendor_data: r.json.vendor_data,
      created_at: r.json.created_at,
      expires_at: r.json.expires_at
    });
  }

  /* ---- webhook: Didit tells us the outcome ---- */
  if (p === '/api/kyc/webhook' && req.method === 'POST') {
    const rawBuf = await readBody(req);
    const raw = rawBuf.toString('utf8');
    let parsed;
    try { parsed = JSON.parse(raw); } catch { return json(res, 400, { error: 'invalid JSON' }); }

    const check = verifyWebhook(req.headers, raw, parsed);
    if (!check.ok) {
      console.warn('[didit] webhook REJECTED:', check.reason);
      return json(res, 401, { error: 'signature verification failed' });
    }

    const store = readStore();
    // event_id gives us idempotency — Didit may retry.
    if (parsed.event_id && store.events.some(e => e.event_id === parsed.event_id)) {
      return json(res, 200, { ok: true, duplicate: true });
    }
    const sid = parsed.session_id || parsed.business_session_id;
    if (sid) {
      store.sessions[sid] = Object.assign({}, store.sessions[sid], {
        session_id: sid,
        user_id: parsed.vendor_data || (store.sessions[sid] && store.sessions[sid].user_id),
        status: parsed.status,
        webhook_type: parsed.webhook_type,
        kind: parsed.business_session_id ? 'business' : 'user',
        updated_at: new Date().toISOString()
      });
    }
    store.events.push({
      event_id: parsed.event_id, session_id: sid, status: parsed.status,
      webhook_type: parsed.webhook_type, at: new Date().toISOString(), verified_via: check.via
    });
    if (store.events.length > 2000) store.events = store.events.slice(-2000);
    writeStore(store);
    console.log('[didit] webhook ok:', parsed.webhook_type, sid, '→', parsed.status, `(${check.via})`);
    return json(res, 200, { ok: true });
  }

  /* ---- admin: all known sessions ---- */
  if (p === '/api/kyc/sessions' && req.method === 'GET') {
    const store = readStore();
    return json(res, 200, {
      sessions: Object.values(store.sessions).sort((a, b) => (b.created_at || '').localeCompare(a.created_at || '')),
      events: store.events.slice(-50).reverse()
    });
  }

  if (p.startsWith('/api/')) return json(res, 404, { error: 'unknown endpoint' });
  return serveStatic(req, res, p);
});

server.listen(PORT, () => {
  console.log(`\n  Equity24.io KYC service + static host`);
  console.log(`  → ${PUBLIC_BASE_URL}`);
  console.log(`  → landing  ${PUBLIC_BASE_URL}/`);
  console.log(`  → app      ${PUBLIC_BASE_URL}/app/`);
  console.log(`  → health   ${PUBLIC_BASE_URL}/api/kyc/health`);
  console.log(`  → webhook  ${PUBLIC_BASE_URL}/api/kyc/webhook  (register this in the Didit console)\n`);
  if (!API_KEY) console.warn('  ! DIDIT_API_KEY missing');
  if (!WORKFLOW_ID) console.warn('  ! DIDIT_WORKFLOW_ID missing — investor (KYC) sessions cannot be created');
  if (!KYB_WORKFLOW_ID) console.warn('  ! DIDIT_KYB_WORKFLOW_ID missing — company (KYB) sessions cannot be created');
  if (!WEBHOOK_SECRET) console.warn('  ! DIDIT_WEBHOOK_SECRET missing — webhooks will be rejected');
});
