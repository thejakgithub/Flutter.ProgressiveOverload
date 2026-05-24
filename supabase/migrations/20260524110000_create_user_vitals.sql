-- Stores onboarding vitals for each authenticated user.
create table if not exists public.user_vitals (
  user_id uuid primary key references auth.users(id) on delete cascade,
  gender text not null,
  age integer not null,
  height_cm numeric not null,
  weight_kg numeric not null,
  fitness_goal text not null,
  training_days_per_week integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_vitals_age_positive check (age > 0),
  constraint user_vitals_height_positive check (height_cm > 0),
  constraint user_vitals_weight_positive check (weight_kg > 0),
  constraint user_vitals_days_range check (
    training_days_per_week >= 1 and training_days_per_week <= 7
  )
);

alter table public.user_vitals enable row level security;

-- Users can read only their own vitals.
drop policy if exists "Read own vitals" on public.user_vitals;
create policy "Read own vitals"
  on public.user_vitals
  for select
  to authenticated
  using (auth.uid() = user_id);

-- Users can insert only their own vitals row.
drop policy if exists "Insert own vitals" on public.user_vitals;
create policy "Insert own vitals"
  on public.user_vitals
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Users can update only their own vitals row.
drop policy if exists "Update own vitals" on public.user_vitals;
create policy "Update own vitals"
  on public.user_vitals
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create or replace function public.set_user_vitals_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_user_vitals_updated_at on public.user_vitals;
create trigger trg_user_vitals_updated_at
before update on public.user_vitals
for each row execute function public.set_user_vitals_updated_at();
