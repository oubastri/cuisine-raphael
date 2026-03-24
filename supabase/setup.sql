-- La Cuisine de Raphaël — run once in Supabase: SQL Editor → New query → Run
-- After this, copy Project URL + anon public key into index.html (SUPABASE_URL / SUPABASE_KEY).
-- (No DROP commands here, so the editor won’t show the “destructive query” warning.)

create table if not exists public.raphael_progress (
  day_id text primary key,
  done boolean not null default false,
  checked_by text,
  checked_at timestamptz
);

comment on table public.raphael_progress is 'Baby feeding plan checkmarks; day_id matches app ids (e.g. w0-d0).';

alter table public.raphael_progress enable row level security;

-- Family app uses only the browser anon key (no Supabase Auth yet).
-- Anyone with your anon key can read/write this table — fine for private use; tighten later if you add auth.
create policy "raphael_progress_select_anon"
  on public.raphael_progress for select to anon using (true);

create policy "raphael_progress_insert_anon"
  on public.raphael_progress for insert to anon with check (true);

create policy "raphael_progress_update_anon"
  on public.raphael_progress for update to anon using (true) with check (true);

create policy "raphael_progress_delete_anon"
  on public.raphael_progress for delete to anon using (true);

-- Realtime (app subscribes via postgres_changes on raphael_progress).
-- If this errors with “already member of publication”, the table is already enabled — that is fine.
alter publication supabase_realtime add table public.raphael_progress;

-- ── If you ever need to re-run policy changes after editing this file, run in a separate query:
-- drop policy if exists "raphael_progress_select_anon" on public.raphael_progress;
-- drop policy if exists "raphael_progress_insert_anon" on public.raphael_progress;
-- drop policy if exists "raphael_progress_update_anon" on public.raphael_progress;
-- drop policy if exists "raphael_progress_delete_anon" on public.raphael_progress;
-- …then run the four create policy statements again. Supabase will warn about “destructive” for DROP — that’s expected.
