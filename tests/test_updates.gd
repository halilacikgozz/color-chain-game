extends SceneTree
var failures := 0
const Checker = preload("res://scripts/update_checker.gd")
func check(ok: bool,message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func payload(code: int) -> Dictionary:
	return {"schema":1,"package_id":Checker.PACKAGE,"version_code":code,"version_name":"1.0."+str(code),"download_url":Checker.BASE+"/downloads/color-chain.apk","notes":["Yeni sürüm"]}
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var client = Checker.new()
	client.auto_start = false
	client.preferences_path = "user://update_checker_test.cfg"
	DirAccess.remove_absolute(client.preferences_path)
	root.add_child(client)
	client.current_code = 142
	client.current_name = "1.0.142"
	check(client.apply_manifest(payload(142)) and not client.has_update(),"Current build never prompts to reinstall itself")
	check(client.apply_manifest(payload(141)) and not client.has_update(),"Older build never offered as an update")
	check(client.apply_manifest(payload(143)) and client.has_update() and client.should_prompt(),"New build offered to installed older build")
	check(client.download_url() == Checker.BASE+"/downloads/color-chain.apk?v=143","Download stays on canonical HTTPS APK")
	client.apply_manifest(payload(141))
	check(client.latest_code == 143,"Cached older metadata cannot remove a known newer version")
	var invalid := payload(144)
	invalid.package_id = "some.other.game"
	check(not client.apply_manifest(invalid) and client.latest_code == 143,"Other packages are rejected")
	invalid = payload(144)
	invalid.download_url = "https://example.com/app.apk"
	check(not client.apply_manifest(invalid),"Remote arbitrary download hosts are rejected")
	invalid = payload(144)
	invalid.version_code = 144.5
	check(not client.apply_manifest(invalid),"Fractional version codes are rejected")
	invalid = payload(144)
	invalid.notes = ["malformed\nline"]
	check(not client.apply_manifest(invalid),"Malformed release-note format rejected")
	client.mark_prompted()
	check(not client.should_prompt(),"One automatic popup per build per session")
	client.dismiss()
	client.prompted_code = 0
	check(not client.should_prompt(),"Later defers same version for twenty-four hours")
	client.dismissed_until = Time.get_unix_time_from_system()-1.0
	check(client.should_prompt(),"Notification returns after deferral expires even without restarting")
	client.dismiss()
	var restored = Checker.new()
	restored.auto_start = false
	restored.preferences_path = client.preferences_path
	root.add_child(restored)
	restored.current_code = 142
	restored.apply_manifest(payload(143))
	check(not restored.should_prompt(),"Deferral survives app restart")
	restored.apply_manifest(payload(144))
	check(restored.should_prompt(),"A newer release is not hidden by previous-version deferral")
	client.response_received(HTTPRequest.RESULT_CANT_CONNECT,0,PackedStringArray(),PackedByteArray())
	check(not client.checking and client.has_update(),"Offline check preserves known release without blocking play")
	client.response_received(HTTPRequest.RESULT_SUCCESS,200,PackedStringArray(),"not-json".to_utf8_buffer())
	check(client.latest_code == 143,"Invalid response cannot replace validated metadata")
	# Exercise the same asynchronous HTTPRequest path against a local CI fixture.
	var network = Checker.new()
	network.auto_start = false
	network.enabled = true
	network.preferences_path = "user://update_checker_network_test.cfg"
	network.manifest_url = "http://127.0.0.1:8765/update.json"
	root.add_child(network)
	network.current_code = 142
	network.check(true)
	if network.checking: await network.request.request_completed
	check(network.has_update() and network.latest_code == 143 and network.manual,"Real HTTP response reaches release comparison and UI state")
	# The game holds notifications until a drag or falling animation has finished.
	var game = load("res://scripts/number_chain.gd").new()
	game.save_path = "user://update_ui_game_test.json"
	game.updates_auto_start = false
	DirAccess.remove_absolute(game.save_path)
	root.add_child(game)
	game.updater.current_code = 142
	game.updater.current_name = "1.0.142"
	game.updater.apply_manifest(payload(143))
	game.update_state_changed()
	game.dragging = true
	game.show_pending_update()
	check(game.overlay.is_empty(),"Update cannot interrupt a drag")
	game.dragging = false
	game.busy = true
	game.show_pending_update()
	check(game.overlay.is_empty(),"Update cannot interrupt falling squares")
	game.busy = false
	game.show_pending_update()
	check(game.overlay == "update","Notification opens once game is idle")
	game.overlay_press(Vector2(240,640))
	check(game.overlay.is_empty() and not game.update_requested,"Later closes the notification and returns to game")
	game.overlay = "settings"
	game.overlay_press(Vector2(240,625))
	check(game.overlay == "update","Manual settings entry still opens a deferred update")
	DirAccess.remove_absolute(game.save_path)
	DirAccess.remove_absolute(client.preferences_path)
	DirAccess.remove_absolute(network.preferences_path)
	game.queue_free()
	client.queue_free()
	restored.queue_free()
	network.queue_free()
	if failures == 0: print("Update checks: versions, trusted download, deferral, offline, real HTTP and safe UI timing passed")
	quit(failures)
