-- =============================================================================
-- Equity24.io — fix infinite recursion in the community policies
--
-- 0002 wrote membership checks as subqueries against community_members from
-- inside a policy ON community_members, so evaluating the policy re-evaluated
-- the policy: 42P17 "infinite recursion detected in policy". Both tables
-- existed but every read failed.
--
-- The fix is the standard one: move the membership test into a security definer
-- function. It runs as the owner, so RLS is not re-applied inside it and the
-- cycle is broken. The visibility rule itself is unchanged — you see a
-- community's members and messages only if you are currently a member of it.
--
-- Run after 0001-0003. Safe to re-run.
-- =============================================================================

create or replace function is_community_member(p_community uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from community_members
    where community_id = p_community
      and profile_id = auth.uid()
      and left_at is null
  );
$$;

-- --------------------------------------------------------- community_members ---
drop policy if exists members_read on community_members;
create policy members_read on community_members for select
  using (is_community_member(community_id) or is_staff());

-- -------------------------------------------------------- community_messages ---
drop policy if exists messages_read on community_messages;
create policy messages_read on community_messages for select
  using ((hidden_at is null and is_community_member(community_id)) or is_staff());

drop policy if exists messages_post on community_messages;
create policy messages_post on community_messages for insert
  with check (profile_id = auth.uid() and is_community_member(community_id));

-- messages_moderate (compliance-only UPDATE, i.e. hiding) is unaffected: it
-- never referenced community_members.
