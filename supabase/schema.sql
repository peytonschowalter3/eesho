-- eesho Supabase schema
-- Paste this whole file into the Supabase SQL editor for a new project.

create extension if not exists "pgcrypto";

do $$
begin
  create type public.source_type as enum ('upload', 'pasted_text', 'forwarded_email', 'manual');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.document_type as enum ('contract', 'subscription', 'insurance', 'landlord', 'university', 'email', 'other');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.processing_status as enum ('queued', 'processing', 'needs_review', 'completed', 'failed');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.finding_type as enum ('deadline', 'fee', 'renewal', 'notice_period', 'obligation', 'missing_document', 'contact_detail', 'risk', 'other');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.finding_review_status as enum ('ai_found', 'user_confirmed', 'user_dismissed');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.deadline_status as enum ('active', 'completed', 'dismissed', 'snoozed', 'missed');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.risk_level as enum ('low', 'medium', 'high');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.draft_type as enum ('cancellation', 'negotiation', 'clarification', 'follow_up', 'other');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.draft_status as enum ('ai_drafted', 'user_edited', 'user_approved', 'sent', 'cancelled');
exception when duplicate_object then null;
end $$;

do $$
begin
  create type public.draft_editor as enum ('ai', 'user', 'system');
exception when duplicate_object then null;
end $$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  locale text not null default 'en',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_settings (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  timezone text not null default 'UTC',
  email_reminders_enabled boolean not null default true,
  default_reminder_hours integer not null default 72 check (default_reminder_hours >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.email_connections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  provider text not null,
  email_address text not null,
  status text not null default 'not_connected',
  token_reference text,
  last_sync_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, provider, email_address)
);

create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  source_type public.source_type not null,
  document_type public.document_type not null default 'other',
  title text not null,
  original_filename text,
  storage_bucket text not null default 'document-uploads',
  storage_path text,
  mime_type text,
  file_size_bytes bigint check (file_size_bytes is null or file_size_bytes >= 0),
  sender_email text,
  recipient_email text,
  received_at timestamptz,
  extracted_text text,
  plain_language_summary text,
  processing_status public.processing_status not null default 'queued',
  processing_error text,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id)
);

create table if not exists public.findings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  document_id uuid not null,
  type public.finding_type not null,
  review_status public.finding_review_status not null default 'ai_found',
  summary text not null,
  explanation text,
  evidence_text text not null,
  evidence_locator text,
  page_number integer check (page_number is null or page_number > 0),
  line_start integer check (line_start is null or line_start > 0),
  line_end integer check (line_end is null or line_end > 0),
  confidence numeric(4,3) check (confidence is null or (confidence >= 0 and confidence <= 1)),
  due_date date,
  notice_date date,
  money_amount numeric(12,2) check (money_amount is null or money_amount >= 0),
  currency char(3),
  raw_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id),
  check (line_end is null or line_start is null or line_end >= line_start),
  foreign key (document_id, user_id) references public.documents(id, user_id) on delete cascade
);

create table if not exists public.deadlines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  document_id uuid,
  finding_id uuid unique,
  title text not null,
  due_date date not null,
  reminder_at timestamptz,
  status public.deadline_status not null default 'active',
  risk_level public.risk_level not null default 'medium',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id),
  foreign key (document_id, user_id) references public.documents(id, user_id) on delete cascade,
  foreign key (finding_id, user_id) references public.findings(id, user_id) on delete cascade
);

create table if not exists public.draft_emails (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  document_id uuid,
  finding_id uuid,
  deadline_id uuid,
  type public.draft_type not null default 'other',
  status public.draft_status not null default 'ai_drafted',
  recipient_email text,
  cc_emails text[] not null default '{}',
  subject text not null,
  body text not null,
  evidence_summary text,
  ai_model text,
  approved_at timestamptz,
  sent_at timestamptz,
  external_message_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id),
  check (sent_at is null or approved_at is not null),
  foreign key (document_id, user_id) references public.documents(id, user_id) on delete cascade,
  foreign key (finding_id, user_id) references public.findings(id, user_id) on delete cascade,
  foreign key (deadline_id, user_id) references public.deadlines(id, user_id) on delete cascade
);

create table if not exists public.draft_versions (
  id uuid primary key default gen_random_uuid(),
  draft_email_id uuid not null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  version_number integer not null check (version_number > 0),
  edited_by public.draft_editor not null,
  subject text not null,
  body text not null,
  created_at timestamptz not null default now(),
  unique (draft_email_id, version_number),
  foreign key (draft_email_id, user_id) references public.draft_emails(id, user_id) on delete cascade
);

