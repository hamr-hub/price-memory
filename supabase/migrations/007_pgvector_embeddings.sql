-- Enable pgvector extension for vector similarity search
create extension if not exists vector;

-- Embeddings table: store text and image embeddings per product
create table if not exists public.product_embeddings (
  product_id bigint primary key references public.products(id) on delete cascade,
  embedding_text vector(1024),
  embedding_image vector(1024),
  updated_at timestamptz default now() not null
);

alter table public.product_embeddings enable row level security;
create policy "product_embeddings_select_all" on public.product_embeddings for select to authenticated using (true);

-- IVFFlat indexes for efficient ANN search
create index if not exists idx_product_embeddings_text_ivf on public.product_embeddings using ivfflat (embedding_text vector_cosine_ops) with (lists = 100);
create index if not exists idx_product_embeddings_image_ivf on public.product_embeddings using ivfflat (embedding_image vector_cosine_ops) with (lists = 100);

-- RPC: search products by embedding (text or image)
create or replace function public.rpc_ai_search_products(q float4[], top_k int default 20, use_image boolean default false)
returns table(product_id bigint, score float4) as $$
  select pe.product_id,
         (case when use_image then pe.embedding_image else pe.embedding_text end) <-> q::vector as score
  from public.product_embeddings pe
  where (case when use_image then pe.embedding_image is not null else pe.embedding_text is not null end)
  order by score asc
  limit top_k;
$$ language sql stable;

-- RPC: search with category filter and return basic product fields
create or replace function public.rpc_ai_search_products_with_info(q float4[], top_k int default 20, use_image boolean default false, category text default null)
returns table(product_id bigint, name text, url text, category text, score float4) as $$
  select p.id as product_id,
         p.name,
         p.url,
         p.category,
         (case when use_image then pe.embedding_image else pe.embedding_text end) <-> q::vector as score
  from public.product_embeddings pe
  join public.products p on p.id = pe.product_id
  where (case when use_image then pe.embedding_image is not null else pe.embedding_text is not null end)
    and (category is null or p.category = category)
  order by score asc
  limit top_k;
$$ language sql stable;

