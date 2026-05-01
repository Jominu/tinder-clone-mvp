# Swipe Match MVP

Flutter and Supabase MVP for a swipe-based matching app. It uses the core matching UX pattern without copying Tinder branding, assets, copy, or proprietary design.

## MVP Features

- Email/password auth
- Profile setup and editing
- Profile photo upload through Supabase Storage
- Discovery card stack
- Like/pass swipes
- Reciprocal like match creation
- Match list

Deferred: realtime chat, push notifications, paid plans, advanced filters, moderation dashboard, and social login.

## Local Setup

```bash
cd swipe_match_mvp
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
```

Without the Dart defines, the app opens a configuration screen. This keeps tests and local scaffolding usable before a live Supabase project is selected.

## Supabase Setup

1. Create or choose a Supabase project dedicated to this MVP. Requested project name: `tinder-clone-mvp`.
2. Apply `supabase/schema.sql`.
3. Confirm the `profile-photos` bucket exists.
4. Use object paths shaped like `{auth.uid()}/{uuid}.{ext}`.
5. Add the project URL and publishable/anon key to the Flutter run command.

The currently connected Supabase account has existing projects. This repo intentionally does not apply schema changes to those projects without explicit approval.

Applied MVP project:

- Project name: `tinder-clone-mvp`
- Project ref: `hkdsguzbjywieieyijwk`
- Project URL: `https://hkdsguzbjywieieyijwk.supabase.co`
- Migration applied: `create_swipe_match_mvp_schema`
- Security follow-up applied: `fix_swipe_match_security_advisors`

### Protected Projects

Never apply this MVP schema, migrations, storage policies, test data, or exploratory SQL to `minglo-prod`. That project is a separate personal project and is explicitly out of scope for this MVP.

## Architecture

The app uses feature-first MVVM with Riverpod:

```text
lib/
  core/
    errors/
    models/
    supabase/
    theme/
  features/
    auth/
    profile/
    discovery/
    matches/
```

Repositories own Supabase calls. View models coordinate async state. Screens render state and forward user actions.

## Verification

```bash
cd swipe_match_mvp
flutter analyze
flutter test
```

## Notion

The PRD was created under the Notion `Works` page as `Swipe Match MVP PRD`.

## Figma

MVP wireframes were created in the Figma file:

https://www.figma.com/design/6fEBndrAPTkazbXjjrsVSv/tinder-clone-mvp?node-id=0-1&p=f&t=59MDCLa65LulwgWA-0

Frames:

- Auth
- Profile Setup
- Discovery
- Matches

## Requested External Assets

- Supabase project: `tinder-clone-mvp`
- Supabase URL: `https://hkdsguzbjywieieyijwk.supabase.co`
- GitHub repository: `Jominu/tinder-clone-mvp`
- Figma file: `tinder-clone-mvp`
- Figma URL: `https://www.figma.com/design/6fEBndrAPTkazbXjjrsVSv/tinder-clone-mvp?node-id=0-1&p=f&t=59MDCLa65LulwgWA-0`
