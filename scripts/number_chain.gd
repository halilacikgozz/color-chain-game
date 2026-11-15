extends Node2D
# Decimal strings keep every digit; neither floating point nor int64 stores values.
const SIDE := 7
const ORIGIN := Vector2(37, 220)
const STEP := 58.0
const SAVE := "user://number_chain_v1.json"
const COLORS := [Color("67d5b5"), Color("ffd384"), Color("b5a0f5"), Color("f79fae"), Color("80c5ef")]
var board: Array[String] = []
var chain: Array[int] = []
var score := "0"
var best := "0"
var largest := "2"
var ended := false
var busy := false
var dragging := false
var phase := 0
var elapsed := 0.0
var motions: Array[Dictionary] = []
var effects := true
var save_path := SAVE
var rng := RandomNumberGenerator.new()
var font := ThemeDB.fallback_font
var message := "Aynı sayıları sürükle • En az 2 taş"

static func valid_number(s: String, zero_ok: bool = false) -> bool:
	if s.is_empty() or (s.length() > 1 and s.begins_with("0")): return false
	for c in s:
		if c < "0" or c > "9": return false
	return zero_ok or s != "0"

static func add(a: String, b: String) -> String:
	var i := a.length() - 1
	var j := b.length() - 1
	var carry := 0
	var out := ""
	while i >= 0 or j >= 0 or carry > 0:
		var total := carry
		if i >= 0: total += a.unicode_at(i) - 48
		if j >= 0: total += b.unicode_at(j) - 48
		out = str(total % 10) + out
		carry = total / 10
		i -= 1
		j -= 1
	return out

static func greater(a: String, b: String) -> bool:
	return a.length() > b.length() or (a.length() == b.length() and a > b)

static func compact(s: String) -> String:
	if s.length() <= 4: return s
	var group: int = (s.length() - 1) / 3
	var head := s.length() - group * 3
	var suffixes := ["", "K", "M", "B", "T", "Qa", "Qi"]
	var suffix: String = suffixes[group] if group < suffixes.size() else "e" + str(group * 3)
	var fraction := s.substr(head, mini(2, s.length() - head)).trim_suffix("0").trim_suffix("0")
	var shown := s.substr(0, head) + ("," + fraction if not fraction.is_empty() else "") + suffix
	var tail := s.substr(head + 2)
	return ("≈" if not tail.is_empty() and tail.replace("0", "") != "" else "") + shown

func _ready() -> void:
	rng.randomize()
	var config := ConfigFile.new()
	if config.load("user://color_chain.cfg") == OK: effects = bool(config.get_value("settings", "effects", true))
	if not load_progress(): new_game()
	queue_redraw()

func new_game() -> void:
	board.clear()
	for i in 49: board.append(["2", "2", "4", "4", "8"][rng.randi_range(0, 4)])
	board[1] = board[0]
	score = "0"
	largest = "8"
	ended = false
	busy = false
	phase = 0
	chain.clear()
	motions.clear()
	message = "Aynı sayıları sürükle • En az 2 taş"
	save_progress()
	queue_redraw()

func adjacent(a: int, b: int) -> bool:
	return absi(a % SIDE - b % SIDE) + absi(a / SIDE - b / SIDE) == 1

func center(i: int) -> Vector2:
	return ORIGIN + Vector2(i % SIDE, i / SIDE) * STEP + Vector2.ONE * STEP / 2.0

func cell_at(p: Vector2) -> int:
	if not Rect2(ORIGIN, Vector2.ONE * SIDE * STEP).has_point(p): return -1
	var q := (p - ORIGIN) / STEP
	return int(q.y) * SIDE + int(q.x)

func select_cell(i: int) -> void:
	if i < 0 or i >= 49 or busy or ended: return
	if chain.is_empty(): chain.append(i)
	elif chain.size() > 1 and i == chain[chain.size() - 2]: chain.pop_back()
	elif not chain.has(i) and adjacent(chain.back(), i) and board[i] == board[chain[0]]: chain.append(i)
	queue_redraw()

func total() -> String:
	var sum := "0"
	for i in chain: sum = add(sum, board[i])
	return sum

func has_move() -> bool:
	for i in 49:
		if i % SIDE < 6 and board[i] == board[i + 1]: return true
		if i < 42 and board[i] == board[i + SIDE]: return true
	return false

