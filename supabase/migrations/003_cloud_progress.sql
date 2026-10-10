create table if not exists public.cc_progress (
 player_id uuid primary key references auth.users(id) on delete cascade,
 payload jsonb not null,
 revision bigint not null default 1,
 updated_at timestamptz not null default now()
);
alter table public.cc_progress enable row level security;
revoke all on public.cc_progress from anon,authenticated;
create or replace function public.cc_save_progress(p_id uuid,p_revision bigint,p_payload jsonb)
returns jsonb language plpgsql security definer set search_path=public as $$
declare current_revision bigint;
begin
 perform pg_advisory_xact_lock(hashtextextended(p_id::text,951));
 select revision into current_revision from cc_progress where player_id=p_id;
 if coalesce(current_revision,0)<>p_revision then return jsonb_build_object('conflict',true);end if;
 insert into cc_progress(player_id,payload,revision,updated_at) values(p_id,p_payload,1,now())
 on conflict(player_id) do update set payload=excluded.payload,revision=cc_progress.revision+1,updated_at=now();
 return (select jsonb_build_object('conflict',false,'revision',revision,'updated_at',updated_at) from cc_progress where player_id=p_id);
end $$;
revoke all on function public.cc_save_progress(uuid,bigint,jsonb) from public,anon,authenticated;
grant execute on function public.cc_save_progress(uuid,bigint,jsonb) to service_role;
