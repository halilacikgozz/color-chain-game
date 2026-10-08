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
	game.specials.fill(0)
	check(game.board.size() == 49 and game.has_move(), "Initial board must be full and playable")
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
	DirAccess.remove_absolute(game.save_path)
	game.queue_free()
	print("Color Chain tests: %d failures" % failures)
	quit(1 if failures else 0)
