-- Emostate · Supabase schema
-- Run once in the Supabase dashboard → SQL Editor → New query → Run.
-- Safe to re-run: every statement is idempotent.

create table if not exists public.check_ins (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null default auth.uid()
                        references auth.users (id) on delete cascade,
  created_at          timestamptz not null default now(),

  -- What the user entered (ReflectionInput)
  journal_text        text not null,
  ambience_type       text not null,
  sleep_hours         numeric(4, 1) not null,
  energy_level        smallint not null check (energy_level between 1 and 5),
  stress_level        smallint not null check (stress_level between 1 and 5),
  time_of_day         text not null,
  previous_day_mood   text not null,
  face_emotion_hint   text not null,

  -- What the engine returned (PredictionResult)
  predicted_state     text not null,
  predicted_intensity smallint not null check (predicted_intensity between 1 and 5),
  confidence          real not null check (confidence between 0 and 1),
  uncertain           boolean not null,
  what_to_do          text not null,
  when_to_do          text not null,
  support_message     text not null,
  state_probabilities jsonb not null default '{}'::jsonb
);

create index if not exists check_ins_user_created_idx
  on public.check_ins (user_id, created_at desc);

-- Row-level security: every user can only see and manage their own rows.
alter table public.check_ins enable row level security;

drop policy if exists "check_ins_select_own" on public.check_ins;
create policy "check_ins_select_own" on public.check_ins
  for select to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "check_ins_insert_own" on public.check_ins;
create policy "check_ins_insert_own" on public.check_ins
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "check_ins_delete_own" on public.check_ins;
create policy "check_ins_delete_own" on public.check_ins
  for delete to authenticated
  using ((select auth.uid()) = user_id);

-- No update policy: check-ins are an immutable log.
