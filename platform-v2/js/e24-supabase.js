/**
 * Equity24.io — Supabase binding for the app.
 *
 * Only the publishable key lives here. It is designed to be public: every table
 * is behind row-level security (see supabase/migrations/0002_rls.sql), so this
 * key can read nothing the signed-in user is not entitled to read. The service
 * role key must never appear in this file or anywhere else the browser loads.
 *
 * The module attaches window.E24 and resolves window.E24.ready. If Supabase is
 * unreachable — offline, project paused, migrations not yet applied — ready
 * resolves with { ok: false } and the app falls back to its local prototype
 * state rather than showing a broken screen.
 */

// Major-pinned. A patch-pinned URL goes stale and 404s; a bare tag would let a
// major bump land silently.
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';

export const CONFIG = {
  url: 'https://wmwcpfdqxkvojuddwhls.supabase.co',
  publishableKey: 'sb_publishable_Zm4Z_PiGWbpNsHm8RmlKgQ_DH7cCoL3',
  termsVersion: '1.0',
  privacyVersion: '1.0'
};

const sb = createClient(CONFIG.url, CONFIG.publishableKey, {
  auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true }
});

/* The signup cards speak one vocabulary, the database another. */
const TO_DB = { raise: 'company', private: 'private_investor', corporate: 'corporate_investor' };
const TO_UI = { company: 'raise', private_investor: 'private', corporate_investor: 'corporate' };

const listeners = new Set();
const emit = () => { for (const fn of listeners) { try { fn(E24.session, E24.profile); } catch (e) { console.error(e); } } };

/** Supabase errors are objects; surface something a human can act on. */
function fail(error, fallback) {
  const msg = (error && (error.message || error.error_description)) || fallback;
  return { ok: false, error: msg };
}

