extends Control
var game
var status: Label
var code_field: LineEdit
var email_field: LineEdit
var verify_button: Button
var otp_type := "email"
var otp_email := ""
var email_ready := false
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
var auto_enabled := false
var bootstrap_done := false
var stored_revision := -1
var stored_owner := ""
var initial_save := false

func _ready() -> void:
	size = Vector2(480,800)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var background := ColorRect.new()
	background.color = Color("09281b")
	background.size = Vector2(480,800)
	add_child(background)
	add_label("HESAP VE BULUT KAYDI",Vector2(25,25),Vector2(430,48),27)
	add_label("İlerlemeni e-postana bağla.\nYeni telefonda aynı e-postayla giriş yap.",Vector2(30,79),Vector2(420,54),17)
	email_field = LineEdit.new()
	email_field.position = Vector2(37,143)
	email_field.size = Vector2(406,48)
	email_field.placeholder_text = "E-posta adresin"
	email_field.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_EMAIL_ADDRESS
	email_field.add_theme_font_size_override("font_size",20)
	add_child(email_field)
	code_field = LineEdit.new()
	code_field.position = Vector2(37,205)
	code_field.size = Vector2(406,48)
	code_field.placeholder_text = "E-postadaki doğrulama kodu"
	code_field.max_length = 8
	code_field.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	code_field.add_theme_font_size_override("font_size",20)
	add_child(code_field)
	create_button = add_button("İlerlememi e-postaya bağla",272,create_account)
	restore_button = add_button("Mevcut hesabıma giriş yap",330,restore_account)
	verify_button = add_button("Kodu doğrula",388,verify_email)
	status = add_label("E-posta gönderimi hazırlanıyor.",Vector2(37,449),Vector2(406,70),16)
	fetch_button = add_button("Bulut kaydını kontrol et",528,fetch_cloud)
	save_button = add_button("Bu ilerlemeyi buluta kaydet",584,save_cloud)
	load_button = add_button("Buluttaki ilerlemeyi yükle",640,load_cloud)
	back_button = add_button("Geri dön",710,close)
	add_label("Hesap bağlandıktan sonra kayıt otomatik güncellenir.",Vector2(20,772),Vector2(440,24),12)
	email_ready = bool(game.competition_client.config.get("email_ready",false))
	visible = false
	var session: Dictionary = game.competition_client.session
	var user: Dictionary = session.get("user",{})
	linked = not bool(user.get("is_anonymous",true)) and not str(user.get("email","")).ends_with(".invalid")
	email_field.text = str(user.get("email","")) if linked else ""
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

func valid_email(value: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")
	return value.length() <= 254 and regex.search(value) != null

func start_email(link_account: bool) -> void:
	if not email_ready:
		status.text = "E-posta gönderimi henüz açılmadı.
Bu cihazdaki ilerlemen korunuyor."
		return
	var address := email_field.text.strip_edges().to_lower()
	if not valid_email(address):
		status.text = "Geçerli bir e-posta adresi gir."
		return
	if linked and link_account:
		status.text = "Hesabın zaten e-postana bağlı."
		return
	otp_email = address
	otp_type = "email_change" if link_account else "email"
	request({"action":"email_link" if link_account else "email_login","email":address})

func create_account() -> void:
	start_email(true)

func restore_account() -> void:
	start_email(false)

func verify_email() -> void:
	var token := code_field.text.strip_edges()
	if otp_email.is_empty() or token.length() < 6 or not token.is_valid_int():
		status.text = "Önce e-postana kod gönder, sonra gelen kodu gir."
		return
	if FileAccess.file_exists(game.save_path): DirAccess.copy_absolute(game.save_path,"user://progress-before-account.cfg")
	request({"action":"email_verify","email":otp_email,"token":token,"type":otp_type})

func fetch_cloud() -> void:
	restore_confirm = false
	request({"action":"cloud_get"})

func save_cloud() -> void:
	if not linked:
		status.text = "Önce hesabını e-postana bağla veya giriş yap."
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
		"email_sent":
			status.text = "E-postanı kontrol et ve gelen kodu gir.\nGörünmüyorsa gereksiz posta klasörüne de bak."
		"account":
			linked = true
			auto_enabled = false
			revision = -1
			dirty = false
			initial_save = bool(data.get("created",false))
			code_field.text = ""
			otp_email = ""
			bootstrap_done = false
			status.text = "E-posta doğrulandı. Bulut kaydı kontrol ediliyor."
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
				status.text = "Bulut kaydı yok. Bu ilerlemeyi kaydedebilirsin." if linked else "Hesabını e-postana bağla; ilerlemeni telefonlar arasında taşı."
			if not email_ready: status.text = "E-posta gönderimi henüz açılmadı.\nBu cihazdaki ilerlemen korunuyor."
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
	for button in [create_button,restore_button,verify_button,fetch_button,save_button,load_button,back_button]: button.disabled = waiting
	create_button.disabled = waiting or linked or not email_ready
	restore_button.disabled = waiting or not email_ready
	verify_button.disabled = waiting or otp_email.is_empty() or not email_ready
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
