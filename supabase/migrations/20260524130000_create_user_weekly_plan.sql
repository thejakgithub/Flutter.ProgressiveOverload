-- Stores user's weekly workout plan.
create table if not exists public.user_weekly_plan (
  user_id uuid primary key references auth.users(id) on delete cascade,
  plan_data jsonb not null default '{}',
  is_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_weekly_plan enable row level security;

-- Users can read only their own plan.
drop policy if exists "Read own plan" on public.user_weekly_plan;
create policy "Read own plan"
  on public.user_weekly_plan
  for select
  to authenticated
  using (auth.uid() = user_id);

-- Users can insert only their own plan row.
drop policy if exists "Insert own plan" on public.user_weekly_plan;
create policy "Insert own plan"
  on public.user_weekly_plan
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Users can update only their own plan row.
drop policy if exists "Update own plan" on public.user_weekly_plan;
create policy "Update own plan"
  on public.user_weekly_plan
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create or replace function public.set_user_weekly_plan_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_user_weekly_plan_updated_at on public.user_weekly_plan;
create trigger trg_user_weekly_plan_updated_at
before update on public.user_weekly_plan
for each row execute function public.set_user_weekly_plan_updated_at();
