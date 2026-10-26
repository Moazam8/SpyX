# DailyLife — a daily-life app for your phone

One simple offline app with the three things people actually use every day:

- **Tasks** — add tasks, tick them off, see how many are left
- **Habits** — daily check-ins with a streak counter
- **Expenses** — quick spending entries with categories, plus today/month totals

No account. No backend. No ads. No tracking. Everything is stored on your
phone only. Built with Flutter, so the whole thing is free.

## How it gets onto your phone (all free)

1. This code lives in a GitHub repo.
2. Every push to `main` runs the workflow in `.github/workflows/build-apk.yml`,
   which builds a real Android APK in the cloud (GitHub Actions).
3. Download the APK from the run's **Artifacts** section (`dailylife-apk`).
4. On your phone, open the downloaded file and allow "Install unknown apps"
   for your browser when asked. That's it — no Play Store needed, no fee.

## Cost check (verified October 2026)

- Flutter: free, open source
- Android build tools: free
- GitHub repo: free
- GitHub Actions: 2,000 free minutes/month on a private repo, unlimited on a
  public repo. One APK build takes roughly 10–20 minutes.
- Play Store listing: NOT needed (sideloading is free). It would only ever
  cost a one-time $25 if you later decide to publish there.

## Version 1 scope

Single-screen app, three tabs, local storage via `shared_preferences`.
Future ideas (only if wanted): reminders/notifications, weekly summaries,
backup/export, dark mode.
