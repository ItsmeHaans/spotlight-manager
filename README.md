# Spotlight Manager

A cross-platform productivity app (mobile + desktop) built with Flutter and Supabase.
Built as a learning project to gain real experience with Flutter, cloud backends,
state management, and professional development workflows.

## Features (Planned)
- Daily Routine Tracker
- Goal Tracker
- Shopping List
- Calendar / Scheduler (shared with Routines & Shopping)
- Income & Expense Tracker (Transactions)
- Teaching / Quick Notes
- Wishlist
- Stats Dashboard (Finance, Health, Stress, Consistency, Work)
- Quick Input System (desktop command panel + mobile quick capture)

## Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Supabase (PostgreSQL, Auth, Storage, Realtime)
- **State Management:** Riverpod

## Getting Started

### Prerequisites
- Flutter SDK installed (`flutter doctor` should show no blocking issues)
- A Supabase account and project

### Setup
1. Clone this repo
2. Create a `.env` file in the project root with:
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_publishable_key
3. Run `flutter pub get`
4. Run `flutter run`

## Project Structure
This project follows a **feature-first** folder structure — see `ARCHITECTURE.md` for details.