func release_chain() -> void:
	dragging = false
	if chain.size() < 2:
		if chain.size() == 1: show_exact(board[chain[0]])
		chain.clear()
		queue_redraw()
		return
	busy = true
	phase = 1
	elapsed = 0.0
	motions.clear()
	for i in chain:
		motions.append({"value":board[i], "from":center(i), "to":center(chain.back())})
	if not effects: finish_merge()
	queue_redraw()

func show_exact(value: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Taşın tam değeri"
	dialog.ok_button_text = "Tamam"
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(320, 120)
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_ANYWHERE
	label.custom_minimum_size.x = 300
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(label)
	dialog.add_child(scroll)
	add_child(dialog)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(350, 180))

func finish_merge() -> void:
	var result := total()
	var target: int = chain.back()
	for i in chain: board[i] = ""
	board[target] = result
	score = add(score, result)
	if greater(score, best): best = score
	if greater(result, largest): largest = result
	message = str(chain.size()) + " taş → " + compact(result)
	chain.clear()
	motions.clear()
	# Collapse bottom-up. Each retained stone keeps its value and column order.
	for col in SIDE:
		var write := 6
		for row in range(6, -1, -1):
			var source := row * SIDE + col
			if board[source].is_empty(): continue
			var destination := write * SIDE + col
			var value := board[source]
			board[source] = ""
			board[destination] = value
			motions.append({"value":value, "from":center(source), "to":center(destination)})
			write -= 1
		for row in range(write, -1, -1):
			var destination := row * SIDE + col
			var value := spawn_value()
			board[destination] = value
			motions.append({"value":value, "from":center(destination) - Vector2(0, (write + 1) * STEP), "to":center(destination)})
	phase = 2
	elapsed = 0.0
	if not effects: finish_fall()

func spawn_value() -> String:
	# Occasionally supply an existing value's mate, including large stones.
	var pool: Array[String] = ["2", "2", "4", "4", "8"]
	if rng.randf() < 0.22:
		var live: Array[String] = []
		for v in board:
			if not v.is_empty(): live.append(v)
		if not live.is_empty(): return live[rng.randi_range(0, live.size() - 1)]
	return pool[rng.randi_range(0, pool.size() - 1)]

func finish_fall() -> void:
	busy = false
	phase = 0
	motions.clear()
	ended = not has_move()
	save_progress()
	queue_redraw()

func _process(delta: float) -> void:
	if not busy: return
	elapsed += delta
	if phase == 1 and elapsed >= 0.18: finish_merge()
	elif phase == 2 and elapsed >= 0.26: finish_fall()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.canceled:
			dragging = false
			chain.clear()
			queue_redraw()
		elif event.pressed: pointer_down(event.position)
		else: release_if_dragging()
	elif event is InputEventScreenDrag and event.index == 0 and dragging: select_cell(cell_at(event.position))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: pointer_down(event.position)
		else: release_if_dragging()
	elif event is InputEventMouseMotion and dragging: select_cell(cell_at(event.position))

func release_if_dragging() -> void:
	if dragging: release_chain()

func pointer_down(p: Vector2) -> void:
	if busy: return
	if Rect2(28, 22, 90, 40).has_point(p):
		save_progress()
		get_tree().change_scene_to_file("res://scenes/main.tscn")
		return
	if Rect2(37, 725, 406, 48).has_point(p):
		var confirm := ConfirmationDialog.new()
		confirm.dialog_text = "Mevcut tur bitsin ve yeni oyun başlasın mı?"
		confirm.ok_button_text = "Yeni oyun"
		confirm.cancel_button_text = "Vazgeç"
		add_child(confirm)
		confirm.confirmed.connect(func(): new_game(); confirm.queue_free())
		confirm.canceled.connect(confirm.queue_free)
		confirm.popup_centered()
		return
	if ended:
		if Rect2(80, 460, 320, 54).has_point(p): new_game()
		return
	dragging = true
	chain.clear()
	select_cell(cell_at(p))

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		dragging = false
		if not busy: chain.clear()
		queue_redraw()

func save_progress() -> void:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"version":1,"board":board,"score":score,"best":best,"largest":largest}))

