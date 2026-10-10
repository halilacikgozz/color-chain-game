extends SceneTree

var failures := 0

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error(label)

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var game = load("res://scripts/game.gd").new()
	game.save_path = "user://color_chain_test.cfg"
	DirAccess.remove_absolute(game.save_path)
	root.add_child(game)
	game.map_open = false
	game.home_open = false
	game.specials.fill(0)
	check(game.board.size() == 49 and game.has_move(), "Initial board must be full and playable")
	game.arrival = 0.0
	game.impact = 0.0
	game.started = false
	check(not game.needs_continuous_redraw(), "Idle board must not request continuous rendering")
	game.busy = true
	check(game.needs_continuous_redraw(), "Falling stones still request animation frames")
	game.busy = false
	game.map_open = true
	check(game.needs_continuous_redraw() == game.effects, "Map decorations honor the animation switch")
	game.map_open = false
	check(not game.adjacent(6, 7), "Rows must not wrap")
	check(not game.adjacent(0, 8), "Diagonal selection is forbidden")
	check(game.cell_at(Vector2(36, 230)) == -1, "Outside board must be rejected")
	game.board.fill(0)
	game.select_cell(0)
	game.select_cell(1)
	game.select_cell(2)
	game.select_cell(1)
	check(game.chain.size() == 2, "Backtracking removes last selection")
	game.release_pointer()
	check(game.score == 0, "Short chains do not score")
	game.board[1] = 1
	game.select_cell(0)
	game.select_cell(1)
	check(game.chain.size() == 1, "Different colors must be rejected")
	game.chain.clear()
	game.board.fill(0)
	game.select_cell(0)
	game.select_cell(1)
	game.select_cell(2)
	game.release_pointer()
	check(game.score == 30 and game.busy, "Three tiles score 30 and lock input")
	await create_timer(0.6).timeout
	check(not game.busy and game.has_move(), "Refill completes and leaves a playable board")
	# Remove the bottom tile of a column; survivors retain their order.
	for y in 7:
		game.board[y * 7] = y % 4
	game.chain.assign([42])
	game.collapse()
	for y in range(1, 7):
		check(game.board[y * 7] == (y - 1) % 4, "Gravity preserves column order")
	for i in 49:
		game.board[i] = (i % 7 + i / 7) % 4
	check(not game.has_move(), "Checker pattern has no move")
	game.ensure_move()
	check(game.has_move(), "Stuck boards recover")
	game.chain.clear()
	game.board.fill(0)
	game.select_cell(0)
	game.select_cell(1)
	game.select_cell(2)
	game.release_pointer()
	game.restart()
	game.specials.fill(0)
	await create_timer(0.6).timeout
	check(game.score == 0 and not game.busy and game.chain.is_empty(), "Restart cancels animation and clears score")
	game.board.fill(0)
	game.select_cell(0)
	game.select_cell(1)
	game.select_cell(2)
	game.release_pointer()
	await create_timer(0.6).timeout
	game.board.fill(0)
	game.select_cell(0)
	game.select_cell(1)
	game.select_cell(2)
	game.release_pointer()
	check(game.combo == 2 and game.score == 90, "Quick second chain doubles points")
	await create_timer(0.6).timeout
	game.combo_left = 0.0
	game.combo = 0
	game.remaining = 20.0
	game.board.fill(0)
	for i in 5:
		game.select_cell(i)
	game.release_pointer()
	check(game.remaining == 23.0, "Five tiles grant three seconds")
	await create_timer(0.6).timeout
	game.remaining = 0.0
	game._process(0.01)
	check(game.ended, "Timer ends the round")
	var final_score: int = game.score
	game.select_cell(0)
	game.release_pointer()
	check(game.score == final_score and game.chain.is_empty(), "Ended rounds reject input")
	game.restart()
	game.specials.fill(0)
	game.timed_mode = false
	game.started = true
	game._process(65.0)
	check(not game.ended, "Relaxed mode has no deadline")
	game.timed_mode = true
	game.restart()
	game.specials.fill(0)
	game.started = true
	game.focused = false
	game._process(5.0)
	check(game.remaining == 60.0, "Timer pauses when focus is lost")
	game.focused = true
	game.restart()
	game.specials.fill(0)
	game.xp = 0
	game.stars = 0
	game.quests_done = 0
	game.quest_progress = 0
	game.combo = 1
	game.update_progress(3, 30)
	check(game.stars == 1 and game.quests_done == 1 and game.xp == 41, "First quest grants one star and bonus XP")
	for i in 5:
		game.update_progress(3, 30)
	check(game.stars == 2 and game.quests_done == 2, "Move quest rewards only after five valid chains")
	check(not game.choose_theme(1), "Locked themes cannot be equipped")
	game.stars = 3
	check(game.choose_theme(1), "Three stars unlock Neon")
	var earned_xp: int = game.xp
	game.restart()
	game.specials.fill(0)
	check(game.xp == earned_xp and game.stars == 3 and game.theme_index == 1, "Restart retains progression and equipped theme")
	var restored = load("res://scripts/game.gd").new()
	restored.save_path = game.save_path
	restored.load_progress()
	check(restored.xp == game.xp and restored.theme_index == 1 and restored.stars == 3, "Save and load restore progression")
	restored.free()
	game.xp = 250
	check(game.player_level() == 3, "Every 100 XP raises level")
	game.timed_mode = false
	game.timed_best = 0
	game.score = 1000
	game.update_progress(3, 30)
	check(game.timed_best == 0, "Relaxed play cannot raise timed medal record")
	game.timed_mode = true
	game.update_progress(3, 30)
	check(game.timed_best == 1000 and game.medal(1000) == "ALTIN", "Timed scores earn medals")
	game.profile_open = true
	game.started = true
	game.remaining = 20.0
	game._process(2.0)
	check(game.remaining == 20.0, "Rewards screen pauses timer")
	game.select_cell(0)
	check(game.chain.is_empty(), "Rewards screen blocks board selection")
	game.quests_done = 100000
	game.quest_progress = 0
	check(game.quest_target() > 0, "Quest rotation remains valid after many completions")
	game.restart()
	check(game.specials[1] == game.BOMB and game.board[0] == game.board[1] and game.board[1] == game.board[2], "Each round provides a playable starter bomb")
	game.specials.fill(0)
	game.board.fill(0)
	game.chain.assign([0, 1, 2, 3, 4])
	game.prepare_resolution()
	check(game.reward_kind == game.BOMB and not game.clear_cells.has(4), "Five tiles reserve a bomb reward")
	game.collapse()
	check(game.specials[4] == game.BOMB and game.specials.count(game.BOMB) == 1, "Bomb reward survives refill")
	game.specials.fill(0)
	game.chain.assign([0, 1, 2, 3, 4, 5, 6])
	game.prepare_resolution()
	game.collapse()
	check(game.specials[6] == game.LIGHTNING, "Seven tiles create lightning")
	game.specials.fill(0)
	game.specials[0] = game.BOMB
	game.chain.assign([0, 1, 2])
	game.prepare_resolution()
	check(game.clear_cells.size() == 5 and game.clear_cells.has(7) and game.clear_cells.has(8), "Corner bomb clips its blast to board bounds")
	game.collapse()
	game.specials.fill(0)
	game.specials[24] = game.LIGHTNING
	game.chain.assign([23, 24, 25])
	game.prepare_resolution()
	check(game.clear_cells.size() == 7 and game.clear_cells.has(21) and game.clear_cells.has(27), "Lightning clears its complete row")
	game.collapse()
	game.specials.fill(0)
	game.specials[24] = game.BOMB
	game.specials[25] = game.LIGHTNING
	game.chain.assign([17, 24, 31])
	game.prepare_resolution()
	check(game.clear_cells.size() == 13 and game.clear_cells.has(21) and game.clear_cells.has(27), "Bomb triggers nearby lightning with unique cells")
	game.collapse()
	check(game.specials.count(game.BOMB) == 0 and game.specials.count(game.LIGHTNING) == 0, "Triggered special tiles are consumed")
	game.specials.fill(0)
	game.specials[0] = game.LIGHTNING
	game.chain.assign([42])
	game.collapse()
	check(game.specials[7] == game.LIGHTNING, "Special identity follows gravity")
	game.restart()
	game.specials.fill(0)
	game.board.fill(0)
	game.specials[0] = game.BOMB
	game.select_cell(0)
	game.select_cell(1)
	game.release_pointer()
	check(game.specials[0] == game.BOMB and game.score == 0, "Short chains cannot activate special tiles")
	game.select_cell(0)
	game.select_cell(1)
	game.select_cell(2)
	game.release_pointer()
	check(game.score == 50, "Blast bonus counts each additional cleared cell once")
	game.restart()
	await create_timer(0.6).timeout
	check(not game.resolution_active and game.clear_cells.is_empty() and game.special_waves.is_empty(), "Restart cancels pending special effects")
	game.restart()
	game.specials.fill(0)
	game.board.fill(1)
	game.specials[0] = game.RAINBOW
	game.select_cell(0)
	game.select_cell(1)
	game.board[2] = 2
	game.select_cell(2)
	check(game.chain.size() == 2 and game.chain_color() == 1, "Rainbow first locks to first normal tile color")
	game.select_cell(0)
	game.board[7] = 2
	game.select_cell(7)
	check(game.chain_color() == 2 and game.chain.size() == 2, "Backtracking releases rainbow color lock")
	game.chain.clear()
	game.specials.fill(0)
	game.board.fill(1)
	game.specials[1] = game.RAINBOW
	game.board[2] = 2
	game.select_cell(0)
	game.select_cell(1)
	game.select_cell(2)
	check(game.chain.size() == 2, "Rainbow cannot bridge two different normal colors")
	game.chain.clear()
	game.specials.fill(0)
	game.board.fill(1)
	game.specials[0] = game.RAINBOW
	for index in [1, 2, 5, 12, 19]:
		game.board[index] = 2
	game.chain.assign([0, 1, 2])
	game.prepare_resolution()
	check(game.clear_cells.size() == 6 and game.clear_cells.has(19) and not game.clear_cells.has(3), "Rainbow clears chosen color throughout board")
	game.collapse()
	game.specials.fill(0)
	game.board.fill(1)
	game.specials[0] = game.RAINBOW
	game.specials[12] = game.BOMB
	for index in [1, 2, 12]:
		game.board[index] = 2
	game.chain.assign([0, 1, 2])
	game.prepare_resolution()
	check(game.clear_cells.has(11) and game.clear_cells.has(13), "Rainbow activates a matching-color bomb")
	game.collapse()
	game.specials.fill(0)
	game.board.fill(0)
	game.chain.assign([0, 1, 2, 3, 4, 5, 6, 7, 8])
	game.prepare_resolution()
	check(game.reward_kind == game.RAINBOW and not game.clear_cells.has(8), "Nine tiles award a rainbow instead of lightning")
	game.collapse()
	check(game.specials.count(game.RAINBOW) == 1, "Rainbow reward survives refill")
	game.specials.fill(0)
	game.board.fill(1)
	for index in [0, 1, 2]:
		game.specials[index] = game.RAINBOW
	game.chain.assign([0, 1, 2])
	game.prepare_resolution()
	check(game.clear_cells.size() == 49, "Rainbow-only chains resolve with a deterministic fallback color")
	game.restart()
	game.level_stars.fill(0)
	game.level_bests.fill(0)
	game.map_open = false
	check(not game.start_stage(1), "Locked stages cannot be started")
	check(game.start_stage(0), "First stage starts unlocked")
	var first_board: Array = game.board.duplicate()
	game.restart()
	check(game.board == first_board and game.moves_left == 12, "Retries restore the same seeded board and budget")
	game.chain.assign([0,1])
	game.release_pointer()
	check(game.moves_left == 12, "Invalid chains do not spend stage moves")
	game.score = 90
	game.moves_left = 6
	game.check_stage_end()
	check(game.stage_won and game.stage_rating == 3 and game.stage_unlocked(1), "Goal completion grants stars and unlocks next stage")
	var win_xp: int = game.xp
	game.check_stage_end()
	check(game.xp == win_xp, "Winning cannot grant XP twice")
	game.restart()
	game.score = 90
	game.moves_left = 0
	game.check_stage_end()
	check(game.stage_won and game.stage_rating == 1 and game.level_stars[0] == 3, "Win on last move succeeds and never lowers saved stars")
	game.start_stage(1)
	game.moves_left = 0
	game.score = 0
	game.check_stage_end()
	check(game.ended and not game.stage_won and game.level_stars[1] == 0, "Running out of moves fails without awarding stars")
	game.level_stars[1] = 1
	game.level_stars[2] = 1
	game.start_stage(3)
	check(game.ice_left() == 6, "Ice stages create the configured goal")
	game.specials.fill(0)
	game.board.fill(0)
	game.ice.fill(0)
	game.ice[0] = 1
	game.ice[1] = 1
	game.chain.assign([0,1,2])
	game.prepare_resolution()
	check(game.ice_left() == 0, "Selected ice cells break once")
	game.collapse()
	game.score = 9999
	game.ice[10] = 1
	game.check_stage_end()
	check(not game.stage_won, "Score alone cannot win an ice stage")
	game.ice[10] = 0
	game.check_stage_end()
	check(game.stage_won, "Combined score and ice goals complete together")
	game.level_stars.fill(1)
	game.level_stars[9] = 0
	check(not game.choose_theme(3), "Garden theme is locked before final stage")
	game.start_stage(9)
	game.ice.fill(0)
	game.score = 1000
	game.check_stage_end()
	check(game.garden_unlocked() and game.choose_theme(3), "World completion unlocks garden theme")
	game.save_best()
	var campaign_restored = load("res://scripts/game.gd").new()
	campaign_restored.save_path = game.save_path
	campaign_restored.load_progress()
	check(campaign_restored.level_stars == game.level_stars and campaign_restored.theme_index == 3, "Campaign stars and garden theme persist")
	campaign_restored.free()
	game.leave_campaign()
	check(not game.campaign_mode and not game.map_open, "Free play remains available")
	game.effects = false
	game.level_stars.fill(1)
	for level_index in 10:
		game.start_stage(level_index)
		for turn in int(game.LEVELS[level_index]["moves"]):
			if game.ended:
				break
			var selected := solve_move(game)
			if selected.size() < 3:
				break
			game.chain.assign(selected)
			game.release_pointer()
			game.fall_tween.kill()
			game.start_fall()
			game.finish_fall()
		check(game.stage_won, "Seeded stage %d solution: score=%d ice=%d moves=%d" % [level_index + 1, game.score, game.ice_left(), game.moves_left])
	game.level_stars.fill(1)
	for index in range(10,30):
		check(game.start_stage(index) and game.has_move() and game.board.size() == 49, "All new stages have a playable opening")
		for turn in int(game.stage_data()["moves"]):
			if game.ended: break
			game.chain.assign(solve_move(game))
			game.release_pointer()
			game.fall_tween.kill()
			game.start_fall()
			game.finish_fall()
		check(game.stage_won, "Expanded stage %d solution score=%d ice=%d mission=%d" % [index+1,game.score,game.ice_left(),game.mission_count])
	game.start_stage(10)
	check(game.ice_left() == 16, "Valley ice has two layers")
	game.score = 99999
	game.ice.fill(0)
	game.check_stage_end()
	check(not game.ended, "Special mission is required in addition to score")
	game.mission_count = 1
	game.check_stage_end()
	check(game.stage_won, "Score ice and special mission jointly win")
	var wallet: int = game.crystals
	game.check_stage_end()
	check(game.crystals == wallet, "First-clear crystals cannot be claimed twice")
	game.start_stage(20)
	check(game.relay.count(1) == 5, "Neon stage has energy targets")
	game.board.fill(0)
	game.specials.fill(0)
	game.specials[0] = game.BOMB
	game.specials[1] = game.LIGHTNING
	game.chain.assign([0,1,2])
	game.prepare_resolution()
	check(game.clear_cells.has(43) and game.mission_count > 0, "Bomb lightning combo hits cross and relay targets")
	game.collapse()
	game.start_daily()
	var daily_board = game.board.duplicate()
	game.restart()
	check(game.board == daily_board and game.moves_left == 20, "Daily retries use identical board and move limit")
	var daily_wallet: int = game.crystals
	game.score = 500
	game.finish_daily()
	check(game.crystals == daily_wallet + 40, "Daily target grants crystals")
	game.restart()
	game.score = 500
	game.finish_daily()
	check(game.crystals == daily_wallet + 40, "Daily reward is only granted once")
	game.crystals = 74
	check(not game.buy_cosmetic(1), "Collection blocks unaffordable purchase")
	game.crystals = 75
	check(game.buy_cosmetic(1) and game.crystals == 0, "Collection purchase deducts exact cost")
	check(game.buy_cosmetic(1) and game.crystals == 0, "Owned cosmetics are free to reselect")
	game.save_best()
	var expanded = load("res://scripts/game.gd").new()
	expanded.save_path = game.save_path
	expanded.load_progress()
	check(expanded.level_stars.size() == 30 and expanded.owned_cosmetics.has(1) and expanded.daily_best == 500, "Expansion data persists")
	expanded.free()
	game.start_daily()
	game.effects = false
	for turn in 20:
		game.chain.assign(solve_move(game))
		game.release_pointer()
		game.fall_tween.kill()
		game.start_fall()
		game.finish_fall()
	check(game.ended and game.daily_replay.size() == 20, "Daily replay records exactly twenty valid moves")
	var fixture := FileAccess.open("res://tests/daily_fixture.json", FileAccess.WRITE)
	fixture.store_string(JSON.stringify({"day":game.daily_day,"moves":game.daily_replay,"score":game.score}))
	fixture.close()
	game.open_home()
	var menu_score: int = game.score
	game.select_cell(0)
	check(game.chain.is_empty() and game.score == menu_score, "Home menu blocks board input")
	game.press(game.HOME_JOURNEY.get_center(),-1)
	check(game.map_open and not game.home_open and game.island_overview, "Journey opens island overview")
	game.press(game.ISLAND_ZONES[1].get_center(),-1)
	check(game.world_page == 1 and not game.island_overview, "Ice island opens its chapter map")
	game.press(game.CHAPTER_NEXT.get_center(),-1)
	check(game.chapter_page == 1, "Later five chapters are accessible")
	game.press(game.CHAPTER_PREV.get_center(),-1)
	check(game.chapter_page == 0, "Earlier chapters remain accessible")
	game.level_stars.fill(0)
	var map_before: int = game.stage
	game.press(game.map_node(2),-1)
	check(game.map_open and game.stage == map_before, "Locked scenic stops cannot start a level")
	game.press(game.PROFILE_BACK.get_center(),-1)
	check(game.island_overview and game.map_open, "Chapter map returns to islands")
	game.press(game.PROFILE_BACK.get_center(),-1)
	check(game.home_open and not game.map_open, "Map returns to home")
	game.press(game.HOME_COLLECTION.get_center(),-1)
	check(game.collection_open, "Home opens collection")
	game.press(game.PROFILE_BACK.get_center(),-1)
	check(game.home_open and not game.collection_open, "Collection returns to home")
	game.press(game.HOME_DAILY.get_center(),-1)
	check(game.daily_mode and game.moves_left == 20 and not game.home_open, "Daily menu card starts daily event")
	game.open_home()
	game.press(game.HOME_PLAY.get_center(),-1)
	check(not game.timed_mode and not game.campaign_mode and not game.daily_mode and not game.home_open, "Free play starts unlimited relaxed mode")
	DirAccess.remove_absolute(game.save_path)
	game.queue_free()
	print("Color Chain tests: %d failures" % failures)
	quit(1 if failures else 0)

