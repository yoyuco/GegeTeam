-- ========================= EXTENSIONS =========================
create extension if not exists "pgcrypto";

-- ========================= TABLES =============================
create table if not exists organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  owner uuid references auth.users(id),
  created_at timestamptz default now()
);

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  org_id uuid references organizations(id) on delete set null,
  full_name text,
  avatar_url text,
  created_at timestamptz default now()
);

create table if not exists user_roles (
  user_id uuid references auth.users(id) on delete cascade,
  org_id uuid references organizations(id) on delete cascade,
  role text check (role in ('admin','manager','staff','viewer')) not null default 'staff',
  primary key (user_id, org_id)
);

create table products (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  sku text unique,
  price numeric(14,2) not null default 0,
  created_at timestamptz default now()
);

create table customers (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  name text not null,
  email text,
  phone text,
  created_at timestamptz default now(),
  created_by uuid references auth.users(id)
);

create table orders (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  code text generated always as (left(replace(id::text,'-',''),8)) stored,
  customer_id uuid references customers(id),
  total_amount numeric(14,2) not null default 0,
  status text check (status in ('pending','paid','fulfilled','cancelled')) not null default 'pending',
  created_at timestamptz default now(),
  created_by uuid references auth.users(id)
);

create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  product_id uuid references products(id),
  quantity int not null default 1,
  unit_price numeric(14,2) not null default 0
);

create table tasks (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  title text not null,
  status text check (status in ('backlog','todo','in_progress','review','done')) not null default 'backlog',
  assignee uuid references auth.users(id),
  priority text check (priority in ('low','medium','high','urgent')) default 'medium',
  due_date date,
  position int not null default 0,
  created_at timestamptz default now(),
  created_by uuid references auth.users(id)
);

create table kpi_metrics (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references organizations(id) on delete cascade,
  key text not null,
  name text not null,
  unit text default 'VND',
  unique (org_id, key)
);

create table kpi_values (
  id uuid primary key default gen_random_uuid(),
  metric_id uuid not null references kpi_metrics(id) on delete cascade,
  ts date not null,
  value numeric(16,4) not null default 0,
  unique (metric_id, ts)
);

-- ========================= VIEWS =============================
create or replace view employees_v as
  select ur.org_id, p.id, p.full_name, ur.role
  from user_roles ur join profiles p on p.id = ur.user_id;

create or replace view orders_v as
  select o.*, c.name as customer_name
  from orders o left join customers c on c.id = o.customer_id;

create or replace view monthly_revenue_v as
  select to_char(date_trunc('month', o.created_at), 'YYYY-MM') as month,
         sum(o.total_amount) as revenue
  from orders o
  group by 1 order by 1;

-- ========================= FUNCTIONS =========================
create or replace function dashboard_kpis()
returns json language plpgsql security definer as $$
declare r record;
begin
  select 
    (select count(*) from orders where created_at >= date_trunc('month', now())) as orders_count,
    (select count(*) from customers where created_at >= date_trunc('month', now())) as new_customers
  into r;
  return json_build_object('orders_count', r.orders_count, 'new_customers', r.new_customers);
end; $$;

create or replace function is_org_member(org uuid)
returns boolean language sql stable as $$
  select exists(select 1 from user_roles where org_id = org and user_id = auth.uid())
$$;

create or replace function is_org_admin(org uuid)
returns boolean language sql stable as $$
  select exists(select 1 from user_roles where org_id = org and user_id = auth.uid() and role = 'admin')
$$;

-- ========================= RLS ===============================
alter table organizations enable row level security;
alter table profiles enable row level security;
alter table user_roles enable row level security;
alter table products enable row level security;
alter table customers enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;
alter table tasks enable row level security;
alter table kpi_metrics enable row level security;
alter table kpi_values enable row level security;

-- Organizations
create policy "orgs admin can all" on organizations
  for all using (owner = auth.uid()) with check (owner = auth.uid());

-- Profiles
create policy "profiles self read" on profiles
  for select using (id = auth.uid());
create policy "profiles self write" on profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

-- user_roles (quản trị membership)
create policy "user_roles: self or admin select" on user_roles
  for select using (user_id = auth.uid() or is_org_admin(org_id));
create policy "user_roles: admin insert" on user_roles
  for insert with check (is_org_admin(org_id));
create policy "user_roles: admin update" on user_roles
  for update using (is_org_admin(org_id)) with check (is_org_admin(org_id));
create policy "user_roles: admin delete" on user_roles
  for delete using (is_org_admin(org_id));

-- Các bảng có org_id
create policy "member select on products"   on products   for select using (is_org_member(org_id));
create policy "member insert on products"   on products   for insert with check (is_org_member(org_id));
create policy "member update on products"   on products   for update using (is_org_member(org_id)) with check (is_org_member(org_id));
create policy "admin delete on products"    on products   for delete using (is_org_admin(org_id));

