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

## Week 2 — Design System & Onboarding Flow

### Design System
- Defined color palette: 4 accent themes (Yellow, Blue, Silver, Pink Rose), each with light and dark mode variants (8 total combinations via `AppThemeName` enum)
- Sidebar color stays fixed regardless of light/dark mode; only main content area (background/surface/text) flips
- Chose Inter (via google_fonts) for typography, with a defined type scale (heading1, heading2, body, caption)
- Defined a 4px-based spacing scale (xs–xxl)
- Decided against glassmorphism/claymorphism in favor of minimalism — better fit for a solo dev shipping 10 CRUD-heavy features on a fixed timeline; blur effects deferred as a possible later accent (e.g. Quick Input panel only), not the whole app
- App icon and splash screen deferred to Week 7 Polish — placeholder only for now

### Schema additions (driven by wireframing feature pages)
- `profiles`: added full_name, date_of_birth, gender, location, bio, theme_preference
- `shopping_items`: added urgency
- `notes`: added optional note_date (links notes to specific calendar days)
- `wishlist_items`: added price
- Decided routine streaks are calculated from `routine_logs` at query time, not stored as a column (avoids stale/derived-data bugs)
- Decided Transactions has no summary table — all totals/graphs computed live via aggregate queries

### Navigation & Layout
- Desktop: labeled sidebar (not icon-only) — necessary given 10+ features, where icon-only nav breaks down past ~8 items
- Desktop dashboard: top row of Stats KPI cards + grid of feature shortcut cards below, inspired by data-dashboard patterns (SkyTrack) rather than smart-home hero-image patterns (better fit for many small data points vs. few rich visual devices)
- Mobile: minimal bottom nav (Home, Quick Input, Settings/Profile) rather than one icon per feature; all 10 features are reached via cards on the Home screen instead

### Onboarding Flow (wireframed)
- Flow: Splash → Login/Signup → Theme Picker → Profile Form (mandatory) → Dashboard
- Theme picked before profile form so the form itself renders in the user's chosen theme
- Profile form (DOB, gender, location, bio) is mandatory at signup — accepted tradeoff of added signup friction, since no other feature currently depends on this data