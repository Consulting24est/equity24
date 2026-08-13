#!/usr/bin/env node
/**
 * Assembles the static site into dist/ for publication.
 *
 * Only the public product is copied — the licence annexes, audit records,
 * research and legal drafts stay in the repo and are never published.
 */
import { mkdirSync, copyFileSync, writeFileSync, readFileSync, existsSync, rmSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const src = join(root, 'platform-v2');
const dist = join(root, 'dist');

// Pre-authorisation: the site must not be indexed. Stated on every page, in
// robots.txt, and again as a header where the host supports it.
const HEAD = [
  '<meta name="robots" content="noindex, nofollow, noarchive, nosnippet">',
  '<meta name="viewport" content="width=device-width, initial-scale=1">',
  '<meta charset="utf-8">',
  ''
].join('\n');

rmSync(dist, { recursive: true, force: true });
mkdirSync(dist, { recursive: true });

const page = (file, out) => {
  const html = HEAD + readFileSync(join(src, file), 'utf8');
  mkdirSync(dirname(join(dist, out)), { recursive: true });
  writeFileSync(join(dist, out), html);
};

// Landing page. The sign-up CTAs point at /app/#/signup in the source itself.
// They used to be rewritten here, but String.replace with a string pattern only
// replaces the first match, so exactly one of the two buttons was ever fixed.
const landing = HEAD + readFileSync(join(src, 'mockup-en-v2.html'), 'utf8');
writeFileSync(join(dist, 'index.html'), landing);

// Guard: no sign-up control may point back at the old on-page anchor.
const strayCta = /<a[^>]*href="#waitlist"[^>]*>\s*Sign up/i.test(landing);
if (strayCta) {
  console.error('ERROR: a "Sign up" CTA still points at #waitlist instead of /app/#/signup');
  process.exit(1);
}

// App
mkdirSync(join(dist, 'app'), { recursive: true });
writeFileSync(join(dist, 'app', 'index.html'), HEAD + readFileSync(join(src, 'app-prototype-v1.html'), 'utf8'));

// The verification landing page. Reached only from a link in an email, by
// someone who has no account here — so it sits outside /app/ and never loads
// the app shell or asks anybody to sign in.
page('verify.html', 'verify/index.html');

// Mandatory ECSPR art 19 disclosure pages, at clean URLs and as .html
for (const p of ['how-we-choose', 'risks', 'complaints', 'terms', 'privacy', 'pricing']) {
  page(`${p}.html`, `${p}/index.html`);
  page(`${p}.html`, `${p}.html`);
}

copyFileSync(join(src, 'pages.css'), join(dist, 'pages.css'));

// Client-side modules (Supabase binding). Only the publishable key travels
// here; the secret-scan step below fails the build if anything else does.
mkdirSync(join(dist, 'js'), { recursive: true });
for (const f of readdirSync(join(src, 'js'))) {
  if (f.endsWith('.js')) copyFileSync(join(src, 'js', f), join(dist, 'js', f));
}

// GitHub Pages serves 404.html for unknown paths
writeFileSync(join(dist, '404.html'), HEAD + `<title>Not found — Equity24.io</title>
<link rel="stylesheet" href="/pages.css">
<div class="wrap"><div class="page-head"><h1>That page does not exist.</h1>
<p class="lede"><a href="/">Back to equity24.io</a></p></div></div>`);

writeFileSync(join(dist, 'robots.txt'), 'User-agent: *\nDisallow: /\n');

// Custom domain for GitHub Pages
writeFileSync(join(dist, 'CNAME'), 'equity24.io\n');

// Jekyll would otherwise ignore files beginning with an underscore
writeFileSync(join(dist, '.nojekyll'), '');

const files = [];
const walk = (d, base = '') => {
  for (const e of readdirSync(d, { withFileTypes: true })) {
    if (e.isDirectory()) walk(join(d, e.name), base + e.name + '/');
    else files.push(base + e.name);
  }
};
walk(dist);

console.log(`built dist/ — ${files.length} files`);
for (const f of files.sort()) console.log('  ' + f);

// Guard: nothing from the licence package or the legal drafts may reach dist/
const forbidden = files.filter(f => /lisa-|POHITAOTLUS|audit|legal\/|research\//i.test(f));
if (forbidden.length) {
  console.error('\nERROR: non-public files staged for publication:', forbidden);
  process.exit(1);
}
if (!existsSync(join(dist, 'robots.txt'))) { console.error('ERROR: robots.txt missing'); process.exit(1); }

// Guard: no live credential may reach a public repo. This was a manual grep
// before every deploy, which is exactly the kind of step that gets skipped on
// the one deploy that matters. The publishable Supabase key is the deliberate
// exception — it is designed to be public and RLS is what protects the data.
const SECRETS = [
  [/\bsb_secret_[A-Za-z0-9_-]{10,}/, 'Supabase secret key'],
  [/\bservice_role\b/i,              'service-role key'],
  [/\bre_[A-Za-z0-9]{8}_[A-Za-z0-9]{20,}/, 'Resend API key'],
  [/\bGOCSPX-[A-Za-z0-9_-]{10,}/,    'Google OAuth client secret'],
  [/\bSG\.[A-Za-z0-9_-]{20,}/,       'SendGrid key'],
  [/\bsk-[A-Za-z0-9]{32,}/,          'OpenAI-style key'],
  [/\beyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\./, 'a JWT']
];
const leaks = [];
for (const f of files) {
  if (/\.(png|jpg|jpeg|gif|webp|ico|woff2?)$/i.test(f)) continue;
  const text = readFileSync(join(dist, f), 'utf8');
  for (const [re, what] of SECRETS) if (re.test(text)) leaks.push(`${f} — looks like ${what}`);
}
if (leaks.length) {
  console.error('\nERROR: refusing to build. This repo is PUBLIC and dist/ contains:');
  for (const l of leaks) console.error('  ' + l);
  process.exit(1);
}

console.log('\nguards passed: only public product files, noindex in place, no credentials');