func load_progress() -> bool:
	if not FileAccess.file_exists(save_path): return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(save_path))
	if not data is Dictionary or data.get("version") != 1: return false
	if not data.get("board") is Array or data.board.size() != 49: return false
	for value in data.board:
		if not value is String or not valid_number(value): return false
	for key in ["score", "best", "largest"]:
		if not data.get(key) is String or not valid_number(data[key], key != "largest"): return false
	board.assign(data.board)
	score = data.score
	best = data.best
	largest = data.largest
	ended = not has_move()
	return true

func panel(rect: Rect2, color: Color, radius: int = 16) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	draw_style_box(style, rect)

func label(value: String, p: Vector2, size: int, color: Color = Color("e8f4dd")) -> void:
	var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(font, p - Vector2(width / 2.0, 0), value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func stone(value: String, p: Vector2, selected: bool = false) -> void:
	var color: Color = COLORS[posmod(value.hash(), COLORS.size())]
	draw_circle(p + Vector2(0, 3), 25, Color("09271e"))
	draw_circle(p, 25, color)
	draw_arc(p, 23, PI, TAU, 18, Color(1, 1, 1, 0.35), 2, true)
	if selected: draw_arc(p, 27, 0, TAU, 32, Color("f9f3ce"), 3, true)
	var shown := compact(value)
	var size := 21
	while size > 10 and font.get_string_size(shown, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > 45: size -= 1
	label(shown, p + Vector2(0, size * 0.35), size, Color("18352e"))

func _draw() -> void:
	draw_rect(Rect2(0, 0, 480, 800), Color("09281b"))
	label("‹ Menü", Vector2(70, 49), 17)
	label("SAYI ZİNCİRİ", Vector2(290, 48), 27)
	panel(Rect2(37, 76, 197, 71), Color("163d2d"))
	panel(Rect2(246, 76, 197, 71), Color("163d2d"))
	label("PUAN", Vector2(135, 99), 12, Color("a5c8b3"))
	label(compact(score), Vector2(135, 132), 26)
	label("EN İYİ", Vector2(345, 99), 12, Color("a5c8b3"))
	label(compact(best), Vector2(345, 132), 26, Color("ffd384"))
	if chain.size() >= 2:
		label(str(chain.size()) + " × " + compact(board[chain[0]]) + " = " + compact(total()), Vector2(240, 183), 24, Color("ffd384"))
	else: label("Aynı sayıları birleştir, toplamı büyüt", Vector2(240, 181), 17)
	label("Yalnızca yatay ve dikey komşular", Vector2(240, 205), 13, Color("a5c8b3"))
	panel(Rect2(31, 214, 418, 418), Color("123426"), 20)
	if phase == 2:
		var t := 1.0 - pow(1.0 - minf(elapsed / 0.26, 1.0), 3)
		for m in motions: stone(m.value, m.from.lerp(m.to, t))
	else:
		if chain.size() >= 2:
			var points := PackedVector2Array()
			for i in chain: points.append(center(i))
			draw_polyline(points, Color("e7eac2"), 7, true)
		for i in board.size():
			if phase == 1 and chain.has(i): continue
			stone(board[i], center(i), chain.has(i))
		if phase == 1:
			var t := minf(elapsed / 0.18, 1.0)
			for m in motions: stone(m.value, m.from.lerp(m.to, t), true)
	label(message, Vector2(240, 660), 17, Color("cbe0c5"))
	label("En büyük taş: " + compact(largest) + " • Üst sınır yok", Vector2(240, 690), 15, Color("ffd384"))
	label("Tam değeri görmek için bir taşa dokun", Vector2(240, 712), 12, Color("a5c8b3"))
	panel(Rect2(37, 725, 406, 48), Color("246c47"))
	label("Yeni oyun", Vector2(240, 756), 20)
	if ended:
		draw_rect(Rect2(0, 0, 480, 800), Color(0.01, 0.07, 0.04, 0.86))
		panel(Rect2(52, 252, 376, 300), Color("1d4833"), 24)
		label("HAMLE KALMADI", Vector2(240, 307), 27, Color("ffd384"))
		label("Bu turdaki puanın", Vector2(240, 351), 18)
		label(compact(score), Vector2(240, 398), 36)
		label("En büyük taş: " + compact(largest), Vector2(240, 431), 18)
		panel(Rect2(80, 460, 320, 54), Color("308553"))
		label("Yeni oyun başlat", Vector2(240, 495), 22)
		label("Menüye dönmek için sol üstteki oka dokun", Vector2(240, 535), 12)
