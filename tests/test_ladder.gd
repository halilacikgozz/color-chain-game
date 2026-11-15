extends SceneTree
const Numbers = preload("res://scripts/number_chain.gd")
var failures := 0
func check(ok: bool,message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = Numbers.new()
	game.save_path = "user://ladder_chain_test.json"
	game.updates_auto_start = false
	DirAccess.remove_absolute(game.save_path)
	root.add_child(game)
	game.effects = false
	game.sound_on = false
	game.board.fill("64")
	game.board[0] = "2"
	game.board[1] = "2"
	game.board[7] = "4"
	game.board[13] = "8"
	game.board[6] = "16"
	game.board[14] = "2"
	game.select_cell(0)
	game.select_cell(6)
	check(game.chain == [0],"Different-tier pair cannot start a chain")
	game.select_cell(1)
	check(game.merge_result() == "4" and game.can_extend(7),"Two twos enable a neighboring four")
	game.select_cell(6)
	check(game.chain == [0,1],"Unrelated larger tiers are rejected")
	game.select_cell(7)
	check(game.chain == [0,1,7] and game.merge_result() == "8" and game.can_extend(13),"Two twos plus four enable eight")
	game.select_cell(1)
	check(game.chain == [0,1] and game.merge_result() == "4" and not game.can_extend(6),"Backtracking restores the previous allowed tier")
	game.select_cell(7)
	game.select_cell(13)
	game.select_cell(14)
	check(game.chain == [0,1,7,13] and game.merge_result() == "16","Growing chain rejects dropping back to small numbers")
	game.release_chain()
	check(game.board[13] == "16" and game.score == "16" and not game.busy,"2+2+4+8 merges into sixteen in one move")
	check(game.board.size() == 35 and not game.board.has(""),"Mixed-tier chain still collapses and refills")
	game.board.fill("2")
	game.chain.assign([0,1,6])
	game.select_cell(0)
	check(game.chain == [0,1,6],"A used square cannot be selected twice")
	game.chain.clear()
	game.select_cell(0)
	game.select_cell(1)
	game.select_cell(2)
	check(game.chain == [0,1,2] and game.merge_result() == "8","Existing same-number long chains remain supported")
	game.chain.clear()
	game.board.fill("64")
	game.board[0] = "2"
	game.board[1] = "2"
	game.board[7] = "4"
	game.board[13] = "8"
	var press := InputEventScreenTouch.new()
	press.index = 4
	press.position = game.center(0)
	press.pressed = true
	game._input(press)
	game.drag_to(game.center(1))
	game.drag_to(game.center(7))
	var other := InputEventScreenTouch.new()
	other.index = 5
	other.position = game.center(20)
	other.pressed = true
	game._input(other)
	check(game.pointer_id == 4 and game.chain == [0,1,7],"Second finger cannot reset a growing chain")
	var release := InputEventScreenTouch.new()
	release.index = 4
	release.position = game.center(13)
	release.pressed = false
	var before: String = game.score
	game._input(release)
	check(game.board[13] == "16" and game.score == Numbers.add(before,"16"),"Touch release captures final growing-tier diagonal")
	game.board.fill("2")
	var huge := "1208925819614629174706176"
	game.board[0] = huge
	game.board[1] = huge
	game.board[7] = Numbers.add(huge,huge)
	game.board[13] = Numbers.add(game.board[7],game.board[7])
	game.chain.clear()
	for i in [0,1,7,13]: game.select_cell(i)
	check(game.chain == [0,1,7,13] and game.merge_result() == "9671406556917033397649408","Growing tiers stay exact beyond int64")
	DirAccess.remove_absolute(game.save_path)
	game.queue_free()
	if failures == 0: print("Growing chains: 2+2+4+8, diagonal touch, preview, backtracking, tier rules and huge values passed")
	quit(failures)
