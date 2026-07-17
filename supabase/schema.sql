-- Profiles: extra info about each user, linked to Supabase Auth
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  created_at timestamp with time zone default now()
);

-- Routines: the definition of a habit/routine
create table routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  tracking_type text not null default 'checklist', -- 'checklist' or 'counter'
  target_count integer,
  frequency text,
  time time,
  is_active boolean default true,
  created_at timestamp with time zone default now()
);

-- Routine logs: daily completion record per routine
create table routine_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  routine_id uuid references routines(id) on delete cascade not null,
  date date not null,
  value integer not null default 0,
  created_at timestamp with time zone default now()
);

-- Goals
create table goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  description text,
  target_date date,
  progress numeric default 0,
  status text default 'not_started',
  image_url text,
  created_at timestamp with time zone default now()
);

-- Shopping items
create table shopping_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  category text,
  quantity numeric default 1,
  is_checked boolean default false,
  created_at timestamp with time zone default now()
);

-- Calendar events
create table calendar_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  description text,
  start_time timestamp with time zone not null,
  end_time timestamp with time zone,
  is_all_day boolean default false,
  source_feature text, -- e.g. 'routine', 'shopping', or null if manually created
  source_id uuid,
  created_at timestamp with time zone default now()
);

-- Transactions (income + expense)
create table transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  amount numeric not null,
  type text not null, -- 'income' or 'expense'
  source text,
  category text,
  date date not null default current_date,
  note text,
  image_url text,
  created_at timestamp with time zone default now()
);

-- Notes
create table notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  content text,
  tags text[],
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Wishlist items
create table wishlist_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  description text,
  url text,
  priority text default 'medium', -- or numeric, your call
  status text default 'not_started', -- 'not_started', 'in_progress', 'achieved'
  image_url text,
  created_at timestamp with time zone default now()
);