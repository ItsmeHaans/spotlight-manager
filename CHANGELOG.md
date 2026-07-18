# Changelog

All notable decisions and milestones for Spotlight Manager.

## Week 1 — Foundation

### Planning
- Defined initial screen list for all features
- Chose feature-first folder structure over layer-first, for better scalability across 10+ features
- Chose Riverpod for state management over Provider/BLoC
- Removed Contacts/CRM and standalone Finance features
- Merged Income + Expense into a single Transactions feature
- Redesigned Finance Dashboard into a broader Stats Dashboard (Finance, Health, Stress, Consistency, Work)
- Added a separate Quick Input System (desktop command panel + mobile quick capture), decoupled from the main Dashboard

### Environment
- Installed Flutter SDK, Android toolchain, VS Code + Flutter/Dart plugins
- Initialized Git repo, connected to GitHub
- Created Flutter project (`spotlight_manager`, org: com.BuildWithHans)

### Database
- Designed full schema across 9 tables + profiles table
- Added `routine_logs` table to support daily history tracking (checklist or counter-based routines)
- Enabled Row Level Security on all tables with per-user policies
- Verified RLS blocks unauthenticated access correctly

### Backend
- Enabled Email/Password auth in Supabase (email confirmation off during development)
- Stored Supabase keys in `.env`, excluded from Git via `.gitignore`
- Connected Flutter app to Supabase, verified live query + RLS enforcement end-to-end