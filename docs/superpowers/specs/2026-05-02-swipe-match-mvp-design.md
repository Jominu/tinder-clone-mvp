# Swipe Match MVP Design

## Objective

Build a Flutter and Supabase based swipe matching app MVP. The app follows a clear MVVM structure and uses the core swipe matching UX pattern without copying Tinder branding, assets, copy, or proprietary design.

## MVP Scope

Included in the first MVP:

- Email/password sign up and sign in
- Profile creation and editing
- One or more profile photos via Supabase Storage
- Discovery card stack
- Like and pass actions
- Match creation when two users like each other
- Match list

Deferred from the first MVP:

- Realtime chat
- Push notifications
- Paid plans
- Advanced filters
- Moderation dashboard
- Social login

## Architecture

The Flutter app uses a feature-first MVVM shape:

- `core/supabase`: Supabase client setup and environment config
- `core/models`: shared domain models
- `core/errors`: user-facing error mapping
- `features/auth`: auth screens, auth view model, auth repository
- `features/profile`: profile editor, profile view model, profile repository
- `features/discovery`: swipe card UI, discovery view model, swipe repository
- `features/matches`: match list UI, match view model, match repository

State management uses Riverpod. View models expose async UI state and call repositories. Repositories own Supabase queries and storage calls. UI widgets stay presentation-focused.

## Supabase Data Model

Tables:

- `profiles`
  - `id uuid primary key references auth.users(id)`
  - `display_name text not null`
  - `bio text`
  - `birthdate date`
  - `city text`
  - `created_at timestamptz not null default now()`
  - `updated_at timestamptz not null default now()`
- `profile_photos`
  - `id uuid primary key default gen_random_uuid()`
  - `user_id uuid not null references profiles(id)`
  - `storage_path text not null`
  - `public_url text not null`
  - `sort_order integer not null default 0`
  - `created_at timestamptz not null default now()`
- `swipes`
  - `id uuid primary key default gen_random_uuid()`
  - `swiper_id uuid not null references profiles(id)`
  - `swiped_id uuid not null references profiles(id)`
  - `decision text not null check (decision in ('like', 'pass'))`
  - `created_at timestamptz not null default now()`
  - unique `(swiper_id, swiped_id)`
- `matches`
  - `id uuid primary key default gen_random_uuid()`
  - `user_a_id uuid not null references profiles(id)`
  - `user_b_id uuid not null references profiles(id)`
  - `created_at timestamptz not null default now()`
  - unique normalized user pair

Storage:

- Bucket: `profile-photos`
- Object path pattern: `{auth.uid()}/{timestamp_or_uuid}.{ext}`

## Access Rules

RLS is enabled on all public tables.

- Users can read public discovery profile data.
- Users can insert/update/delete only their own profile row.
- Users can manage only their own profile photos.
- Users can create swipes where `swiper_id = auth.uid()`.
- Users can read their own swipes.
- Users can read matches where they are `user_a_id` or `user_b_id`.
- Match creation should happen through a controlled repository/RPC path after a reciprocal like is detected.

## UI Flow

1. App launches and checks Supabase auth session.
2. Signed-out users see sign in/sign up.
3. New signed-in users without a complete profile are sent to profile setup.
4. Users with profiles see discovery cards.
5. Like/pass writes a swipe and removes the card.
6. If reciprocal like exists, the app creates a match and can show a lightweight match confirmation.
7. Match list shows matched users and creation dates.

## Screens

- Auth screen
- Profile setup/edit screen
- Discovery screen
- Match list screen

## Testing And Verification

Minimum verification:

- `flutter analyze`
- `flutter test`
- Manual smoke path:
  - sign up/sign in route renders
  - profile setup form renders
  - discovery view renders seeded/mock cards or empty state
  - match list renders loading/empty states

Supabase verification:

- SQL schema is documented in `supabase/schema.sql`
- RLS policies are documented with comments
- Storage bucket and object path rules are documented

## Open Constraints

- A real Supabase project URL and publishable anon key are required for live app execution.
- The existing Supabase project `minglo-prod` is protected and must never be modified for this MVP.
- Figma creation requires an available target file or generated file flow. The MVP can proceed with local Flutter implementation first and add Figma artifacts once a file target is available.
- GitHub publication requires a target repository or permission to create one.

## Requested External Assets

- Supabase project: `tinder-clone-mvp`
- Supabase URL: `https://hkdsguzbjywieieyijwk.supabase.co`
- GitHub repository: `Jominu/tinder-clone-mvp`
- Figma file: `tinder-clone-mvp`
- Figma URL: `https://www.figma.com/design/6fEBndrAPTkazbXjjrsVSv/tinder-clone-mvp?node-id=0-1&p=f&t=59MDCLa65LulwgWA-0`
