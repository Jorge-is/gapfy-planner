-- Initial schema for Gapfy: academic and time planning.
-- Source of truth documented in docs/DATA-MODEL.md.

create extension if not exists "pgcrypto";

-- Areas (UTP, ICPNA, work, personal, ...)
create table areas (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    color text not null default '#64748b',
    created_at timestamptz not null default now()
);

create table projects (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    area_id uuid references areas(id) on delete set null,
    name text not null,
    status text not null default 'active' check (status in ('active','archived')),
    created_at timestamptz not null default now()
);

-- Recurring series (fixed classes)
create table event_series (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    area_id uuid references areas(id) on delete set null,
    title text not null,
    byweekday int[] not null,           -- 0=sunday .. 6=saturday
    start_time time not null,
    end_time time not null,
    valid_from date not null,
    valid_until date not null,
    timezone text not null default 'America/Lima',
    created_at timestamptz not null default now(),
    check (end_time > start_time),
    check (valid_until >= valid_from)
);

create table event_exceptions (
    id uuid primary key default gen_random_uuid(),
    series_id uuid not null references event_series(id) on delete cascade,
    occurrence_date date not null,
    kind text not null check (kind in ('CANCELLED','MOVED')),
    override_start time,
    override_end time,
    unique (series_id, occurrence_date)
);

-- One-off, non-recurring events
create table manual_events (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    title text not null,
    starts_at timestamptz not null,
    ends_at timestamptz not null,
    created_at timestamptz not null default now(),
    check (ends_at > starts_at)
);

-- Tasks, exams, deliverables
create table tasks (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    project_id uuid references projects(id) on delete set null,
    area_id uuid references areas(id) on delete set null,
    title text not null,
    deadline date not null,
    priority text not null default 'media' check (priority in ('alta','media','baja')),
    estimated_minutes int not null check (estimated_minutes > 0),
    status text not null default 'pending' check (status in ('pending','in_progress','done')),
    created_at timestamptz not null default now()
);

-- Scheduler runs (audit trail for reschedules)
create table plan_runs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    executed_at timestamptz not null default now(),
    trigger_reason text not null   -- 'manual' | 'session_skipped' | 'task_created' | 'deadline_changed'
);

-- Planned sessions
create table planned_sessions (
    id uuid primary key default gen_random_uuid(),
    task_id uuid not null references tasks(id) on delete cascade,
    plan_run_id uuid references plan_runs(id) on delete set null,
    starts_at timestamptz not null,
    ends_at timestamptz not null,
    origin text not null check (origin in ('AUTO','MANUAL')),
    locked boolean not null default false,
    created_at timestamptz not null default now(),
    check (ends_at > starts_at)
);

-- Record of what actually happened
create table session_logs (
    id uuid primary key default gen_random_uuid(),
    planned_session_id uuid references planned_sessions(id) on delete set null,
    task_id uuid not null references tasks(id) on delete cascade,
    actual_start timestamptz not null,
    actual_end timestamptz,
    outcome text not null check (outcome in ('DONE','PARTIAL','SKIPPED')),
    created_at timestamptz not null default now()
);

-- Per-user settings
create table user_settings (
    user_id uuid primary key references auth.users(id) on delete cascade,
    sleep_start time not null default '23:00',
    sleep_end time not null default '07:00',
    max_minutes_per_day int not null default 240,
    min_block_minutes int not null default 30,
    min_break_minutes int not null default 10
);

-- Web Push subscriptions
create table push_subscriptions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    endpoint text not null unique,
    keys jsonb not null,
    created_at timestamptz not null default now()
);

-- Indexes
create index idx_event_series_user on event_series(user_id);
create index idx_manual_events_user_time on manual_events(user_id, starts_at);
create index idx_tasks_user_deadline on tasks(user_id, deadline);
create index idx_planned_sessions_task on planned_sessions(task_id);
create index idx_planned_sessions_time on planned_sessions(starts_at);
create index idx_session_logs_task on session_logs(task_id);

-- Row Level Security
alter table areas enable row level security;
alter table projects enable row level security;
alter table event_series enable row level security;
alter table event_exceptions enable row level security;
alter table manual_events enable row level security;
alter table tasks enable row level security;
alter table plan_runs enable row level security;
alter table planned_sessions enable row level security;
alter table session_logs enable row level security;
alter table user_settings enable row level security;
alter table push_subscriptions enable row level security;

-- Standard policy: the row owner (direct user_id or via join) is the only one with access
create policy "own rows" on areas for all using (auth.uid() = user_id);
create policy "own rows" on projects for all using (auth.uid() = user_id);
create policy "own rows" on event_series for all using (auth.uid() = user_id);
create policy "own rows" on manual_events for all using (auth.uid() = user_id);
create policy "own rows" on tasks for all using (auth.uid() = user_id);
create policy "own rows" on plan_runs for all using (auth.uid() = user_id);
create policy "own rows" on user_settings for all using (auth.uid() = user_id);
create policy "own rows" on push_subscriptions for all using (auth.uid() = user_id);

create policy "own via series" on event_exceptions for all using (
    exists (select 1 from event_series s where s.id = series_id and s.user_id = auth.uid())
);
create policy "own via task" on planned_sessions for all using (
    exists (select 1 from tasks t where t.id = task_id and t.user_id = auth.uid())
);
create policy "own via task" on session_logs for all using (
    exists (select 1 from tasks t where t.id = task_id and t.user_id = auth.uid())
);