const E24 = {
  sb,
  config: CONFIG,
  ok: false,          // did we reach the database at all
  session: null,
  profile: null,
  staff: null,        // null = unknown, false = not staff, or the role string

  toDb: t => TO_DB[t] || t,
  toUi: t => TO_UI[t] || t,

  onChange(fn) { listeners.add(fn); return () => listeners.delete(fn); },

  providers: null,      // { google: bool, ... } once /auth/v1/settings answers

  /**
   * Which sign-in providers this project actually has switched on.
   *
   * This has to be asked up front. signInWithOAuth does not call the server —
   * it builds a URL and navigates — so it returns { error: null } even for a
   * disabled provider, and the failure only appears as raw JSON on Supabase's
   * own domain after the redirect. Checking first is the only way to keep the
   * user on our page.
   */
  async loadProviders() {
    try {
      const res = await fetch(CONFIG.url + '/auth/v1/settings', {
        headers: { apikey: CONFIG.publishableKey }
      });
      if (!res.ok) return null;
      const s = await res.json();
      E24.providers = s.external || null;
      return E24.providers;
    } catch { return null; }
  },

  providerEnabled(name) {
    return !!(E24.providers && E24.providers[name]);
  },

  /* ------------------------------------------------------------- session --- */
  async refresh() {
    const { data, error } = await sb.auth.getSession();
    if (error) { E24.ok = false; return fail(error, 'Could not reach Supabase'); }
    E24.ok = true;
    E24.session = data.session || null;
    E24.profile = E24.session ? await E24.loadProfile() : null;
    E24.staff = E24.session ? await E24.loadStaff() : null;
    emit();
    return { ok: true, session: E24.session, profile: E24.profile };
  },

  /* -------------------------------------------------------------- signup --- */
  /**
   * Creates the auth user. The profile row is written by the on_auth_user_created
   * trigger from this metadata — the client never inserts into profiles directly,
   * so a half-created account is not possible.
   */
  async signUp({ email, password, accountType, fullName, companyName, registryCode, country }) {
    const dbType = TO_DB[accountType] || 'private_investor';
    if (dbType === 'corporate_investor' && !(companyName || '').trim()) {
      return { ok: false, error: 'A corporate investor account needs a company name.' };
    }
    const { data, error } = await sb.auth.signUp({
      email,
      password,
      options: {
        // No fragment. Supabase appends its token to this URL, and appending to
        // a URL that already has one produces '/app/#/login#access_token=...'
        // (or '?code=' inside the fragment), which detectSessionInUrl cannot
        // parse — the confirmation link would sign nobody in.
        emailRedirectTo: location.origin + '/app/',
        data: {
          account_type: dbType,
          full_name: (fullName || '').trim(),
          company_name: (companyName || '').trim() || null,
          company_registry_code: (registryCode || '').trim() || null,
          country: country || 'EE'
        }
      }
    });
    if (error) return fail(error, 'Sign-up failed');
    // With email confirmation on — which it must stay, because staff bootstrap
    // trusts the mailbox — there is no session until the link is clicked.
    const needsConfirmation = !data.session;
    if (data.session) await E24.refresh();
    return { ok: true, needsConfirmation, email };
  },

  async signIn({ email, password }) {
    const { error } = await sb.auth.signInWithPassword({ email, password });
    if (error) return fail(error, 'Could not sign in');
    await E24.refresh();
    return { ok: true };
  },

  /**
   * OAuth carries no account_type, so the trigger defaults the profile to
   * private_investor; the chosen role is re-applied on return.
   */
  async oauth(provider, accountType) {
    if (E24.providers && !E24.providerEnabled(provider)) {
      return { ok: false, error: 'Google sign-in is not switched on yet. Please sign up with an email address and password for now.' };
    }
    const { error } = await sb.auth.signInWithOAuth({
      provider,
      // Fragment-free, for the same reason as emailRedirectTo above.
      options: { redirectTo: location.origin + '/app/' }
    });
    // Stashed only once the redirect is actually going to happen. Writing it
    // first left a stale role behind on a failed attempt, which a later
    // unrelated sign-in would then apply to the wrong account.
    if (!error && accountType) {
      sessionStorage.setItem('e24-pending-type', TO_DB[accountType] || accountType);
    }
    if (error) {
      // "Unsupported provider: provider is not enabled" is a configuration
      // state, not something the person signing up did wrong.
      if (/not enabled|unsupported provider/i.test(error.message || '')) {
        return { ok: false, error: 'Google sign-in is not switched on yet. Please sign up with an email address and password for now.' };
      }
      return fail(error, 'Could not start ' + provider + ' sign-in');
    }
    return { ok: true };
  },

  async applyPendingType() {
    const pending = sessionStorage.getItem('e24-pending-type');
    if (!pending || !E24.session) return;
    sessionStorage.removeItem('e24-pending-type');
    if (pending === 'corporate_investor') return;   // needs a company name; leave it to the profile page
    if (E24.profile && E24.profile.account_type !== pending) {
      await E24.saveProfile({ account_type: pending });
    }
  },

  async signOut() {
    await sb.auth.signOut();
    E24.session = null; E24.profile = null; E24.staff = null;
    emit();
  },

  /* ------------------------------------------------------------- profile --- */
  async loadProfile() {
    if (!E24.session) return null;
    const { data, error } = await sb.from('profiles').select('*').eq('id', E24.session.user.id).maybeSingle();
    if (error) { console.warn('profile read failed', error.message); return null; }
    return data;
  },

  async saveProfile(patch) {
    if (!E24.session) return { ok: false, error: 'Not signed in' };
    const { data, error } = await sb.from('profiles').update(patch)
      .eq('id', E24.session.user.id).select().maybeSingle();
    if (error) return fail(error, 'Could not save your profile');
    // A zero-row update returns data:null with no error. Treating that as
    // success would both report a save that did not happen and wipe the
    // cached profile, so callers must see it as the failure it is.
    if (!data) {
      return { ok: false, error: 'Your profile record could not be found. Please sign out and sign in again.' };
    }
    E24.profile = data; emit();
    return { ok: true, profile: data };
  },

  /** ECSPR art 26 — acceptance is evidence, so it is stamped, not implied. */
  async acceptTerms() {
    const now = new Date().toISOString();
    return E24.saveProfile({
      terms_version: CONFIG.termsVersion, terms_accepted_at: now,
      privacy_version: CONFIG.privacyVersion, privacy_accepted_at: now
    });
  },

  hasAcceptedTerms() {
    return !!(E24.profile && E24.profile.terms_accepted_at);
  },

  /* --------------------------------------------------------------- staff --- */
  /**
   * Returns the role string, false for "definitely not staff", or null for
   * "could not tell". A transient failure must not read as a definitive answer:
   * it would silently demote a real staff member and let the console state so.
   */
  async loadStaff() {
    if (!E24.session) return null;
    const { data, error } = await sb.from('staff_roles')
      .select('role, revoked_at').eq('profile_id', E24.session.user.id)
      .is('revoked_at', null).maybeSingle();
    if (error) { console.warn('staff role read failed', error.message); return null; }
    return data ? data.role : false;     // RLS returns no rows for non-staff
  },

  isStaff() { return typeof E24.staff === 'string'; },
  staffKnown() { return E24.staff !== null; },

  /**
   * Every signup, newest first, with the latest verification decision attached.
   * RLS returns only the caller's own row unless is_staff() passes, so this is
   * safe to call from any session — a non-staff user simply sees themselves.
   */
  async listSignups({ limit = 200 } = {}) {
    const { data: profiles, error } = await sb.from('profiles')
      .select('id, full_name, email, account_type, investor_class, country, company_name, company_registry_code, terms_accepted_at, created_at, closed_at')
      .order('created_at', { ascending: false }).limit(limit);
    if (error) return fail(error, 'Could not load signups');

    const { data: kyc, error: kycError } = await sb.from('kyc_sessions')
      .select('profile_id, kind, status, updated_at')
      .order('updated_at', { ascending: false });

    const latest = new Map();
    for (const k of kyc || []) if (!latest.has(k.profile_id)) latest.set(k.profile_id, k);

    // If the KYC read failed, say so. Rendering a dash for every row would
    // read as "no verification on record" in a supervision screen.
    return {
      ok: true,
      kycUnavailable: !!kycError,
      rows: (profiles || []).map(p => ({ ...p, kyc: latest.get(p.id) || null }))
    };
  }
};

sb.auth.onAuthStateChange(async (event) => {
  if (event === 'SIGNED_IN' || event === 'TOKEN_REFRESHED' || event === 'SIGNED_OUT') {
    await E24.refresh();
    if (event === 'SIGNED_IN') await E24.applyPendingType();
  }
});

window.E24 = E24;

// The app is a classic script and runs before this module, so it cannot read
// window.E24 at boot. It listens for this event instead.
const announce = result => {
  window.dispatchEvent(new CustomEvent('e24-ready', { detail: result }));
  return result;
};
window.E24.ready = Promise.all([E24.loadProviders(), E24.refresh()])
  .then(([, r]) => r)
  .catch(e => {
    console.warn('Supabase unreachable — running on local prototype state.', e);
    E24.ok = false;
    return { ok: false, error: String(e) };
  })
  .then(announce);

export default E24;
