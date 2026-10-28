-- Households, and which users belong to each one
create table households (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table household_members (
  household_id uuid not null references households (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  primary key (household_id, user_id)
);

-- Subscriptions
create table subscriptions (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households (id) on delete cascade,
  name text not null,
  provider text,
  amount numeric(10, 2) not null,
  billing_rhythm text not null check (billing_rhythm in ('monthly', 'quarterly', 'yearly')),
  owner_user_id uuid references auth.users (id) on delete set null, -- empty means the household owns it
  payment_method text check (payment_method in ('direct_debit', 'card', 'invoice', 'cash')),
  contract_start date,
  term_end date,
  notice_period text,
  auto_renews boolean not null default false,
  status text not null default 'active' check (status in ('active', 'cancelled', 'ended')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Installments
create table installments (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households (id) on delete cascade,
  item text not null,
  total_price numeric(10, 2) not null,
  installment_amount numeric(10, 2) not null,
  number_of_installments integer not null check (number_of_installments > 0),
  first_installment_date date not null,
  lender text,
  owner_user_id uuid references auth.users (id) on delete set null,
  status text not null default 'active' check (status in ('active', 'ended')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Invoices
create table invoices (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households (id) on delete cascade,
  item text not null,
  amount numeric(10, 2) not null,
  purchase_date date,
  due_date date,
  owner_user_id uuid references auth.users (id) on delete set null,
  invoice_number text,
  status text not null default 'open' check (status in ('open', 'paid')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Turn on row-level security: without these rules, no one can see anything
alter table households enable row level security;
alter table household_members enable row level security;
alter table subscriptions enable row level security;
alter table installments enable row level security;
alter table invoices enable row level security;

-- Users can see the households they belong to
create policy "see own memberships" on household_members
  for select to authenticated
  using (user_id = auth.uid());

create policy "see own households" on households
  for select to authenticated
  using (id in (select household_id from household_members where user_id = auth.uid()));

-- Members can read, add, change and delete entries in their own household only
create policy "household members manage subscriptions" on subscriptions
  for all to authenticated
  using (household_id in (select household_id from household_members where user_id = auth.uid()))
  with check (household_id in (select household_id from household_members where user_id = auth.uid()));

create policy "household members manage installments" on installments
  for all to authenticated
  using (household_id in (select household_id from household_members where user_id = auth.uid()))
  with check (household_id in (select household_id from household_members where user_id = auth.uid()));

create policy "household members manage invoices" on invoices
  for all to authenticated
  using (household_id in (select household_id from household_members where user_id = auth.uid()))
  with check (household_id in (select household_id from household_members where user_id = auth.uid()));
