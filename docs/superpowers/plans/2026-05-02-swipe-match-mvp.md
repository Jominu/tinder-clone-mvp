# Swipe Match MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter and Supabase swipe matching MVP with auth, profiles, photo upload, discovery swipes, reciprocal matches, and match list.

**Architecture:** The app uses feature-first MVVM with Riverpod. Views render state from view models, view models coordinate repositories, and repositories own Supabase reads/writes. Supabase schema and RLS live in a documented SQL file for applying to a connected project.

**Tech Stack:** Flutter, Dart, Riverpod, Supabase Flutter, image_picker, GoRouter.

---

## File Structure

- Create `swipe_match_mvp/`: Flutter application root.
- Create `swipe_match_mvp/lib/core/supabase/supabase_config.dart`: Supabase URL/key loading and client access.
- Create `swipe_match_mvp/lib/core/models/app_models.dart`: shared immutable models for profile, photo, discovery card, swipe, and match.
- Create `swipe_match_mvp/lib/core/errors/app_error.dart`: friendly error mapping.
- Create `swipe_match_mvp/lib/features/auth/*`: auth repository, view model, and screen.
- Create `swipe_match_mvp/lib/features/profile/*`: profile repository, view model, and edit screen.
- Create `swipe_match_mvp/lib/features/discovery/*`: discovery repository, view model, and swipe UI.
- Create `swipe_match_mvp/lib/features/matches/*`: match repository, view model, and list screen.
- Modify `swipe_match_mvp/lib/main.dart`: app bootstrap, routing, theme, Supabase initialization.
- Create `supabase/schema.sql`: database, RLS, Storage policy SQL.
- Create `README.md`: local setup and Supabase setup.

## Tasks

### Task 1: Scaffold Flutter App

**Files:**
- Create: `swipe_match_mvp/`
- Modify: `swipe_match_mvp/pubspec.yaml`

- [ ] Run `flutter create swipe_match_mvp`.
- [ ] Add dependencies: `flutter_riverpod`, `supabase_flutter`, `go_router`, `image_picker`, `uuid`.
- [ ] Run `flutter pub get`.

### Task 2: Supabase Schema

**Files:**
- Create: `supabase/schema.sql`

- [x] Confirm the target Supabase project is dedicated to this MVP and is not `minglo-prod`.
- [x] Use the requested Supabase project name `tinder-clone-mvp`.
- [x] Define `profiles`, `profile_photos`, `swipes`, and `matches`.
- [x] Enable RLS on all public tables.
- [x] Add policies for owner writes, discovery reads, swipe creation, and match reads.
- [x] Document `profile-photos` bucket and storage policies.

### Task 3: Core Models And Config

**Files:**
- Create: `swipe_match_mvp/lib/core/models/app_models.dart`
- Create: `swipe_match_mvp/lib/core/errors/app_error.dart`
- Create: `swipe_match_mvp/lib/core/supabase/supabase_config.dart`

- [ ] Add plain Dart model classes with `fromMap` factories.
- [ ] Add friendly error text helper.
- [ ] Add Supabase env config based on `--dart-define`.

### Task 4: Auth

**Files:**
- Create: `swipe_match_mvp/lib/features/auth/auth_repository.dart`
- Create: `swipe_match_mvp/lib/features/auth/auth_view_model.dart`
- Create: `swipe_match_mvp/lib/features/auth/auth_screen.dart`

- [ ] Implement sign in, sign up, sign out.
- [ ] Expose auth session state through Riverpod.
- [ ] Build a combined sign in/sign up screen.

### Task 5: Profile

**Files:**
- Create: `swipe_match_mvp/lib/features/profile/profile_repository.dart`
- Create: `swipe_match_mvp/lib/features/profile/profile_view_model.dart`
- Create: `swipe_match_mvp/lib/features/profile/profile_screen.dart`

- [ ] Load current user's profile.
- [ ] Upsert profile fields.
- [ ] Upload a selected image to `profile-photos`.
- [ ] Save image metadata in `profile_photos`.

### Task 6: Discovery

**Files:**
- Create: `swipe_match_mvp/lib/features/discovery/discovery_repository.dart`
- Create: `swipe_match_mvp/lib/features/discovery/discovery_view_model.dart`
- Create: `swipe_match_mvp/lib/features/discovery/discovery_screen.dart`

- [ ] Fetch candidate profiles excluding self and already-swiped users.
- [ ] Render a swipe card stack.
- [ ] Implement like/pass.
- [ ] Create a match after reciprocal like.

### Task 7: Matches

**Files:**
- Create: `swipe_match_mvp/lib/features/matches/matches_repository.dart`
- Create: `swipe_match_mvp/lib/features/matches/matches_view_model.dart`
- Create: `swipe_match_mvp/lib/features/matches/matches_screen.dart`

- [ ] Fetch matches containing current user.
- [ ] Resolve the other user's profile and photo.
- [ ] Render loading, empty, and populated states.

### Task 8: App Shell And Verification

**Files:**
- Modify: `swipe_match_mvp/lib/main.dart`
- Create: `README.md`
- Modify: `swipe_match_mvp/test/widget_test.dart`

- [ ] Wire routes for auth, profile, discovery, and matches.
- [ ] Add setup docs and run commands.
- [ ] Add smoke widget tests for app shell rendering.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.

### Task 9: External MCP Assets

**Targets:**
- Supabase project: `tinder-clone-mvp`
- Supabase URL: `https://hkdsguzbjywieieyijwk.supabase.co`
- GitHub repository: `Jominu/tinder-clone-mvp`
- Figma file: `tinder-clone-mvp`
- Figma URL: `https://www.figma.com/design/6fEBndrAPTkazbXjjrsVSv/tinder-clone-mvp?node-id=0-1&p=f&t=59MDCLa65LulwgWA-0`

- [x] Create or select the dedicated Supabase project, excluding `minglo-prod`.
- [x] Apply `supabase/schema.sql` only to the dedicated project.
- [x] Publish the local Git commit to the requested GitHub repository.
- [x] Create a Figma design file with Auth, Profile, Discovery, and Matches wireframes.

## Self-Review

- Spec coverage: all approved MVP features are mapped to tasks.
- Scope: realtime chat and advanced features are explicitly deferred.
- Placeholders: no task depends on an unspecified future feature.
- Verification: analyze, tests, README, and schema SQL are required before completion.
