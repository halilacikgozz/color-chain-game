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
	await create_timer(0.5).timeout
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
	await create_timer(0.5).timeout
	check(game.score == 0 and not game.busy and game.chain.is_empty(), "Restart cancels animation and clears score")
	game.queue_free()
	print("Color Chain tests: %d failures" % failures)
	quit(1 if failures else 0)
