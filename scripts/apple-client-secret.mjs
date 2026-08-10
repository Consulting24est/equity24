#!/usr/bin/env node
/**
 * Generates the Apple "client secret" for Supabase's Apple provider.
 *
 * Apple does not issue a static secret. The value you paste into Supabase is a
 * JWT you sign yourself with your Sign in with Apple key, and Apple refuses any
 * token whose lifetime exceeds SIX MONTHS. So this has to be re-run twice a
 * year — and when it lapses, Apple sign-in fails for everyone with no warning.
 * Put a calendar reminder a few weeks before the printed expiry.
 *
 * Usage:
 *   node scripts/apple-client-secret.mjs \
 *     --key    ./AuthKey_ABC1234567.p8 \
 *     --key-id ABC1234567 \
 *     --team   DEF7654321 \
 *     --client io.equity24.signin
 *
 *   --key      path to the .p8 downloaded from Apple (never commit this file)
 *   --key-id   Key ID, shown next to the key in the Apple Developer portal
 *   --team     Team ID, top right of the Apple Developer portal
 *   --client   the SERVICES ID identifier, not the App ID — this is the single
 *              most common mistake; the App ID will authenticate and then fail
 *              at the redirect with invalid_client
 *
 * The private key is read from disk and never leaves this machine. Paste the
 * printed JWT into Supabase -> Authentication -> Sign In / Providers -> Apple
 * -> "Secret Key (for OAuth)".
 */
import { createSign } from 'node:crypto';
import { readFileSync } from 'node:fs';

const args = Object.fromEntries(
  process.argv.slice(2).reduce((acc, cur, i, arr) => {
    if (cur.startsWith('--')) acc.push([cur.slice(2), arr[i + 1]]);
    return acc;
  }, [])
);

const missing = ['key', 'key-id', 'team', 'client'].filter(k => !args[k]);
if (missing.length) {
  console.error('Missing required option(s): ' + missing.map(m => '--' + m).join(', '));
  console.error('Run with no arguments to see the usage comment at the top of this file.');
  process.exit(1);
}

const b64url = buf =>
  Buffer.from(buf).toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

const now = Math.floor(Date.now() / 1000);
// Apple's hard ceiling is 6 months (15777000s). Stay just inside it.
const SIX_MONTHS = 15777000;
const exp = now + SIX_MONTHS - 60;

const header = { alg: 'ES256', kid: args['key-id'] };
const payload = {
  iss: args.team,
  iat: now,
  exp,
  aud: 'https://appleid.apple.com',
  sub: args.client
};

const signingInput = b64url(JSON.stringify(header)) + '.' + b64url(JSON.stringify(payload));

let privateKey;
try {
  privateKey = readFileSync(args.key, 'utf8');
} catch (e) {
  console.error(`Could not read the key file at ${args.key}: ${e.message}`);
  process.exit(1);
}

// JWS requires the raw r||s form, not the DER encoding OpenSSL emits by default.
const signer = createSign('SHA256');
signer.update(signingInput);
signer.end();
const signature = signer.sign({ key: privateKey, dsaEncoding: 'ieee-p1363' });

const jwt = signingInput + '.' + b64url(signature);

console.log('\nApple client secret (paste into Supabase):\n');
console.log(jwt);
console.log('\n  expires: ' + new Date(exp * 1000).toISOString().slice(0, 10) +
            '  —  Apple sign-in stops working on this date unless you re-run this.');
console.log('  services id: ' + args.client);
console.log('\nDo not commit this JWT or the .p8 key.\n');