create policy "member select on customers"  on customers  for select using (is_org_member(org_id));
create policy "member insert on customers"  on customers  for insert with check (is_org_member(org_id));
create policy "member update on customers"  on customers  for update using (is_org_member(org_id)) with check (is_org_member(org_id));
create policy "admin delete on customers"   on customers  for delete using (is_org_admin(org_id));

create policy "member select on orders"     on orders     for select using (is_org_member(org_id));
create policy "member insert on orders"     on orders     for insert with check (is_org_member(org_id));
create policy "member update on orders"     on orders     for update using (is_org_member(org_id)) with check (is_org_member(org_id));
create policy "admin delete on orders"      on orders     for delete using (is_org_admin(org_id));

create policy "member select on tasks"      on tasks      for select using (is_org_member(org_id));
create policy "member insert on tasks"      on tasks      for insert with check (is_org_member(org_id));
create policy "member update on tasks"      on tasks      for update using (is_org_member(org_id)) with check (is_org_member(org_id));
create policy "admin delete on tasks"       on tasks      for delete using (is_org_admin(org_id));

create policy "member select on kpi_metrics" on kpi_metrics for select using (is_org_member(org_id));
create policy "member insert on kpi_metrics" on kpi_metrics for insert with check (is_org_member(org_id));
create policy "member update on kpi_metrics" on kpi_metrics for update using (is_org_member(org_id)) with check (is_org_member(org_id));
create policy "admin delete on kpi_metrics"  on kpi_metrics for delete using (is_org_admin(org_id));

-- order_items: suy org từ orders(order_id)
create policy "member select on order_items" on order_items
  for select using (exists (select 1 from orders o where o.id = order_items.order_id and is_org_member(o.org_id)));
create policy "member insert on order_items" on order_items
  for insert with check (exists (select 1 from orders o where o.id = order_items.order_id and is_org_member(o.org_id)));
create policy "member update on order_items" on order_items
  for update using (exists (select 1 from orders o where o.id = order_items.order_id and is_org_member(o.org_id)))
  with check (exists (select 1 from orders o where o.id = order_items.order_id and is_org_member(o.org_id)));
create policy "admin delete on order_items" on order_items
  for delete using (exists (select 1 from orders o where o.id = order_items.order_id and is_org_admin(o.org_id)));

-- kpi_values: suy org từ kpi_metrics(metric_id)
create policy "member select on kpi_values" on kpi_values
  for select using (exists (select 1 from kpi_metrics m where m.id = kpi_values.metric_id and is_org_member(m.org_id)));
create policy "member insert on kpi_values" on kpi_values
  for insert with check (exists (select 1 from kpi_metrics m where m.id = kpi_values.metric_id and is_org_member(m.org_id)));
create policy "member update on kpi_values" on kpi_values
  for update using (exists (select 1 from kpi_metrics m where m.id = kpi_values.metric_id and is_org_member(m.org_id)))
  with check (exists (select 1 from kpi_metrics m where m.id = kpi_values.metric_id and is_org_member(m.org_id)));
create policy "admin delete on kpi_values" on kpi_values
  for delete using (exists (select 1 from kpi_metrics m where m.id = kpi_values.metric_id and is_org_admin(m.org_id)));

-- ========================= STORAGE (SAFE) ====================
DO $$
BEGIN
  -- Tạo bucket: dùng function nếu có, nếu không thì insert trực tiếp
  IF EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'storage' AND p.proname = 'create_bucket'
  ) THEN
    PERFORM storage.create_bucket('public', TRUE);
    PERFORM storage.create_bucket('private', FALSE);
  ELSIF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema='storage' AND table_name='buckets'
  ) THEN
    INSERT INTO storage.buckets(id, name, public)
      VALUES ('public','public', TRUE)  ON CONFLICT (id) DO NOTHING;
    INSERT INTO storage.buckets(id, name, public)
      VALUES ('private','private', FALSE) ON CONFLICT (id) DO NOTHING;
  END IF;

  -- Policies cho storage.objects (chỉ khi bảng tồn tại)
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema='storage' AND table_name='objects'
  ) THEN
    BEGIN
      CREATE POLICY "public can read public bucket" on storage.objects
        for select using (bucket_id = 'public');
    EXCEPTION WHEN duplicate_object THEN NULL; END;

    BEGIN
      CREATE POLICY "auth can insert public/private" on storage.objects
        for insert to authenticated with check (bucket_id in ('public','private'));
    EXCEPTION WHEN duplicate_object THEN NULL; END;

    BEGIN
      CREATE POLICY "owner can update/delete" on storage.objects
        for all to authenticated using (owner = auth.uid());
    EXCEPTION WHEN duplicate_object THEN NULL; END;
  END IF;
END $$;

-- ========================= VIEW SECURITY =====================
alter view employees_v set (security_invoker = on);
alter view orders_v set (security_invoker = on);
alter view monthly_revenue_v set (security_invoker = on);
