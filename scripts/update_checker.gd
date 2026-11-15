extends Node
signal changed
const BASE := "https://halilacikgozz.github.io/color-chain-game"
const PACKAGE := "com.halilacikgozz.colorchain"
const INTERVAL := 300.0
var enabled := OS.has_feature("android")
var auto_start := true
var manifest_url := BASE+"/update.json"
var preferences_path := "user://update_preferences_v1.cfg"
var current_code := 0
var current_name := "Geliştirme"
var latest_code := 0
var latest_name := ""
var notes: Array[String] = []
var checking := false
var manual := false
var last_check := -1000000.0
var status := ""
var dismissed_code := 0
var dismissed_until := 0.0
var prompted_code := 0
var request: HTTPRequest
var poll: Timer

func _ready() -> void:
	if FileAccess.file_exists("res://build_info.json"):
		var info = JSON.parse_string(FileAccess.get_file_as_string("res://build_info.json"))
		if info is Dictionary:
			current_code = int(info.get("version_code",0))
			current_name = str(info.get("version_name","Geliştirme"))
	var config := ConfigFile.new()
	if config.load(preferences_path) == OK:
		dismissed_code = int(config.get_value("update","dismissed_code",0))
		dismissed_until = float(config.get_value("update","dismissed_until",0.0))
	request = HTTPRequest.new()
	request.timeout = 10.0
	request.body_size_limit = 32768
	add_child(request)
	request.request_completed.connect(response_received)
	poll = Timer.new()
	poll.wait_time = INTERVAL
	add_child(poll)
	poll.timeout.connect(func(): check(false))
	if enabled and auto_start:
		poll.start()
		get_tree().create_timer(3.0).timeout.connect(func(): check(false))

func has_update() -> bool:
	return latest_code > current_code

func should_prompt() -> bool:
	if not has_update() or prompted_code == latest_code: return false
	return dismissed_code != latest_code or Time.get_unix_time_from_system() >= dismissed_until

func mark_prompted() -> void:
	prompted_code = latest_code

func dismiss() -> void:
	prompted_code = 0
	dismissed_code = latest_code
	dismissed_until = Time.get_unix_time_from_system()+86400.0
	var config := ConfigFile.new()
	config.set_value("update","dismissed_code",dismissed_code)
	config.set_value("update","dismissed_until",dismissed_until)
	config.save(preferences_path)

func check(by_user: bool = false) -> void:
	if checking: return
	manual = by_user
	if not enabled:
		status = "Güncelleme denetimi Android uygulamasında çalışır."
		changed.emit()
		return
	if not by_user and Time.get_ticks_msec()/1000.0-last_check < INTERVAL: return
	checking = true
	last_check = Time.get_ticks_msec()/1000.0
	status = "Güncellemeler denetleniyor…"
	changed.emit()
	var url := manifest_url+("&" if "?" in manifest_url else "?")+"t="+str(int(Time.get_unix_time_from_system()))
	var error := request.request(url,PackedStringArray(["Accept: application/json","Cache-Control: no-cache"]))
	if error != OK:
		checking = false
		status = "Bağlantı kurulamadı. Daha sonra yeniden deneyebilirsin."
		changed.emit()

func response_received(result: int,code: int,_headers: PackedStringArray,body: PackedByteArray) -> void:
	checking = false
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		status = "Güncelleme denetlenemedi. Oynamaya devam edebilirsin."
		changed.emit()
		return
	if not apply_manifest(JSON.parse_string(body.get_string_from_utf8())):
		status = "Güncelleme bilgisi doğrulanamadı. Daha sonra yeniden dene."
	changed.emit()

func apply_manifest(data: Variant) -> bool:
	if not data is Dictionary or data.get("schema") != 1 or data.get("package_id") != PACKAGE: return false
	var version = data.get("version_code")
	if not (version is int or version is float): return false
	if version < 1 or version > 2100000000 or version != int(version): return false
	var name = data.get("version_name")
	if not name is String or name.length() > 32 or not name.begins_with("1.0.") or name != "1.0."+str(int(version)): return false
	# Never navigate to a remotely supplied arbitrary host or install anything silently.
	if data.get("download_url") != BASE+"/downloads/color-chain.apk": return false
	var release_notes = data.get("notes",[])
	if not release_notes is Array or release_notes.size() > 5: return false
	for line in release_notes:
		if not line is String or line.length() > 180 or "\n" in line or "\r" in line: return false
	if int(version) > current_code and int(version) >= latest_code:
		latest_code = int(version)
		latest_name = name
		notes.assign(release_notes)
	if has_update(): status = "Yeni sürüm hazır: "+latest_name
	else: status = "Güncel sürümü kullanıyorsun."
	return true

func download_url() -> String:
	return BASE+"/downloads/color-chain.apk?v="+str(latest_code)

func open_download() -> Error:
	if not enabled or not has_update(): return ERR_UNAVAILABLE
	return OS.shell_open(download_url())

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and is_node_ready() and enabled and auto_start: check(false)
