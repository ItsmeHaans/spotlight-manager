-- Profiles: fuller personal info
alter table profiles add column full_name text;
alter table profiles add column date_of_birth date;
alter table profiles add column gender text;
alter table profiles add column location text;
alter table profiles add column bio text;

-- Shopping: urgency
alter table shopping_items add column urgency text default 'normal';

-- Notes: optional date + (confirm tags is your filter mechanism, no category added)
alter table notes add column note_date date;

-- Wishlist: price
alter table wishlist_items add column price numeric;