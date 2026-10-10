begin;
do $$
declare player uuid; old_revision bigint; result jsonb;
begin
 select id into player from public.cc_players limit 1;
 if player is null then raise exception 'An existing test player is required';end if;
 select coalesce((select revision from public.cc_progress where player_id=player),0) into old_revision;
 result:=public.cc_save_progress(player,old_revision,'{"version":1}'::jsonb);
 if (result->>'conflict')::boolean then raise exception 'First save failed';end if;
 result:=public.cc_save_progress(player,old_revision,'{"version":1}'::jsonb);
 if not (result->>'conflict')::boolean then raise exception 'Stale save was accepted';end if;
 if has_table_privilege('anon','public.cc_progress','SELECT') or has_table_privilege('authenticated','public.cc_progress','UPDATE') then raise exception 'Public progress access';end if;
 if has_function_privilege('authenticated','public.cc_save_progress(uuid,bigint,jsonb)','EXECUTE') then raise exception 'Public save RPC access';end if;
end $$;
rollback;
select 'Cloud revision conflicts and private access passed; test changes rolled back' as result;
