-- Enable RLS on every table
alter table profiles enable row level security;
alter table routines enable row level security;
alter table routine_logs enable row level security;
alter table goals enable row level security;
alter table shopping_items enable row level security;
alter table calendar_events enable row level security;
alter table transactions enable row level security;
alter table notes enable row level security;
alter table wishlist_items enable row level security;

-- Policies: profiles (special case — id IS the user's own id, not a separate user_id column)
create policy "Users can view own profile" on profiles
  for select using (auth.uid() = id);
create policy "Users can update own profile" on profiles
  for update using (auth.uid() = id);
create policy "Users can insert own profile" on profiles
  for insert with check (auth.uid() = id);

-- Policies: every other table follows the same pattern (user_id = logged-in user)
create policy "Users can view own routines" on routines
  for select using (auth.uid() = user_id);
create policy "Users can insert own routines" on routines
  for insert with check (auth.uid() = user_id);
create policy "Users can update own routines" on routines
  for update using (auth.uid() = user_id);
create policy "Users can delete own routines" on routines
  for delete using (auth.uid() = user_id);

create policy "Users can view own routine_logs" on routine_logs
  for select using (auth.uid() = user_id);
create policy "Users can insert own routine_logs" on routine_logs
  for insert with check (auth.uid() = user_id);
create policy "Users can update own routine_logs" on routine_logs
  for update using (auth.uid() = user_id);
create policy "Users can delete own routine_logs" on routine_logs
  for delete using (auth.uid() = user_id);

create policy "Users can view own goals" on goals
  for select using (auth.uid() = user_id);
create policy "Users can insert own goals" on goals
  for insert with check (auth.uid() = user_id);
create policy "Users can update own goals" on goals
  for update using (auth.uid() = user_id);
create policy "Users can delete own goals" on goals
  for delete using (auth.uid() = user_id);

create policy "Users can view own shopping_items" on shopping_items
  for select using (auth.uid() = user_id);
create policy "Users can insert own shopping_items" on shopping_items
  for insert with check (auth.uid() = user_id);
create policy "Users can update own shopping_items" on shopping_items
  for update using (auth.uid() = user_id);
create policy "Users can delete own shopping_items" on shopping_items
  for delete using (auth.uid() = user_id);

create policy "Users can view own calendar_events" on calendar_events
  for select using (auth.uid() = user_id);
create policy "Users can insert own calendar_events" on calendar_events
  for insert with check (auth.uid() = user_id);
create policy "Users can update own calendar_events" on calendar_events
  for update using (auth.uid() = user_id);
create policy "Users can delete own calendar_events" on calendar_events
  for delete using (auth.uid() = user_id);

create policy "Users can view own transactions" on transactions
  for select using (auth.uid() = user_id);
create policy "Users can insert own transactions" on transactions
  for insert with check (auth.uid() = user_id);
create policy "Users can update own transactions" on transactions
  for update using (auth.uid() = user_id);
create policy "Users can delete own transactions" on transactions
  for delete using (auth.uid() = user_id);

create policy "Users can view own notes" on notes
  for select using (auth.uid() = user_id);
create policy "Users can insert own notes" on notes
  for insert with check (auth.uid() = user_id);
create policy "Users can update own notes" on notes
  for update using (auth.uid() = user_id);
create policy "Users can delete own notes" on notes
  for delete using (auth.uid() = user_id);

create policy "Users can view own wishlist_items" on wishlist_items
  for select using (auth.uid() = user_id);
create policy "Users can insert own wishlist_items" on wishlist_items
  for insert with check (auth.uid() = user_id);
create policy "Users can update own wishlist_items" on wishlist_items
  for update using (auth.uid() = user_id);
create policy "Users can delete own wishlist_items" on wishlist_items
  for delete using (auth.uid() = user_id);