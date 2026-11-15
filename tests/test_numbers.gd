extends SceneTree
var failures := 0
const Numbers = preload("res://scripts/number_chain.gd")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	check(Numbers.add("8", "8") == "16", "Two equal stones sum")
	check(Numbers.add("999999999999999999999999999999", "1") == "1000000000000000000000000000000", "Carry beyond int64 is exact")
	check(Numbers.add("128000", "128000") == "256000", "Large tiles sum exactly")
	check(Numbers.compact("128000") == "128K", "128K display")
	check(Numbers.power_at_least("12") == "16", "Three fours round up to sixteen")
	check(Numbers.power_at_least("16") == "16", "Exact power does not jump another tier")
	check(Numbers.power_at_least("20") == "32", "Five fours reach thirty-two")
	check(Numbers.power_at_least("18446744073709551617") == "36893488147419103232", "Rounding remains exact beyond int64")
	check(not Numbers.valid_number("1e30") and not Numbers.valid_number("-2"), "Save accepts exact decimal integers only")
	var game = Numbers.new()
	game.save_path = "user://number_chain_test.json"
	DirAccess.remove_absolute(game.save_path)
	root.add_child(game)
	game.effects = false
	game.board.fill("4")
	game.board[2] = "8"
	game.select_cell(0)
	game.select_cell(1)
	game.select_cell(2)
	check(game.chain == [0, 1], "Different values cannot join a chain")
	game.select_cell(0)
	check(game.chain == [0], "Backtracking removes last tile")
	check(not game.adjacent(6, 7) and not game.adjacent(0, 0) and not game.adjacent(0, 16), "No wrap, self or distant selection")
	check(game.adjacent(0, 8) and game.adjacent(8, 0) and game.adjacent(6, 12) and game.adjacent(12, 6), "All diagonal directions allowed")
	game.select_cell(1)
	game.release_chain()
	check(game.score == "8" and game.board[1] == "8", "Sum remains at final selected bottom-independent location")
	check(game.board.size() == 49 and not game.board.has(""), "Gravity refills every cell")
	check(not game.busy and game.phase == 0, "Reduced effects finish synchronously")
	game.board.fill("2")
	game.board[42] = "1208925819614629174706176"
	game.board[43] = game.board[42]
	game.select_cell(42)
	game.select_cell(43)
	game.release_chain()
	check(game.board[43] == "2417851639229258349412352", "Merged value has no int64 cap")
	var expected: Array[String] = game.board.duplicate()
	game.save_progress()
	game.board.fill("2")
	check(game.load_progress() and game.board == expected, "Board and decimal values persist")
	game.board.fill("4")
	game.chain.assign([0, 1, 2])
	var score_before: String = game.score
	check(game.merge_result() == "16" and game.total() == "12", "Preview separates real sum from new power tile")
	game.release_chain()
	check(game.board[2] == "16" and game.score == Numbers.add(score_before, "12"), "Three fours create sixteen but award actual consumed total")
	for value in game.board: check(Numbers.power_at_least(value) == value, "Spawned and merged tiles remain binary powers")
	var old_board: Array[String] = []
	old_board.resize(49)
	old_board.fill("6")
	var old_file := FileAccess.open(game.save_path, FileAccess.WRITE)
	old_file.store_string(JSON.stringify({"version":1,"board":old_board,"score":"35","best":"40","largest":"12"}))
	old_file.close()
	check(game.load_progress() and game.board[0] == "8" and game.largest == "16" and game.score == "35", "Legacy arbitrary-number progress migrates without losing points")
	check(JSON.parse_string(FileAccess.get_file_as_string(game.save_path)).version == 2, "Migrated save uses new rule version")
	for i in 49: game.board[i] = str(i + 1)
	check(not game.has_move(), "Unique board has no moves")
	game.finish_fall()
	check(game.ended and game.board[0] == "1", "No moves ends round without restarting")
	game.ended = false
	game.board[8] = game.board[0]
	check(game.has_move(), "A diagonal-only pair keeps the round playable")
	game.select_cell(0)
	game.select_cell(8)
	check(game.chain == [0, 8], "Equal diagonal neighbors join the chain")
	game.select_cell(0)
	check(game.chain == [0], "Diagonal backtracking removes last tile")
	game.select_cell(8)
	game.release_chain()
	check(game.board[8] == "2", "Diagonal chain sums at final tile")
	for i in 49: game.board[i] = str(i + 1)
	game.board[12] = game.board[6]
	check(game.has_move(), "Opposite diagonal is detected as a legal move")
	DirAccess.remove_absolute(game.save_path)
	game.queue_free()
	if failures == 0: print("Number Chain: exact sums, selection, gravity, persistence and end state passed")
	quit(failures)
