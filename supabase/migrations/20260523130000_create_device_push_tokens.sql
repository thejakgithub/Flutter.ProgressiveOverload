-- Stores one or more push tokens per authenticated user/device.
create table if not exists public.device_push_tokens (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  fcm_token text not null,
  platform text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint device_push_tokens_user_token_unique unique (user_id, fcm_token)
);

create index if not exists device_push_tokens_user_id_idx
  on public.device_push_tokens (user_id);

alter table public.device_push_tokens enable row level security;

-- Users can read only their own registered tokens.
drop policy if exists "Read own push tokens" on public.device_push_tokens;
create policy "Read own push tokens"
  on public.device_push_tokens
  for select
  to authenticated
  using (auth.uid() = user_id);

-- Users can register tokens only for themselves.
drop policy if exists "Insert own push tokens" on public.device_push_tokens;
create policy "Insert own push tokens"
  on public.device_push_tokens
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Users can update only their own tokens.
drop policy if exists "Update own push tokens" on public.device_push_tokens;
create policy "Update own push tokens"
  on public.device_push_tokens
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Users can remove only their own tokens.
drop policy if exists "Delete own push tokens" on public.device_push_tokens;
create policy "Delete own push tokens"
  on public.device_push_tokens
  for delete
  to authenticated
  using (auth.uid() = user_id);

create or replace function public.set_device_push_tokens_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_device_push_tokens_updated_at on public.device_push_tokens;
create trigger trg_device_push_tokens_updated_at
before update on public.device_push_tokens
for each row execute function public.set_device_push_tokens_updated_at();
