extends Node
signal updated(data: Dictionary)
signal failed(message: String)
var config: Dictionary = {}
var session: Dictionary = {}
var pending: Dictionary = {}
var phase := ""
var request: HTTPRequest
var session_path := "user://competition_session.json"
func _ready() -> void:
	request = HTTPRequest.new()
	request.timeout = 15
	add_child(request)
	request.request_completed.connect(completed)
	if FileAccess.file_exists("res://competition.json"):
		var value = JSON.parse_string(FileAccess.get_file_as_string("res://competition.json"))
		if value is Dictionary: config = value
	if FileAccess.file_exists(session_path):
		var value = JSON.parse_string(FileAccess.get_file_as_string(session_path))
		if value is Dictionary: session = value
func configured() -> bool:
	return str(config.get("url", "")).begins_with("https://") and not str(config.get("key", "")).is_empty()
func send(payload: Dictionary) -> void:
	if not configured():
		failed.emit("Çevrimiçi lig sunucusu henüz bağlanmadı.")
		return
	if not phase.is_empty(): return
	if str(payload.get("action","")).begins_with("email_") and not bool(config.get("email_ready",false)):
		failed.emit("E-posta gönderimi henüz açılmadı.")
		return
	pending = payload
	if session.is_empty():
		phase = "signup"
		perform("/auth/v1/signup", {})
	elif float(session.get("expires_at",0)) < Time.get_unix_time_from_system() + 30:
		phase = "refresh"
		perform("/auth/v1/token?grant_type=refresh_token", {"refresh_token":session.get("refresh_token", "")})
	else:
		send_competition()
func perform(path: String, body: Dictionary, method: int = HTTPClient.METHOD_POST) -> void:
	var headers := PackedStringArray(["Content-Type: application/json", "apikey: " + str(config["key"])])
	if phase == "competition" or phase == "email_link": headers.append("Authorization: Bearer " + str(session.get("access_token", "")))
	var error := request.request(str(config["url"]).trim_suffix("/") + path, headers, method, JSON.stringify(body))
	if error != OK:
		phase = ""
		failed.emit("Bağlantı kurulamadı; yeniden dene.")
func send_competition() -> void:
	match str(pending.get("action","")):
		"email_link":
			phase = "email_link"
			perform("/auth/v1/user",{"email":pending["email"]},HTTPClient.METHOD_PUT)
		"email_login":
			phase = "email_login"
			perform("/auth/v1/otp",{"email":pending["email"],"create_user":false})
		"email_verify":
			phase = "email_verify"
			perform("/auth/v1/verify",{"email":pending["email"],"token":pending["token"],"type":pending["type"]})
		_:
			phase = "competition"
			perform("/functions/v1/competition", pending)
func completed(result: int, code: int, _headers: PackedStringArray, bytes: PackedByteArray) -> void:
	var value = JSON.parse_string(bytes.get_string_from_utf8())
	if result != HTTPRequest.RESULT_SUCCESS or code < 200 or code >= 300 or not value is Dictionary:
		phase = ""
		failed.emit(str(value.get("msg",value.get("error_description",value.get("error", "Bağlantı tamamlanamadı. İnternetini kontrol et.")))) if value is Dictionary else "Lig bağlantısı tamamlanamadı. İnternetini kontrol et.")
		return
	if phase == "signup" or phase == "refresh":
		session = value
		var file := FileAccess.open(session_path, FileAccess.WRITE)
		if file: file.store_string(JSON.stringify(session))
		send_competition()
	else:
		var completed_phase := phase
		phase = ""
		if completed_phase == "email_link" or completed_phase == "email_login":
			updated.emit({"action":"email_sent"})
		elif completed_phase == "email_verify":
			if str(value.get("access_token","")).is_empty():
				failed.emit("Doğrulama tamamlanmadı; e-postandaki diğer kodu kontrol et.")
			else:
				session = value
				if not session.has("expires_at"): session["expires_at"] = Time.get_unix_time_from_system()+float(session.get("expires_in",3600))
				var file := FileAccess.open(session_path,FileAccess.WRITE)
				if file: file.store_string(JSON.stringify(session))
				updated.emit({"action":"account","created":pending.get("type","")=="email_change"})
		else:
			updated.emit(value)
		pending.clear()
