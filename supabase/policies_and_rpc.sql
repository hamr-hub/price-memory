-- Users: add auth_uid binding and RLS policies
alter table public.users add column if not exists auth_uid uuid unique;
alter table public.users enable row level security;
create policy users_select_self on public.users for select using (auth_uid = auth.uid());
create policy users_insert_self on public.users for insert with check (auth_uid = auth.uid());
create policy users_update_self on public.users for update using (auth_uid = auth.uid()) with check (auth_uid = auth.uid());

-- Follows: user can only CRUD their own rows
alter table public.user_follows enable row level security;
create policy follows_select_self on public.user_follows for select using (exists (select 1 from public.users u where u.id = user_follows.user_id and u.auth_uid = auth.uid()));
create policy follows_insert_self on public.user_follows for insert with check (exists (select 1 from public.users u where u.id = user_follows.user_id and u.auth_uid = auth.uid()));
create policy follows_delete_self on public.user_follows for delete using (exists (select 1 from public.users u where u.id = user_follows.user_id and u.auth_uid = auth.uid()));

-- Pushes: sender or recipient can read; recipient can update status
alter table public.pushes enable row level security;
create policy pushes_select_sender_recipient on public.pushes for select using (
  exists (select 1 from public.users u where u.id = pushes.sender_id and u.auth_uid = auth.uid())
  or exists (select 1 from public.users u2 where u2.id = pushes.recipient_id and u2.auth_uid = auth.uid())
);
create policy pushes_update_recipient on public.pushes for update using (
  exists (select 1 from public.users u2 where u2.id = pushes.recipient_id and u2.auth_uid = auth.uid())
) with check (
  exists (select 1 from public.users u2 where u2.id = pushes.recipient_id and u2.auth_uid = auth.uid())
);
create policy pushes_insert_sender on public.pushes for insert with check (
  exists (select 1 from public.users u where u.id = pushes.sender_id and u.auth_uid = auth.uid())
);

-- Optional: Prices are public read
alter table public.prices enable row level security;
create policy prices_public_read on public.prices for select using (true);

-- RPC: product price stats aggregation
create or replace function public.product_price_stats(p_product_id int)
returns table (min_price numeric, max_price numeric, avg_price numeric, count int)
language sql stable as $$
  select min(price), max(price), avg(price), count(*) from public.prices where product_id = p_product_id;
$$;

create or replace view public.v_product_prices_export as
select p.id as product_id, p.name as product_name, p.url, p.category, pr.id as price_id, pr.price, pr.created_at
from public.products p
join public.prices pr on pr.product_id = p.id;

