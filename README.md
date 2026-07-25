# Spotlight Manager

A cross-platform productivity app (mobile + desktop) built with Flutter and Supabase.
Built as a learning project to gain real experience with Flutter, cloud backends,
state management, and professional development workflows.

## Features

### Built
<!-- NEW section — shows real progress, not just plans -->
- Authentication (Email/Password Login & Sign Up, session persistence, logout)
- Theme system (4 accent colors × light/dark, synced per-user via Supabase)
- Responsive navigation shell (sidebar on desktop, bottom nav on mobile)

### Planned
- Daily Routine Tracker
- Goal Tracker
- Shopping List
- Calendar / Scheduler (shared with Routines & Shopping)
- Income & Expense Tracker (Transactions)
- Quick Notes
- Wishlist
- Stats Dashboard (Finance, Health, Stress, Consistency, Work)
- Quick Input System (desktop command panel + mobile quick capture)

## Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Supabase (PostgreSQL, Auth, Storage, Realtime)
- **State Management:** Riverpod
- **Navigation:** GoRouter <!-- NEW -->

## Getting Started

### Prerequisites
- Flutter SDK installed (`flutter doctor` should show no blocking issues)
- A Supabase account and project

### Setup
1. Clone this repo
2. Create a Supabase project, then run the SQL in `supabase/schema.sql` <!-- NEW -->
   (via Supabase Dashboard → SQL Editor) to set up all tables and Row Level Security
3. Create a `.env` file in the project root with:
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_publishable_key
4. Run `flutter pub get`
5. Run `flutter run`

## Project Structure
This project follows a **feature-first** folder structure — see `ARCHITECTURE.md` for details.