var search_best: Array[int] = []
var search_value := -1
var search_budget := 0

func solve_move(game) -> Array[int]:
	search_best.clear()
	search_value = -1
	for start in 49:
		search_budget = 1000
		var path: Array[int] = [start]
		search_path(game, path, game.board[start] if game.specials[start] != game.RAINBOW else -1)
	return search_best.duplicate()

func search_path(game, path: Array[int], color: int) -> void:
	search_budget -= 1
	if search_budget <= 0:
		return
	if path.size() >= 3:
		var value := path.size() * 8
		if game.campaign_mode and game.stage >= 10 and not game.mission_complete():
			var kind: String = game.stage_data().get("mission", "")
			if kind == "chain" and path.size() >= int(game.stage_data()["target"]): value += 3000
			for index in path:
				if game.special_name_key(game.specials[index]) == kind: value += 600
				if kind == "relay" and game.relay[index] > 0: value += 400
		var hit: Array[int] = path.duplicate()
		for index in path:
			if game.specials[index] == game.BOMB:
				for other in 49:
					if absi(other % 7 - index % 7) <= 1 and absi(other / 7 - index / 7) <= 1 and not hit.has(other):
						hit.append(other)
			elif game.specials[index] == game.LIGHTNING:
				for x in 7:
					if not hit.has(index / 7 * 7 + x): hit.append(index / 7 * 7 + x)
			elif game.specials[index] == game.RAINBOW:
				for other in 49:
					if game.board[other] == color and not hit.has(other): hit.append(other)
		for index in hit:
			value += 150 if game.ice[index] > 0 else 1
		if value > search_value:
			search_value = value
			search_best.assign(path)
	if path.size() >= (12 if game.campaign_mode and game.stage >= 10 else 9):
		return
	var last: int = path.back()
	for next in [last - 7, last + 7, last - 1, last + 1]:
		if next < 0 or next >= 49 or path.has(next) or not game.adjacent(last,next): continue
		if game.specials[next] != game.RAINBOW and color != -1 and game.board[next] != color: continue
		path.append(next)
		search_path(game,path,game.board[next] if color == -1 and game.specials[next] != game.RAINBOW else color)
		path.pop_back()
