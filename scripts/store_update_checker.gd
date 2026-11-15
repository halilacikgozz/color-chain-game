extends Node
signal changed
const STORE_URL := "https://play.google.com/store/apps/details?id=com.halilacikgozz.colorchain"
var enabled := false
var auto_start := false
var current_code := 0
var current_name := "Geliştirme"
var latest_code := 0
var latest_name := ""
var notes: Array[String] = []
var checking := false
var manual := false
var status := "Güncellemeler Google Play üzerinden yapılır."
func _ready() -> void:
	if FileAccess.file_exists("res://build_info.json"):
		var info = JSON.parse_string(FileAccess.get_file_as_string("res://build_info.json"))
		if info is Dictionary:
			current_code = int(info.get("version_code",0))
			current_name = str(info.get("version_name","Geliştirme"))
func has_update() -> bool: return false
func should_prompt() -> bool: return false
func mark_prompted() -> void: pass
func dismiss() -> void: pass
func apply_manifest(_data: Variant) -> bool: return false
func check(_by_user: bool = false) -> void: changed.emit()
func open_store() -> Error: return OS.shell_open(STORE_URL)
func open_download() -> Error: return ERR_UNAVAILABLE
