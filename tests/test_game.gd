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
	root.add_child(game)
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
	game.timed_mode = false
	game.started = true
	game._process(65.0)
	check(not game.ended, "Relaxed mode has no deadline")
	game.timed_mode = true
	game.restart()
	game.started = true
	game.focused = false
	game._process(5.0)
	check(game.remaining == 60.0, "Timer pauses when focus is lost")
	game.queue_free()
	print("Color Chain tests: %d failures" % failures)
	quit(1 if failures else 0)
