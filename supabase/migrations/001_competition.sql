create table if not exists public.cc_players(id uuid primary key references auth.users(id) on delete cascade, nickname text not null, tier integer not null default 0 check(tier between 0 and 3));
create table if not exists public.cc_scores(player_id uuid references public.cc_players(id), day date not null, score integer not null check(score>=0), primary key(player_id,day));
create table if not exists public.cc_members(player_id uuid references public.cc_players(id), week date not null, tier integer not null, cohort integer not null, claimed boolean not null default false, primary key(player_id,week));
alter table public.cc_players enable row level security;
alter table public.cc_scores enable row level security;
alter table public.cc_members enable row level security;
-- Only the authenticated Edge Function's service role may access these tables.
revoke all on public.cc_players,public.cc_scores,public.cc_members from anon,authenticated;
create or replace function public.cc_join(p_id uuid,p_week date) returns void language plpgsql security definer set search_path=public as $$
declare t integer; n integer; previous_week date; previous_rank bigint;
begin
 perform pg_advisory_xact_lock(735501);
 if exists(select 1 from cc_members where player_id=p_id and week=p_week) then return; end if;
 select tier into t from cc_players where id=p_id;
 select max(week) into previous_week from cc_members where player_id=p_id and week<p_week;
 if previous_week is not null then
  select ranking into previous_rank from (
   select m.player_id,row_number() over(order by coalesce(sum(s.score),0) desc,m.player_id) ranking
   from cc_members m left join cc_scores s on s.player_id=m.player_id and s.day>=previous_week and s.day<previous_week+7
   where m.week=previous_week and (m.tier,m.cohort)=(select tier,cohort from cc_members where player_id=p_id and week=previous_week)
   group by m.player_id) r where r.player_id=p_id;
  t=least(3,t+case when previous_rank<=5 then 1 else 0 end);
  update cc_players set tier=t where id=p_id;
 end if;
 select count(*) into n from cc_members where week=p_week and tier=t;
 insert into cc_members values(p_id,p_week,t,n/20,false);
end $$;
revoke all on function public.cc_join(uuid,date) from public,anon,authenticated;
grant execute on function public.cc_join(uuid,date) to service_role;
