-- =========================================================
-- INITIAL DATABASE SETUP FOR n8n_ig SCHEMA
-- All-in-one migration: schema, tables, indexes, permissions
-- =========================================================

-- ==========================================
-- Create schema
-- ==========================================
create schema if not exists n8n_ig;


-- ==========================================
-- Helper: updated_at trigger
-- ==========================================
create or replace function n8n_ig.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;


-- ==========================================
-- USERS
-- ==========================================
create table if not exists n8n_ig.users (
  id                  bigserial primary key,
  username            text not null unique,
  full_name           text,
  profile_pic_url     text,
  posts_count         int,
  followers_count     bigint,
  follows_count       bigint,
  is_private          boolean,
  is_verified         boolean,
  is_business_account boolean,
  biography           text,

  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create trigger users_set_updated_at
before update on n8n_ig.users
for each row execute function n8n_ig.set_updated_at();


-- ==========================================
-- POSTS
-- ==========================================
create table if not exists n8n_ig.posts (
  id                   bigserial primary key,
  instagram_id         text unique not null,
  type                 text not null check (type in ('Image','Video','Sidecar')),
  short_code           text,
  caption              text,
  hashtags             text[] not null default '{}',
  mentions             text[] not null default '{}',
  url                  text,
  comments_count       int,
  first_comment        text,
  dimensions_height    int,
  dimensions_width     int,
  display_url          text,
  images               text[] not null default '{}',
  alt                  text,
  likes_count          int,
  posted_at            timestamptz,
  location_name        text,
  location_id          text,

  owner_username       text,
  owner_instagram_id   text,
  owner_full_name      text,
  owner_user_id        bigint references n8n_ig.users(id) on delete set null,

  is_comments_disabled boolean not null default false,
  input_url            text,
  is_sponsored         boolean not null default false,

  -- Video fields
  video_url            text,
  video_view_count     bigint,
  video_play_count     bigint,
  video_duration       numeric,

  -- Audio and music
  audio_url            text,
  music_info           jsonb,

  -- Product and pin status
  product_type         text,
  is_pinned            boolean not null default false,

  -- Raw JSON storage
  raw                  jsonb,

  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now()
);

create index if not exists posts_owner_user_id_idx on n8n_ig.posts(owner_user_id);
create index if not exists posts_posted_at_idx on n8n_ig.posts(posted_at);
create index if not exists posts_product_type_idx on n8n_ig.posts(product_type);
create index if not exists posts_is_pinned_idx on n8n_ig.posts(is_pinned) where is_pinned = true;

create trigger posts_set_updated_at
before update on n8n_ig.posts
for each row execute function n8n_ig.set_updated_at();


-- ==========================================
-- COMMENTS
-- ==========================================
create table if not exists n8n_ig.comments (
  id                     bigserial primary key,
  instagram_id           text unique,
  post_id                bigint not null references n8n_ig.posts(id) on delete cascade,

  text                   text,
  owner_username         text,
  owner_instagram_id     text,
  owner_profile_pic_url  text,

  likes_count            int,
  commented_at           timestamptz,
  replies_count          int,

  -- Raw JSON storage
  raw                    jsonb,
  owner_raw              jsonb,

  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

create index if not exists comments_post_id_idx on n8n_ig.comments(post_id);

create trigger comments_set_updated_at
before update on n8n_ig.comments
for each row execute function n8n_ig.set_updated_at();


-- latest comments mapping
create table if not exists n8n_ig.post_latest_comments (
  post_id     bigint not null references n8n_ig.posts(id) on delete cascade,
  comment_id  bigint not null references n8n_ig.comments(id) on delete cascade,
  position    int not null,
  primary key (post_id, comment_id)
);

create index if not exists plc_post_id_pos_idx on n8n_ig.post_latest_comments(post_id, position);


-- ==========================================
-- TAGGED USERS
-- ==========================================
create table if not exists n8n_ig.tagged_users (
  id                bigserial primary key,
  instagram_id      text unique,
  username          text not null,
  full_name         text,
  profile_pic_url   text,
  is_verified       boolean,

  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create trigger tagged_users_set_updated_at
before update on n8n_ig.tagged_users
for each row execute function n8n_ig.set_updated_at();


-- link posts <-> tagged_users (many-to-many)
create table if not exists n8n_ig.post_tagged_users (
  post_id        bigint not null references n8n_ig.posts(id) on delete cascade,
  tagged_user_id bigint not null references n8n_ig.tagged_users(id) on delete cascade,
  primary key (post_id, tagged_user_id)
);

create index if not exists ptu_post_id_idx on n8n_ig.post_tagged_users(post_id);


-- ==========================================
-- COAUTHOR PRODUCERS
-- ==========================================
create table if not exists n8n_ig.coauthor_producers (
  id               bigserial primary key,
  instagram_id     text unique,
  username         text not null,
  profile_pic_url  text,
  is_verified      boolean,

  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create trigger coauthor_producers_set_updated_at
before update on n8n_ig.coauthor_producers
for each row execute function n8n_ig.set_updated_at();


-- link posts <-> coauthors
create table if not exists n8n_ig.post_coauthor_producers (
  post_id               bigint not null references n8n_ig.posts(id) on delete cascade,
  coauthor_producer_id  bigint not null references n8n_ig.coauthor_producers(id) on delete cascade,
  primary key (post_id, coauthor_producer_id)
);

create index if not exists pcp_post_id_idx on n8n_ig.post_coauthor_producers(post_id);


-- ==========================================
-- CHILD POSTS (Sidecar slides)
-- ==========================================
create table if not exists n8n_ig.post_child_posts (
  parent_post_id bigint not null references n8n_ig.posts(id) on delete cascade,
  child_post_id  bigint not null references n8n_ig.posts(id) on delete cascade,
  position       int not null,
  primary key (parent_post_id, child_post_id),
  constraint no_self_child check (parent_post_id <> child_post_id)
);

create index if not exists pcp_parent_pos_idx
  on n8n_ig.post_child_posts(parent_post_id, position);


-- ==========================================
-- GRANT PERMISSIONS
-- ==========================================

-- Grant usage on schema to anon and service roles
GRANT USAGE ON SCHEMA n8n_ig TO anon, authenticated, service_role;

-- Grant all privileges on all tables in the schema
GRANT ALL ON ALL TABLES IN SCHEMA n8n_ig TO anon, authenticated, service_role;

-- Grant all privileges on all sequences in the schema (for auto-increment IDs)
GRANT ALL ON ALL SEQUENCES IN SCHEMA n8n_ig TO anon, authenticated, service_role;

-- Ensure future tables and sequences also get these permissions
ALTER DEFAULT PRIVILEGES IN SCHEMA n8n_ig GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA n8n_ig GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;
