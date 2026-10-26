-- Gartenmond: Datenbank einrichten
-- Im Supabase-Dashboard unter "SQL Editor" einfügen, die E-Mail in der letzten Zeile anpassen und "Run" klicken.

-- Tabellen ------------------------------------------------------------------
create table if not exists public.members (
  email      text primary key check (email = lower(email)),
  role       text not null default 'gardener' check (role in ('admin','gardener','read')),
  last_seen  date,
  created_at timestamptz not null default now()
);

create table if not exists public.zones (
  id         text primary key,
  name       text not null check (char_length(name) between 1 and 60),
  kind       text,
  light      text,
  color      text,
  note       text,
  ord        bigint,
  created_by uuid default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.plantings (
  id         text primary key,
  zone_id    text not null references public.zones(id) on delete cascade,
  cat        text not null,
  count      int  not null default 1 check (count between 1 and 999),
  status     text not null default 'gepflanzt' check (status in ('gepflanzt','geplant')),
  note       text,
  added      date,
  created_by uuid default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.done (
  id       text primary key,
  pid      text not null references public.plantings(id) on delete cascade,
  tid      text not null,
  y        int  not null,
  date     date not null,
  skipped  boolean not null default false,
  done_by  uuid default auth.uid()
);

-- Rolle der angemeldeten Person -------------------------------------------
create or replace function public.my_role() returns text
language sql stable security definer set search_path = public as $$
  select role from public.members where email = lower(coalesce(auth.jwt() ->> 'email', ''));
$$;

-- "zuletzt da" setzen, ohne dass Mitglieder die Liste ändern dürfen
create or replace function public.touch_me() returns void
language sql security definer set search_path = public as $$
  update public.members set last_seen = current_date
  where email = lower(coalesce(auth.jwt() ->> 'email', ''));
$$;
grant execute on function public.my_role()  to authenticated;
grant execute on function public.touch_me() to authenticated;

-- Zugriffsregeln (Row Level Security) -------------------------------------
alter table public.members   enable row level security;
alter table public.zones     enable row level security;
alter table public.plantings enable row level security;
alter table public.done      enable row level security;

drop policy if exists "lesen"     on public.members;
drop policy if exists "verwalten" on public.members;
create policy "lesen"     on public.members for select to authenticated using (public.my_role() is not null);
create policy "verwalten" on public.members for all    to authenticated using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

drop policy if exists "lesen"     on public.zones;
drop policy if exists "verwalten" on public.zones;
create policy "lesen"     on public.zones for select to authenticated using (public.my_role() is not null);
create policy "verwalten" on public.zones for all    to authenticated using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

drop policy if exists "lesen"   on public.plantings;
drop policy if exists "gaertnern" on public.plantings;
create policy "lesen"     on public.plantings for select to authenticated using (public.my_role() is not null);
create policy "gaertnern" on public.plantings for all    to authenticated using (public.my_role() in ('admin','gardener')) with check (public.my_role() in ('admin','gardener'));

drop policy if exists "lesen"   on public.done;
drop policy if exists "gaertnern" on public.done;
create policy "lesen"     on public.done for select to authenticated using (public.my_role() is not null);
create policy "gaertnern" on public.done for all    to authenticated using (public.my_role() in ('admin','gardener')) with check (public.my_role() in ('admin','gardener'));

-- Live-Aktualisierung auf beiden Handys -------------------------------------
do $$ begin
  alter publication supabase_realtime add table public.members, public.zones, public.plantings, public.done;
exception when duplicate_object then null; end $$;

-- Dich selbst als Verwalter eintragen (E-Mail anpassen!) -------------------
insert into public.members (email, role) values (lower('DEINE-EMAIL@example.com'), 'admin')
on conflict (email) do update set role = 'admin';
