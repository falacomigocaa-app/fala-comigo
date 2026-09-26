-- Gate 2: schema mínimo do portal sintético.
-- Não contém dados reais, senhas, tokens ou credenciais.

create table if not exists users (
  id text primary key,
  external_subject text not null unique,
  status text not null check (status in ('active', 'disabled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists organizations (
  id text primary key,
  name text not null,
  status text not null check (status in ('active', 'suspended')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists memberships (
  id text primary key,
  user_id text not null references users(id),
  organization_id text not null references organizations(id),
  role text not null check (role in ('owner', 'org_admin', 'professional', 'outsider')),
  status text not null check (status in ('active', 'revoked', 'expired')),
  valid_until timestamptz not null,
  unique (user_id, organization_id)
);

create table if not exists invitations (
  id text primary key,
  organization_id text not null references organizations(id),
  invitee_user_id text not null references users(id),
  role text not null check (role in ('org_admin', 'professional')),
  status text not null check (status in ('pending', 'accepted', 'declined', 'expired')),
  expires_at timestamptz not null
);

create table if not exists access_grants (
  id text primary key,
  user_id text not null references users(id),
  organization_id text not null references organizations(id),
  purpose text not null,
  scopes text[] not null default '{}',
  status text not null check (status in ('active', 'revoked', 'expired')),
  valid_until timestamptz not null
);

create table if not exists benefit_entitlements (
  id text primary key,
  organization_id text not null references organizations(id),
  status text not null check (status in ('active', 'suspended', 'expired', 'revoked')),
  valid_until timestamptz not null
);

create table if not exists audit_events (
  id text primary key,
  user_id text references users(id),
  organization_id text references organizations(id),
  action text not null,
  result text not null check (result in ('allowed', 'denied')),
  code text,
  request_id text,
  occurred_at timestamptz not null,
  api_version text not null
);

create unique index if not exists audit_events_request_id_idx
  on audit_events(request_id)
  where request_id is not null;
