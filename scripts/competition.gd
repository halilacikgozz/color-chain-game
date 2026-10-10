extends Node
signal updated(data: Dictionary)
signal failed(message: String)
var config: Dictionary = {}
var session: Dictionary = {}
var pending: Dictionary = {}
var phase := ""
var request: HTTPRequest
func _ready() -> void:
	request = HTTPRequest.new()
	request.timeout = 15
	add_child(request)
	request.request_completed.connect(completed)
	if FileAccess.file_exists("res://competition.json"):
		var value = JSON.parse_string(FileAccess.get_file_as_string("res://competition.json"))
		if value is Dictionary: config = value
	if FileAccess.file_exists("user://competition_session.json"):
		var value = JSON.parse_string(FileAccess.get_file_as_string("user://competition_session.json"))
		if value is Dictionary: session = value
func configured() -> bool:
	return str(config.get("url", "")).begins_with("https://") and not str(config.get("key", "")).is_empty()
func send(payload: Dictionary) -> void:
	if not configured():
		failed.emit("Çevrimiçi lig sunucusu henüz bağlanmadı.")
		return
	if not phase.is_empty(): return
	pending = payload
	if session.is_empty():
		phase = "signup"
		perform("/auth/v1/signup", {})
	elif float(session.get("expires_at",0)) < Time.get_unix_time_from_system() + 30:
		phase = "refresh"
		perform("/auth/v1/token?grant_type=refresh_token", {"refresh_token":session.get("refresh_token", "")})
	else:
		send_competition()
func perform(path: String, body: Dictionary) -> void:
	var headers := PackedStringArray(["Content-Type: application/json", "apikey: " + str(config["key"])])
	if phase == "competition": headers.append("Authorization: Bearer " + str(session.get("access_token", "")))
	var error := request.request(str(config["url"]).trim_suffix("/") + path, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		phase = ""
		failed.emit("Bağlantı kurulamadı; yeniden dene.")
func send_competition() -> void:
	phase = "competition"
	perform("/functions/v1/competition", pending)
func completed(result: int, code: int, _headers: PackedStringArray, bytes: PackedByteArray) -> void:
	var value = JSON.parse_string(bytes.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS or code < 200 or code >= 300 or not value is Dictionary:
		phase = ""
		failed.emit(str(value.get("error", "Lig bağlantısı tamamlanamadı. İnternetini kontrol et.")) if value is Dictionary else "Lig bağlantısı tamamlanamadı. İnternetini kontrol et.")
		return
	if phase == "signup" or phase == "refresh":
		session = value
		var file := FileAccess.open("user://competition_session.json", FileAccess.WRITE)
		if file: file.store_string(JSON.stringify(session))
		send_competition()
	else:
		phase = ""
		updated.emit(value)
