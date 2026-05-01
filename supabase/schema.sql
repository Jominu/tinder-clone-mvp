-- Swipe Match MVP schema for Supabase.
-- Apply to a new or explicitly approved Supabase project.

create extension if not exists pgcrypto;
create schema if not exists app_private;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 80),
  bio text default '',
  birthdate date,
  city text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.profile_photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  storage_path text not null,
  public_url text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique (user_id, storage_path)
);

create table if not exists public.swipes (
  id uuid primary key default gen_random_uuid(),
  swiper_id uuid not null references public.profiles(id) on delete cascade,
  swiped_id uuid not null references public.profiles(id) on delete cascade,
  decision text not null check (decision in ('like', 'pass')),
  created_at timestamptz not null default now(),
  check (swiper_id <> swiped_id),
  unique (swiper_id, swiped_id)
);

create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  user_a_id uuid not null references public.profiles(id) on delete cascade,
  user_b_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  check (user_a_id < user_b_id),
  unique (user_a_id, user_b_id)
);

create index if not exists profile_photos_user_id_idx on public.profile_photos(user_id, sort_order);
create index if not exists swipes_swiper_id_idx on public.swipes(swiper_id);
create index if not exists swipes_swiped_id_idx on public.swipes(swiped_id);
create index if not exists matches_user_a_id_idx on public.matches(user_a_id);
create index if not exists matches_user_b_id_idx on public.matches(user_b_id);

alter table public.profiles enable row level security;
alter table public.profile_photos enable row level security;
alter table public.swipes enable row level security;
alter table public.matches enable row level security;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create or replace function app_private.has_reciprocal_like(
  first_user_id uuid,
  second_user_id uuid
)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.swipes
    where swiper_id = first_user_id
      and swiped_id = second_user_id
      and decision = 'like'
  )
  and exists (
    select 1
    from public.swipes
    where swiper_id = second_user_id
      and swiped_id = first_user_id
      and decision = 'like'
  );
$$;

revoke all on schema app_private from public;
grant usage on schema app_private to authenticated;
revoke all on function app_private.has_reciprocal_like(uuid, uuid) from public;
grant execute on function app_private.has_reciprocal_like(uuid, uuid) to authenticated;

drop policy if exists "profiles are readable by authenticated users" on public.profiles;
create policy "profiles are readable by authenticated users"
on public.profiles for select
to authenticated
using (true);

drop policy if exists "users insert own profile" on public.profiles;
create policy "users insert own profile"
on public.profiles for insert
to authenticated
with check (id = auth.uid());

drop policy if exists "users update own profile" on public.profiles;
create policy "users update own profile"
on public.profiles for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

drop policy if exists "users delete own profile" on public.profiles;
create policy "users delete own profile"
on public.profiles for delete
to authenticated
using (id = auth.uid());

drop policy if exists "profile photos readable by authenticated users" on public.profile_photos;
create policy "profile photos readable by authenticated users"
on public.profile_photos for select
to authenticated
using (true);

drop policy if exists "users insert own profile photos" on public.profile_photos;
create policy "users insert own profile photos"
on public.profile_photos for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "users update own profile photos" on public.profile_photos;
create policy "users update own profile photos"
on public.profile_photos for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "users delete own profile photos" on public.profile_photos;
create policy "users delete own profile photos"
on public.profile_photos for delete
to authenticated
using (user_id = auth.uid());

drop policy if exists "users read own swipes" on public.swipes;
create policy "users read own swipes"
on public.swipes for select
to authenticated
using (swiper_id = auth.uid());

drop policy if exists "users create own swipes" on public.swipes;
create policy "users create own swipes"
on public.swipes for insert
to authenticated
with check (swiper_id = auth.uid());

drop policy if exists "users update own swipes" on public.swipes;
create policy "users update own swipes"
on public.swipes for update
to authenticated
using (swiper_id = auth.uid())
with check (swiper_id = auth.uid());

drop policy if exists "users read own matches" on public.matches;
create policy "users read own matches"
on public.matches for select
to authenticated
using (user_a_id = auth.uid() or user_b_id = auth.uid());

drop policy if exists "users create reciprocal own matches" on public.matches;
create policy "users create reciprocal own matches"
on public.matches for insert
to authenticated
with check (
  (user_a_id = auth.uid() or user_b_id = auth.uid())
  and app_private.has_reciprocal_like(user_a_id, user_b_id)
);

-- Storage setup:
-- 1. Create a public bucket named profile-photos in Supabase Storage.
-- 2. Store files under {auth.uid()}/{uuid-or-timestamp}.{ext}.
-- 3. Apply the policies below if using the standard storage.objects table.

insert into storage.buckets (id, name, public)
values ('profile-photos', 'profile-photos', true)
on conflict (id) do nothing;

drop policy if exists "profile photos public read" on storage.objects;

drop policy if exists "users upload own profile photos" on storage.objects;
create policy "users upload own profile photos"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "users update own profile photos objects" on storage.objects;
create policy "users update own profile photos objects"
on storage.objects for update
to authenticated
using (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "users delete own profile photos objects" on storage.objects;
create policy "users delete own profile photos objects"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);
