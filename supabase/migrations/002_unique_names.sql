create unique index if not exists cc_players_nickname_unique on public.cc_players (lower(nickname));
