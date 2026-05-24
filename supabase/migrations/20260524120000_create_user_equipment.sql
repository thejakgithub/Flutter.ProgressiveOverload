-- Stores user's selected equipment for workout planning.
create table if not exists public.user_equipment (
  user_id uuid primary key references auth.users(id) on delete cascade,
  equipment_list text[] not null default '{}',
  has_bodyweight boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_equipment enable row level security;

-- Users can read only their own equipment.
drop policy if exists "Read own equipment" on public.user_equipment;
create policy "Read own equipment"
  on public.user_equipment
  for select
  to authenticated
  using (auth.uid() = user_id);

-- Users can insert only their own equipment row.
drop policy if exists "Insert own equipment" on public.user_equipment;
create policy "Insert own equipment"
  on public.user_equipment
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Users can update only their own equipment row.
drop policy if exists "Update own equipment" on public.user_equipment;
create policy "Update own equipment"
  on public.user_equipment
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create or replace function public.set_user_equipment_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_user_equipment_updated_at on public.user_equipment;
create trigger trg_user_equipment_updated_at
before update on public.user_equipment
for each row execute function public.set_user_equipment_updated_at();