-- Collections and membership
create table if not exists public.collections (
  id serial primary key,
  name text not null,
  owner_user_id int not null references public.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.collections add column if not exists description text;
alter table public.collections add column if not exists visibility text not null default 'private';
create table if not exists public.collection_members (
  id serial primary key,
  collection_id int not null references public.collections(id) on delete cascade,
  user_id int not null references public.users(id) on delete cascade,
  role text,
  unique(collection_id, user_id)
);
create table if not exists public.collection_products (
  id serial primary key,
  collection_id int not null references public.collections(id) on delete cascade,
  product_id int not null references public.products(id) on delete cascade,
  unique(collection_id, product_id)
);

alter table public.collections enable row level security;
alter table public.collection_members enable row level security;
alter table public.collection_products enable row level security;

-- Owner or member can read collection
create policy collections_select_owner_member on public.collections for select using (
  exists (select 1 from public.users u where u.id = collections.owner_user_id and u.auth_uid = auth.uid())
  or exists (select 1 from public.collection_members cm join public.users u2 on cm.user_id = u2.id where cm.collection_id = collections.id and u2.auth_uid = auth.uid())
);
create policy collections_select_public on public.collections for select using (
  visibility = 'public'
);
-- Only owner can insert/update/delete collections
create policy collections_insert_owner on public.collections for insert with check (
  exists (select 1 from public.users u where u.id = collections.owner_user_id and u.auth_uid = auth.uid())
);
create policy collections_update_owner on public.collections for update using (
  exists (select 1 from public.users u where u.id = collections.owner_user_id and u.auth_uid = auth.uid())
) with check (
  exists (select 1 from public.users u where u.id = collections.owner_user_id and u.auth_uid = auth.uid())
);
create policy collections_delete_owner on public.collections for delete using (
  exists (select 1 from public.users u where u.id = collections.owner_user_id and u.auth_uid = auth.uid())
);

-- Members: owner can manage, members can read
create policy collection_members_select_owner_member on public.collection_members for select using (
  exists (select 1 from public.collections c join public.users u1 on c.owner_user_id = u1.id where c.id = collection_members.collection_id and u1.auth_uid = auth.uid())
  or exists (select 1 from public.users u2 where u2.id = collection_members.user_id and u2.auth_uid = auth.uid())
);
create policy collection_members_insert_owner on public.collection_members for insert with check (
  exists (select 1 from public.collections c join public.users u1 on c.owner_user_id = u1.id where c.id = collection_members.collection_id and u1.auth_uid = auth.uid())
);
create policy collection_members_update_owner on public.collection_members for update using (
  exists (select 1 from public.collections c join public.users u1 on c.owner_user_id = u1.id where c.id = collection_members.collection_id and u1.auth_uid = auth.uid())
) with check (
  exists (select 1 from public.collections c join public.users u1 on c.owner_user_id = u1.id where c.id = collection_members.collection_id and u1.auth_uid = auth.uid())
);
create policy collection_members_delete_owner on public.collection_members for delete using (
  exists (select 1 from public.collections c join public.users u1 on c.owner_user_id = u1.id where c.id = collection_members.collection_id and u1.auth_uid = auth.uid())
);

-- Collection products: members read, owner manage
create policy collection_products_select_member on public.collection_products for select using (
  exists (select 1 from public.collection_members cm join public.users u on cm.user_id = u.id where cm.collection_id = collection_products.collection_id and u.auth_uid = auth.uid())
  or exists (select 1 from public.collections c join public.users u1 on c.owner_user_id = u1.id where c.id = collection_products.collection_id and u1.auth_uid = auth.uid())
);
create policy collection_products_insert_owner on public.collection_products for insert with check (
  exists (select 1 from public.collections c join public.users u1 on c.owner_user_id = u1.id where c.id = collection_products.collection_id and u1.auth_uid = auth.uid())
);
create policy collection_products_delete_owner on public.collection_products for delete using (
  exists (select 1 from public.collections c join public.users u1 on c.owner_user_id = u1.id where c.id = collection_products.collection_id and u1.auth_uid = auth.uid())
);

-- Alerts
create table if not exists public.alerts (
  id serial primary key,
  user_id int not null references public.users(id) on delete cascade,
  product_id int not null references public.products(id) on delete cascade,
  rule_type text not null,
  threshold numeric,
  status text default 'active',
  created_at timestamptz not null default now()
);
alter table public.alerts enable row level security;
create policy alerts_select_self on public.alerts for select using (
  exists (select 1 from public.users u where u.id = alerts.user_id and u.auth_uid = auth.uid())
);
create policy alerts_insert_self on public.alerts for insert with check (
  exists (select 1 from public.users u where u.id = alerts.user_id and u.auth_uid = auth.uid())
);
create policy alerts_update_self on public.alerts for update using (
  exists (select 1 from public.users u where u.id = alerts.user_id and u.auth_uid = auth.uid())
) with check (
  exists (select 1 from public.users u where u.id = alerts.user_id and u.auth_uid = auth.uid())
);
create policy alerts_delete_self on public.alerts for delete using (
  exists (select 1 from public.users u where u.id = alerts.user_id and u.auth_uid = auth.uid())
);

alter table public.products add column if not exists image_url text;

create or replace function public.collection_export_csv(p_collection_id int)
returns text
language sql stable as $$
  with rows as (
    select p.id as product_id, p.name as product_name, p.url, p.category
    from public.collection_products cp join public.products p on cp.product_id = p.id
    where cp.collection_id = p_collection_id
  )
  select 'product_id,product_name,url,category' || chr(10) || string_agg(
    product_id::text || ',' || replace(product_name, ',', ' ') || ',' || coalesce(url,'') || ',' || coalesce(category,''),
    chr(10)
  ) from rows;
$$;
