extends SceneTree
var failures := 0
func check(ok: bool,message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scripts/number_chain.gd").new()
	game.save_path = "user://store_game_test.json"
	game.distribution_store = true
	game.updates_auto_start = false
	DirAccess.remove_absolute(game.save_path)
	root.add_child(game)
	check(not game.updater.enabled and not game.updater.has_update(),"Play build disables external APK update checking")
	check(game.updater.get_child_count() == 0,"Play update provider creates no HTTP requests or polling timers")
	check(game.updater.open_download() == ERR_UNAVAILABLE,"Play build cannot download outside APK updates")
	check(not game.updater.apply_manifest({"version_code":999999}),"Outside APK release metadata is rejected")
	check(game.updater.STORE_URL == "https://play.google.com/store/apps/details?id=com.halilacikgozz.colorchain","Only own Google Play listing is used")
	game.sound_on = false
	game.effects = false
	game.board.fill("2")
	game.select_cell(0)
	game.select_cell(1)
	game.release_chain()
	check(game.score == "4" and game.board[1] == "4","Offline store game retains exact core mechanics")
	check(game.overlay.is_empty(),"Play build never prompts an APK update")
	DirAccess.remove_absolute(game.save_path)
	game.queue_free()
	if failures == 0: print("Play build: no external APK updates, no HTTP clients and offline gameplay passed")
	quit(failures)