create table if not exists public.action_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  action_type text not null,
  entity_table text,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists set_user_settings_updated_at on public.user_settings;
create trigger set_user_settings_updated_at before update on public.user_settings
for each row execute function public.set_updated_at();

drop trigger if exists set_email_connections_updated_at on public.email_connections;
create trigger set_email_connections_updated_at before update on public.email_connections
for each row execute function public.set_updated_at();

drop trigger if exists set_documents_updated_at on public.documents;
create trigger set_documents_updated_at before update on public.documents
for each row execute function public.set_updated_at();

drop trigger if exists set_findings_updated_at on public.findings;
create trigger set_findings_updated_at before update on public.findings
for each row execute function public.set_updated_at();

drop trigger if exists set_deadlines_updated_at on public.deadlines;
create trigger set_deadlines_updated_at before update on public.deadlines
for each row execute function public.set_updated_at();

drop trigger if exists set_draft_emails_updated_at on public.draft_emails;
create trigger set_draft_emails_updated_at before update on public.draft_emails
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name')
  )
  on conflict (id) do update
  set email = excluded.email,
      full_name = coalesce(public.profiles.full_name, excluded.full_name);

  insert into public.user_settings (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create index if not exists documents_user_status_idx on public.documents (user_id, processing_status, created_at desc);
create index if not exists documents_user_type_idx on public.documents (user_id, document_type);
create index if not exists findings_user_document_idx on public.findings (user_id, document_id);
create index if not exists findings_due_date_idx on public.findings (user_id, due_date) where due_date is not null;
create index if not exists deadlines_user_due_idx on public.deadlines (user_id, due_date, status);
create index if not exists draft_emails_user_status_idx on public.draft_emails (user_id, status, created_at desc);
create index if not exists action_logs_user_created_idx on public.action_logs (user_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.user_settings enable row level security;
alter table public.email_connections enable row level security;
alter table public.documents enable row level security;
alter table public.findings enable row level security;
alter table public.deadlines enable row level security;
alter table public.draft_emails enable row level security;
alter table public.draft_versions enable row level security;
alter table public.action_logs enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile" on public.profiles
for select to authenticated using (id = auth.uid());

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles
for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile" on public.profiles
for insert to authenticated with check (id = auth.uid());

drop policy if exists "Users can manage own settings" on public.user_settings;
create policy "Users can manage own settings" on public.user_settings
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "Users can manage own email connections" on public.email_connections;
create policy "Users can manage own email connections" on public.email_connections
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "Users can manage own documents" on public.documents;
create policy "Users can manage own documents" on public.documents
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "Users can manage own findings" on public.findings;
create policy "Users can manage own findings" on public.findings
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "Users can manage own deadlines" on public.deadlines;
create policy "Users can manage own deadlines" on public.deadlines
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "Users can manage own draft emails" on public.draft_emails;
create policy "Users can manage own draft emails" on public.draft_emails
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "Users can manage own draft versions" on public.draft_versions;
create policy "Users can manage own draft versions" on public.draft_versions
for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "Users can read own action logs" on public.action_logs;
create policy "Users can read own action logs" on public.action_logs
for select to authenticated using (user_id = auth.uid());

drop policy if exists "Users can insert own action logs" on public.action_logs;
create policy "Users can insert own action logs" on public.action_logs
for insert to authenticated with check (user_id = auth.uid());

insert into storage.buckets (id, name, public)
values ('document-uploads', 'document-uploads', false)
on conflict (id) do nothing;

drop policy if exists "Users can read own document uploads" on storage.objects;
create policy "Users can read own document uploads" on storage.objects
for select to authenticated
using (
  bucket_id = 'document-uploads'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can upload own documents" on storage.objects;
create policy "Users can upload own documents" on storage.objects
for insert to authenticated
with check (
  bucket_id = 'document-uploads'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can update own document uploads" on storage.objects;
create policy "Users can update own document uploads" on storage.objects
for update to authenticated
using (
  bucket_id = 'document-uploads'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'document-uploads'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can delete own document uploads" on storage.objects;
create policy "Users can delete own document uploads" on storage.objects
for delete to authenticated
using (
  bucket_id = 'document-uploads'
  and (storage.foldername(name))[1] = auth.uid()::text
);
