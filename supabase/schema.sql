-- Meu Plano Nutrição — esquema inicial multiusuário
-- Executar no SQL Editor do projeto Supabase. Não executar até revisar políticas.
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null default '',
 role text not null default 'member' check (role in ('member','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.meal_plans (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 name text not null default 'Meu plano',
 days jsonb not null default '{}'::jsonb,
 updated_at timestamptz not null default now(),
 unique(user_id)
);
create table if not exists public.daily_logs (
 user_id uuid not null references auth.users(id) on delete cascade,
 day date not null,
 data jsonb not null default '{}'::jsonb,
 updated_at timestamptz not null default now(),
 primary key(user_id,day)
);
create table if not exists public.measurements (
 user_id uuid not null references auth.users(id) on delete cascade,
 day date not null,
 weight_kg numeric(5,2) check (weight_kg > 0 and weight_kg < 500),
 waist_cm numeric(5,2) check (waist_cm > 0 and waist_cm < 500),
 primary key(user_id,day)
);
create index if not exists meal_plans_user_idx on public.meal_plans(user_id);
create index if not exists daily_logs_user_idx on public.daily_logs(user_id);
create index if not exists measurements_user_idx on public.measurements(user_id);
alter table public.profiles enable row level security;
alter table public.meal_plans enable row level security;
alter table public.daily_logs enable row level security;
alter table public.measurements enable row level security;
revoke all on public.profiles,public.meal_plans,public.daily_logs,public.measurements from anon,authenticated;
grant select,insert,update on public.profiles to authenticated;
grant select,insert,update,delete on public.meal_plans,public.daily_logs,public.measurements to authenticated;
-- Roles não podem ser autodeclaradas: somente o administrador do banco promove admins.
create or replace function public.is_plan_admin() returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.profiles where id=(select auth.uid()) and role='admin');
$$;
revoke all on function public.is_plan_admin() from public,anon;
grant execute on function public.is_plan_admin() to authenticated;
create policy "profile self or admin read" on public.profiles for select to authenticated using ((select auth.uid())=id or (select public.is_plan_admin()));
create policy "profile self create member" on public.profiles for insert to authenticated with check ((select auth.uid())=id and role='member');
-- Não há política de UPDATE para profiles: nomes e roles serão geridos pelo backend autorizado.
create policy "plans self or admin read" on public.meal_plans for select to authenticated using ((select auth.uid())=user_id or (select public.is_plan_admin()));
create policy "plans admin create" on public.meal_plans for insert to authenticated with check ((select public.is_plan_admin()));
create policy "plans admin update" on public.meal_plans for update to authenticated using ((select public.is_plan_admin())) with check ((select public.is_plan_admin()));
create policy "plans admin delete" on public.meal_plans for delete to authenticated using ((select public.is_plan_admin()));
create policy "logs self read" on public.daily_logs for select to authenticated using ((select auth.uid())=user_id);
create policy "logs self insert" on public.daily_logs for insert to authenticated with check ((select auth.uid())=user_id);
create policy "logs self update" on public.daily_logs for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "logs self delete" on public.daily_logs for delete to authenticated using ((select auth.uid())=user_id);
create policy "measurements self read" on public.measurements for select to authenticated using ((select auth.uid())=user_id);
create policy "measurements self insert" on public.measurements for insert to authenticated with check ((select auth.uid())=user_id);
create policy "measurements self update" on public.measurements for update to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "measurements self delete" on public.measurements for delete to authenticated using ((select auth.uid())=user_id);
-- Após criar sua conta, promover seu UUID pelo painel SQL autenticado:
-- update public.profiles set role='admin' where id='UUID-DA-SUA-CONTA';
-- Importante: não publicar chaves secret/service_role no GitHub Pages.
