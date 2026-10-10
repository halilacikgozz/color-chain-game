extends Control
var game
var status: Label
var code_field: TextEdit
var create_button: Button
var restore_button: Button
var fetch_button: Button
var save_button: Button
var load_button: Button
var back_button: Button
var revision := -1
var cloud_record: Dictionary = {}
var linked := false
var waiting := false
var restore_confirm := false
var dirty := false
var retry_clock := 0.0
var pending_snapshot: Dictionary = {}
var code_shown := false
var auto_enabled := false
var bootstrap_done := false
var stored_revision := -1
var stored_owner := ""
var regenerate_confirm := false
var initial_save := false

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var background := ColorRect.new()
	background.color = Color("09281b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	add_label("HESAP VE BULUT KAYDI",Vector2(25,35),Vector2(430,48),27)
	add_label("Kurtarma kodunu sakla; yeni telefonda gir.\nKod hesabının anahtarıdır, kimseyle paylaşma.",Vector2(30,96),Vector2(420,60),17)
	code_field = TextEdit.new()
	code_field.position = Vector2(37,167)
	code_field.size = Vector2(406,92)
	code_field.placeholder_text = "Kurtarma kodu"
	code_field.add_theme_font_size_override("font_size",16)
	add_child(code_field)
	create_button = add_button("Hesabımı bağla • kod oluştur",276,create_account)
	restore_button = add_button("Kodla hesabıma gir",334,restore_account)
	status = add_label("Bulut kaydı henüz açılmadı.",Vector2(37,402),Vector2(406,80),16)
	fetch_button = add_button("Bulut kaydını kontrol et",494,fetch_cloud)
	save_button = add_button("Bu ilerlemeyi buluta kaydet",552,save_cloud)
	load_button = add_button("Buluttaki ilerlemeyi yükle",610,load_cloud)
	back_button = add_button("Geri dön",708,close)
	add_label("Bağladıktan sonra kayıt otomatik güncellenir.",Vector2(20,769),Vector2(440,24),13)
	visible = false
	var session: Dictionary = game.competition_client.session
	var user: Dictionary = session.get("user",{})
	linked = not bool(user.get("is_anonymous",true))
	var cfg := ConfigFile.new()
	if cfg.load(game.save_path) == OK:
		stored_revision = int(cfg.get_value("sync","revision",-1))
		stored_owner = str(cfg.get_value("sync","owner",""))

func add_label(value: String,pos: Vector2,dimensions: Vector2,font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.position = pos
	label.size = dimensions
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color("e3f4d4"))
	add_child(label)
	return label

func add_button(value: String,y: float,callback: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.position = Vector2(37,y)
	button.size = Vector2(406,48)
	button.add_theme_font_size_override("font_size",19)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("14864c")
	style.set_corner_radius_all(14)
	button.add_theme_stylebox_override("normal",style)
	button.pressed.connect(callback)
	add_child(button)
	return button

func open() -> void:
	if game.busy: return
	game.cancel_selection()
	game.account_open = true
	visible = true
	update_controls()
	if not waiting and game.competition_client.phase.is_empty(): fetch_cloud()

func close() -> void:
	if waiting: return
	visible = false
	game.account_open = false
	code_field.release_focus()
	game.queue_redraw()

func request(payload: Dictionary) -> bool:
	if waiting or not game.competition_client.phase.is_empty():
		status.text = "Bağlantı sürüyor; birazdan yeniden dene."
		return false
	waiting = true
	status.text = "Bağlanıyor…"
	update_controls()
	game.competition_client.send(payload)
	return true

func create_account() -> void:
	if linked and not regenerate_confirm:
		regenerate_confirm = true
		status.text = "Yeni kod oluşturursan önceki kod geçersiz olur.
Onaylamak için aynı düğmeye tekrar dokun."
		return
	regenerate_confirm = false
	if request({"action":"account_create"}): status.text = "Hesabın bağlanıyor…"

func restore_account() -> void:
	var code := code_field.text.strip_edges()
	if not code.begins_with("CC1.") or code.length() != 84:
		status.text = "Kurtarma kodunu eksiksiz gir."
		return
	if FileAccess.file_exists(game.save_path): DirAccess.copy_absolute(game.save_path,"user://progress-before-account.cfg")
	request({"action":"account_restore","code":code})

func fetch_cloud() -> void:
	restore_confirm = false
	request({"action":"cloud_get"})

func save_cloud() -> void:
	if not linked:
		status.text = "Önce hesabını bağla veya kodla giriş yap."
		return
	if revision < 0:
		status.text = "Önce bulut kaydını kontrol et."
		return
	pending_snapshot = game.progress_snapshot()
	auto_enabled = true
	request({"action":"cloud_save","revision":revision,"progress":pending_snapshot})

func load_cloud() -> void:
	if cloud_record.is_empty():
		status.text = "Yüklenecek bulut kaydı yok."
		return
	if not restore_confirm:
		restore_confirm = true
		load_button.text = "Onayla • bulut kaydını kullan"
		status.text = "Bu cihazın ilerlemesi değişecek.\nTur kapanacak; mevcut kayıt yedeklenecek."
		return
	if game.restore_snapshot(cloud_record):
		auto_enabled = true
		game.campaign_mode = false
		game.daily_mode = false
		game.timed_mode = false
		game.restart()
		game.open_home()
		dirty = false
		stored_revision = revision
		stored_owner = str(game.competition_client.session.get("user",{}).get("id",""))
		game.save_best()
		dirty = false
		status.text = "İlerleme yüklendi. Aynı yerden devam edebilirsin."
	else: status.text = "Kayıt yüklenemedi; cihaz kaydın korundu."
	restore_confirm = false
	load_button.text = "Buluttaki ilerlemeyi yükle"

func received(data: Dictionary) -> void:
	waiting = false
	match str(data.get("action","")):
		"account":
			linked = true
			auto_enabled = false
			revision = -1
			dirty = false
			initial_save = bool(data.get("created",false))
			if initial_save:
				code_field.text = str(data.get("recovery_code",""))
				code_field.editable = false
				code_shown = true
				status.text = "Kodunu şimdi güvenli bir yere kopyala.\nBulut kaydını kontrol edip ilk kaydını oluştur."
			else:
				code_field.text = ""
				code_field.editable = true
				status.text = "Giriş yapıldı. Bulut kaydını kontrol edip yükle."
		"cloud_get":
			linked = bool(data.get("linked",false))
			var record = data.get("record")
			if record is Dictionary:
				revision = int(record.get("revision",0))
				cloud_record = record.get("payload",{}).duplicate(true)
				var owner := str(game.competition_client.session.get("user",{}).get("id",""))
				auto_enabled = stored_owner == owner and stored_revision == revision
				dirty = auto_enabled and game.progress_snapshot() != cloud_record
				status.text = "Bulut: %d. seviye • %d kristal\nYüklemek için aşağıdaki düğmeye dokun." % [1+int(cloud_record.get("xp",0))/100,int(cloud_record.get("crystals",0))]
			else:
				revision = 0
				cloud_record.clear()
				auto_enabled = initial_save and linked
				dirty = auto_enabled
				initial_save = false
				status.text = "Bulut kaydı yok. Bu ilerlemeyi kaydedebilirsin." if linked else "Hesabını bağla; ilerlemeni telefonlar arasında taşı."
			var nickname := str(data.get("nickname",""))
			if not nickname.begins_with("Oyuncu "):
				game.player_name = nickname
		"cloud_save":
			if bool(data.get("conflict",false)):
				revision = -1
				auto_enabled = false
				status.text = "Diğer cihazın kaydı değişmiş.\nBulutu kontrol edip hangi kaydı kullanacağını seç."
			else:
				revision = int(data.get("revision",revision))
				cloud_record = pending_snapshot.duplicate(true)
				stored_revision = revision
				stored_owner = str(game.competition_client.session.get("user",{}).get("id",""))
				game.save_best()
				dirty = game.progress_snapshot() != pending_snapshot
				status.text = "İlerlemen buluta kaydedildi."
	update_controls()
	game.queue_redraw()

func failure(message: String) -> void:
	waiting = false
	status.text = message
	retry_clock = 15.0
	update_controls()

func update_controls() -> void:
	for button in [create_button,restore_button,fetch_button,save_button,load_button,back_button]: button.disabled = waiting
	create_button.disabled = waiting
	create_button.text = "Kurtarma kodunu yenile" if linked else "Hesabımı bağla • kod oluştur"
	save_button.disabled = waiting or not linked or revision < 0
	load_button.disabled = waiting or cloud_record.is_empty()

func mark_dirty() -> void:
	if linked and auto_enabled and revision >= 0:
		dirty = true
		retry_clock = 3.0

func _process(delta: float) -> void:
	retry_clock = maxf(0,retry_clock-delta)
	if linked and not bootstrap_done and game.competition_client.phase.is_empty():
		bootstrap_done = true
		fetch_cloud()
	if linked and auto_enabled and dirty and revision >= 0 and not waiting and retry_clock <= 0 and game.competition_client.phase.is_empty(): save_cloud()
