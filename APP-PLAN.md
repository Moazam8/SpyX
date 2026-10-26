# DailyLife — build plan

## Decision (2026-10-26, Mr.Moazam's call)

- **Route: Plan B** — a real Android app, not a web app.
- **Stack: Flutter** (free, open source) + GitHub Actions builds the APK (free).
- **Topic: daily-life activities** — deliberately NOT built around his own
  interests. Something usable every single day.
- **Built by: azal** (the user asked azal to make it).

## What V1 does

| Tab | Features |
|---|---|
| Tasks | Add a task, tick it off, delete it, count of open tasks |
| Habits | Add a habit, daily check-in button, streak counter (counts back from today/yesterday) |
| Expenses | Amount + category (Food, Transport, Shopping, Bills, Other) + optional note; totals for today and this month |

## Technical choices (all free, no lock-in)

- Flutter + Dart, Material 3 design.
- Only dependency: `shared_preferences` (on-device storage). No Firebase,
  no server, no account, no paid API.
- CI: `.github/workflows/build-apk.yml` — scaffolds the Android project with
  `flutter create`, copies in `lib/main.dart` + `pubspec.yaml`, builds the
  release APK, uploads it as an artifact.
- Install: download the APK artifact on the phone, allow install from the
  browser once, done. No Play Store, no $25 fee.

## Steps to the phone

1. ✅ App code written (this folder): `lib/main.dart`, `pubspec.yaml`,
   `.github/workflows/build-apk.yml`, `README.md`.
2. ✅ Repo: **Moazam8/SpyX** — public, created by the user himself on
   2026-10-26 (public = unlimited free build minutes).
3. ⏳ Push to GitHub (SpyX, branch `main`). Note: the repo's starter README
   (just "# SpyX") is replaced by the app's README.md in this push.
4. ⏳ GitHub Actions builds the APK automatically on push.
5. ⏳ User downloads the APK artifact and installs it on his phone.
6. ⏳ User tests V1 and says what to change/add next.

## Honest limits

- The APK is signed with the default debug keys by `flutter build apk
  --release` without a signing config. That is fine for personal use on your
  own phone; a Play Store release would need a proper release key later.
- iOS is NOT covered — an iPhone build needs a Mac and an Apple developer
  account. This plan is Android-only.
- No cloud sync: if the phone is lost, the data is lost. Export/backup can
  be a V2 feature if wanted.
