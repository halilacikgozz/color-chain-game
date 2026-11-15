extends SceneTree
var failures := 0
const Numbers = preload("res://scripts/number_chain.gd")
func check(ok: bool,message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/number_chain.tscn","App launches directly into numbers")
	check(Numbers.add("999999999999999999999999999999","1") == "1000000000000000000000000000000","Exact decimal carry beyond int64")
	check(Numbers.power_at_least("12") == "16" and Numbers.power_at_least("16") == "16","Long chains only produce powers of two")
	check(Numbers.power_at_least("18446744073709551617") == "36893488147419103232","No float rounding above int64")
	check(Numbers.ratio("500","1000") == 0.5 and Numbers.ratio("0","1000") == 0,"Goal gauge starts at zero and reaches halfway")
	check(absf(Numbers.ratio("5000000000000000000000000","10000000000000000000000000")-0.5) < 0.001,"Goal gauge handles huge scores")
	var game = Numbers.new()
	game.save_path = "user://number_chain_test_v3.json"
	game.updates_auto_start = false
	DirAccess.remove_absolute(game.save_path)
	root.add_child(game)
	game.effects = false
	game.sound_on = false
	check(game.board.size() == 35 and game.has_move(),"5 by 7 fresh board is playable")
	check(not game.adjacent(4,5) and not game.adjacent(0,0),"Rows do not wrap or select themselves")
	for pair in [[0,6],[6,0],[4,8],[8,4]]:
		game.board.fill("4")
		game.chain.clear()
		game.select_cell(pair[0])
		game.select_cell(pair[1])
		check(game.chain.size() == 2,"Diagonal direction is selectable")
	game.chain.clear()
	game.board.fill("4")
	game.board[1] = "8"
	game.select_cell(0)
	game.select_cell(1)
	check(game.chain == [0],"Unequal numbers cannot join")
	game.chain.clear()
	game.board.fill("4")
	game.pointer_down(game.center(0),3)
	game.drag_to(game.center(0)+Vector2(46,34))
	game.drag_to(game.center(6))
	check(game.chain == [0,6],"Diagonal drag ignores corners of side squares")
	game.select_cell(0)
	check(game.chain == [0],"Diagonal backtracking shortens chain")
	var release := InputEventScreenTouch.new()
	release.index = 3
	release.position = game.center(6)
	release.pressed = false
	var before: String = game.score
	game._input(release)
	check(game.score == Numbers.add(before,"8") and game.pointer_id == -2,"Final touch position is included for nonzero touch IDs")
	game.board.fill("4")
	game.chain.assign([0,1,2])
	check(game.merge_result() == "16" and game.total() == "12","Preview distinguishes total from resulting tier")
	before = game.score
	game.release_chain()
	check(game.board[2] == "16" and game.score == Numbers.add(before,"12"),"Three fours produce sixteen and twelve score")
	check(game.board.size() == 35 and not game.board.has(""),"Gravity fills every hole")
	game.board.fill("4")
	game.chain.assign([0,1])
	game.effects = true
	game.release_chain()
	game.cancel_pointer()
	check(game.chain == [0,1],"Focus changes preserve an in-flight merge")
	game.effects = false
	game.finish_merge()
	check(not game.busy,"Reduced effects settle completely")
	game.score = "998"
	game.goal = "1000"
	game.gems = 0
	game.board.fill("2")
	game.chain.assign([0,1])
	game.release_chain()
	check(game.score == "1002" and game.goal == "2000" and game.gems == 20,"Checkpoint awards twenty gems once and advances")
	game.advance_goal(true)
	check(game.gems == 20,"Checkpoint cannot be claimed twice")
	game.board.fill("4")
	game.gems = 90
	game.choose_tool("hammer")
	check(game.gems == 90,"Choosing a tool does not spend gems")
	game.apply_tool(0)
	check(game.gems == 75 and not game.board.has(""),"Hammer charges only when a square is removed and refilled")
	game.board.fill("4")
	var sorted_before: Array = game.board.duplicate()
	sorted_before.sort()
	game.choose_tool("shuffle")
	var sorted_after: Array = game.board.duplicate()
	sorted_after.sort()
	check(game.gems == 55 and sorted_before == sorted_after and game.has_move(),"Shuffle preserves stones and creates legal moves")
	for i in 35:
		var v := "2"
		for n in i: v = Numbers.add(v,v)
		game.board[i] = v
	var funds: int = game.gems
	game.choose_tool("shuffle")
	check(game.gems == funds,"Shuffle does not charge when no matching values exist")
	game.choose_tool("magnet")
	game.apply_tool(0)
	check(game.gems == funds,"Magnet does not charge for an unmatched square")
	game.board.fill("4")
	game.board[0] = "8"
	game.board[34] = "8"
	game.apply_tool(0)
	check(game.gems == funds-25 and game.board[0] == "16","Magnet merges distant equal squares at selected target")
	game.gems = 0
	game.choose_tool("hammer")
	check(game.active_tool.is_empty(),"Insufficient gems cannot activate a helper")
	for value in game.board: check(Numbers.power_at_least(value) == value,"All spawned squares retain binary tiers")
	game.board.fill("2")
	game.board[30] = "1208925819614629174706176"
	game.board[31] = game.board[30]
	game.chain.assign([30,31])
	game.release_chain()
	check(game.board[31] == "2417851639229258349412352","Very large merges remain exact")
	game.gems = 65
	game.save_progress()
	var expected: Array = game.board.duplicate()
	game.board.fill("2")
	check(game.load_progress() and game.board == expected and game.gems == 65,"Board, score and helper wallet persist")
	var legacy: Array = []
	legacy.resize(49)
	legacy.fill("6")
	var file := FileAccess.open(game.save_path,FileAccess.WRITE)
	file.store_string(JSON.stringify({"version":1,"board":legacy,"score":"35","best":"40","largest":"12"}))
	file.close()
	check(game.load_progress() and game.board.size() == 35 and game.reserve.size() == 14 and game.score == "35","49-cell save migrates to 35 with all leftover stones reserved")
	check(game.board[0] == "8" and game.reserve[0] == "8" and game.largest == "16","Legacy arbitrary values migrate to powers of two")
	check(game.spawn_value() == "8" and game.reserve.size() == 13,"Reserved old stones return on refill")
	for i in 35:
		var v := "2"
		for n in i: v = Numbers.add(v,v)
		game.board[i] = v
	check(not game.has_move(),"Distinct board has no moves")
	game.finish_fall()
	check(game.ended and game.board[0] == "2","No moves shows results without automatic restart")
	game.board[6] = game.board[0]
	check(game.has_move(),"Diagonal-only pair prevents false game over")
	var old_best: String = game.best
	funds = game.gems
	game.new_game()
	check(game.gems == funds and game.best == old_best,"New rounds preserve gems and best score")
	DirAccess.remove_absolute(game.save_path)
	game.queue_free()
	if failures == 0: print("Number game: direct launch, square board, diagonal touch, exact tiers, tools, goals and migrations passed")
	quit(failures)
