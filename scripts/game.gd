extends Node2D

const BOMB := 1
const LIGHTNING := 2
const SIDE := 7
const CELL := 58.0
const ORIGIN := Vector2(37, 230)
const COLORS := [Color("ff6584"), Color("58d8ce"), Color("ffd166"), Color("9381ff")]
const PALETTES := [
	[Color("ff6584"), Color("58d8ce"), Color("ffd166"), Color("9381ff")],
	[Color("ff75dd"), Color("70f6ff"), Color("c7ff77"), Color("ae95ff")],
	[Color("ff968a"), Color("8ed6b1"), Color("ffe4a1"), Color("b7acff")]
]
const THEME_NAMES := ["Klasik", "Neon", "Pastel"]
const THEME_COSTS := [0, 3, 6]
const PROFILE_BUTTON := Rect2(37, 60, 406, 25)
const PROFILE_BACK := Rect2(37, 710, 406, 56)
const QUESTS := [
	{"kind": "chain", "target": 3, "title": "İlk adım: 3 taş bağla"},
	{"kind": "moves", "target": 5, "title": "5 başarılı zincir yap"},
	{"kind": "chain", "target": 5, "title": "Tek zincirde 5 taş bağla"},
	{"kind": "combo", "target": 3, "title": "Kombo x3'e ulaş"},
	{"kind": "points", "target": 500, "title": "Toplam 500 puan kazan"},
	{"kind": "chain", "target": 7, "title": "Tek zincirde 7 taş bağla"},
	{"kind": "tiles", "target": 80, "title": "Toplam 80 taş temizle"},
	{"kind": "combo", "target": 4, "title": "Kombo x4'e ulaş"}
]
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const RESTART := Rect2(100, 690, 280, 52)
const MODE_BUTTON := Rect2(37, 754, 195, 32)
const EFFECTS_BUTTON := Rect2(248, 754, 195, 32)
const ROUND_SECONDS := 60.0
const COMBO_WINDOW := 4.0
var board: Array[int] = []
var chain: Array[int] = []
var offsets: Array[float] = []
var specials: Array[int] = []
var clear_cells: Array[int] = []
var resolution_active := false
var reward_anchor := -1
var reward_kind := 0
var special_waves: Array[Dictionary] = []
var score := 0
var best := 0
var timed_best := 0
var xp := 0
var stars := 0
var quests_done := 0
var quest_progress := 0
var theme_index := 0
var profile_open := false
var round_xp := 0
var palette: Array = PALETTES[0]
var save_path := "user://color_chain.cfg"
var dragging := false
var pointer := -2
var busy := false
var message := "Sürükle ve ilk zincirinle turu başlat!"
var fall_tween: Tween
var rng := RandomNumberGenerator.new()
var font: Font = ThemeDB.fallback_font
var fall_progress := 0.0
var pop_progress := 0.0
var popping: Array[int] = []
var particles: Array[Dictionary] = []
var floaters: Array[Dictionary] = []
var timed_mode := true
var effects := true
var started := false
var ended := false
var focused := true
var remaining := ROUND_SECONDS
var combo := 0
var combo_left := 0.0
var elapsed := 0.0
var impact := 0.0
var longest := 0
var moves := 0

func _ready() -> void:
	rng.randomize()
	load_progress()
	restart()

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(save_path) != OK:
		return
	best = maxi(0, int(config.get_value("game", "best", 0)))
	timed_best = maxi(0, int(config.get_value("progress", "timed_best", 0)))
	xp = maxi(0, int(config.get_value("progress", "xp", 0)))
	stars = maxi(0, int(config.get_value("progress", "stars", 0)))
	quests_done = maxi(0, int(config.get_value("progress", "quests_done", 0)))
	quest_progress = clampi(int(config.get_value("progress", "quest_progress", 0)), 0, quest_target() - 1)
	theme_index = clampi(int(config.get_value("progress", "theme", 0)), 0, PALETTES.size() - 1)
	if stars < THEME_COSTS[theme_index]:
		theme_index = 0
	palette = PALETTES[theme_index]

func save_best() -> void:
	var config := ConfigFile.new()
	config.set_value("game", "best", best)
	config.set_value("progress", "timed_best", timed_best)
	config.set_value("progress", "xp", xp)
	config.set_value("progress", "stars", stars)
	config.set_value("progress", "quests_done", quests_done)
	config.set_value("progress", "quest_progress", quest_progress)
	config.set_value("progress", "theme", theme_index)
	config.save(save_path)

func player_level() -> int:
	return 1 + xp / 100

func quest_target() -> int:
	var base: int = QUESTS[quests_done % QUESTS.size()]["target"]
	var cycle := quests_done / QUESTS.size()
	var kind: String = QUESTS[quests_done % QUESTS.size()]["kind"]
	if kind == "combo":
		return mini(5, base + cycle)
	if kind == "chain":
		return mini(10, base + cycle)
	return base + cycle * maxi(5, base / 2)

func quest_title() -> String:
	var kind: String = QUESTS[quests_done % QUESTS.size()]["kind"]
	var target := quest_target()
	match kind:
		"chain": return "%d taşı tek zincirde bağla" % target
		"moves": return "%d başarılı zincir yap" % target
		"combo": return "Kombo x%d'e ulaş" % target
		"points": return "Toplam %d puan kazan" % target
		_: return "Toplam %d taş temizle" % target

func update_progress(count: int, gained: int) -> void:
	var old_level := player_level()
	var earned := count * 3 + combo * 2
	xp += earned
	round_xp += earned
	if timed_mode:
		timed_best = maxi(timed_best, score)
	var kind: String = QUESTS[quests_done % QUESTS.size()]["kind"]
	match kind:
		"chain": quest_progress = maxi(quest_progress, count)
		"combo": quest_progress = maxi(quest_progress, combo)
		"moves": quest_progress += 1
		"points": quest_progress += gained
		"tiles": quest_progress += count
	if quest_progress >= quest_target():
		stars += 1
		quests_done += 1
		quest_progress = 0
		xp += 30
		round_xp += 30
		message = "Görev tamam! +1 yıldız • +30 deneyim"
		if stars == 3 or stars == 6:
			message = "%s teması açıldı! Hedefler'e dokun." % ("Neon" if stars == 3 else "Pastel")
	elif player_level() > old_level:
		message = "Seviye %d! Yeni hedefe devam et." % player_level()
	save_best()

func choose_theme(index: int) -> bool:
	if index < 0 or index >= PALETTES.size() or stars < THEME_COSTS[index]:
		return false
	theme_index = index
	palette = PALETTES[index]
	save_best()
	queue_redraw()
	return true

func medal(value: int) -> String:
	if value >= 1500: return "ELMAS"
	if value >= 750: return "ALTIN"
	if value >= 300: return "GÜMÜŞ"
	if value >= 100: return "BRONZ"
	return "ÇAYLAK"

func next_medal(value: int) -> String:
	if value < 100: return "Bronz hedefi: 100 puan"
	if value < 300: return "Gümüş hedefi: 300 puan"
	if value < 750: return "Altın hedefi: 750 puan"
	if value < 1500: return "Elmas hedefi: 1500 puan"
	return "Elmas kazanıldı! Rekorunu geliştir."

func restart() -> void:
	if score > 0:
		save_best()
	if fall_tween != null and fall_tween.is_valid():
		fall_tween.kill()
	busy = false
	dragging = false
	pointer = -2
	score = 0
	combo = 0
	combo_left = 0.0
	remaining = ROUND_SECONDS
	started = false
	ended = false
	moves = 0
	round_xp = 0
	profile_open = false
	longest = 0
	impact = 0.0
	pop_progress = 0.0
	fall_progress = 0.0
	particles.clear()
	floaters.clear()
	popping.clear()
	clear_cells.clear()
	special_waves.clear()
	resolution_active = false
	reward_anchor = -1
	reward_kind = 0
	chain.clear()
	board.resize(SIDE * SIDE)
	specials.resize(SIDE * SIDE)
	specials.fill(0)
	offsets.resize(SIDE * SIDE)
	offsets.fill(0.0)
	for i in board.size():
		board[i] = rng.randi_range(0, COLORS.size() - 1)
	ensure_move()
	board[1] = board[0]
	board[2] = board[0]
	specials[1] = BOMB
	message = "Bomba taşını aynı renkte 3+ zincire kat!" if timed_mode else "Rahat mod • Bomba ile başla"
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	impact = maxf(0.0, impact - delta * 3.0)
	if focused and started and not ended and not profile_open:
		combo_left = maxf(0.0, combo_left - delta)
		if combo_left <= 0.0:
			combo = 0
		if timed_mode:
			remaining = maxf(0.0, remaining - delta)
			if remaining <= 0.0 and not busy:
				end_round()
	for i in range(special_waves.size() - 1, -1, -1):
		special_waves[i]["age"] += delta
		if special_waves[i]["age"] >= 0.7:
			special_waves.remove_at(i)
	for i in range(particles.size() - 1, -1, -1):
		particles[i]["life"] -= delta
		particles[i]["pos"] += particles[i]["velocity"] * delta
		particles[i]["velocity"] += Vector2(0, 190) * delta
		if particles[i]["life"] <= 0.0:
			particles.remove_at(i)
	for i in range(floaters.size() - 1, -1, -1):
		floaters[i]["life"] -= delta
		floaters[i]["pos"] += Vector2(0, -42) * delta
		if floaters[i]["life"] <= 0.0:
			floaters.remove_at(i)
	queue_redraw()

func end_round() -> void:
	ended = true
	dragging = false
	pointer = -2
	chain.clear()
	combo_left = 0.0
	save_best()
	message = "Tur tamamlandı!"
	queue_redraw()

func cell_at(pos: Vector2) -> int:
	var local := pos - ORIGIN
	if local.x < 0 or local.y < 0 or local.x >= SIDE * CELL or local.y >= SIDE * CELL:
		return -1
	return int(local.y / CELL) * SIDE + int(local.x / CELL)

func adjacent(a: int, b: int) -> bool:
	return absi(a % SIDE - b % SIDE) + absi(a / SIDE - b / SIDE) == 1

func select_cell(index: int) -> void:
	if index < 0 or busy or ended or profile_open:
		return
	if chain.is_empty():
		chain.append(index)
	elif chain.size() >= 2 and index == chain[chain.size() - 2]:
		chain.pop_back()
	elif not chain.has(index) and adjacent(chain.back(), index) and board[index] == board[chain.front()]:
		chain.append(index)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and pointer == -2:
			press(event.position, event.index)
		elif not event.pressed and pointer == event.index:
			release_pointer()
	elif event is InputEventScreenDrag and pointer == event.index:
		select_cell(cell_at(event.position))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and pointer == -2:
			press(event.position, -1)
		elif not event.pressed and pointer == -1:
			release_pointer()
	elif event is InputEventMouseMotion and pointer == -1 and dragging:
		select_cell(cell_at(event.position))
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		profile_open = false
		cancel_selection()

func cancel_selection() -> void:
	if not busy:
		chain.clear()
	dragging = false
	pointer = -2
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		focused = false
		cancel_selection()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		focused = true

func press(pos: Vector2, id: int) -> void:
	if profile_open:
		if PROFILE_BACK.has_point(pos):
			profile_open = false
		else:
			for i in PALETTES.size():
				if Rect2(37, 356 + i * 86, 406, 74).has_point(pos):
					choose_theme(i)
		queue_redraw()
		return
	if PROFILE_BUTTON.has_point(pos):
		if not busy:
			cancel_selection()
			profile_open = true
		queue_redraw()
		return
	if RESTART.has_point(pos):
		restart()
		return
	if MODE_BUTTON.has_point(pos):
		timed_mode = not timed_mode
		restart()
		return
	if EFFECTS_BUTTON.has_point(pos):
		effects = not effects
		particles.clear()
		floaters.clear()
		special_waves.clear()
		impact = 0.0
		queue_redraw()
		return
	if busy or ended or cell_at(pos) < 0:
		return
	pointer = id
	dragging = true
	chain.clear()
	select_cell(cell_at(pos))

func release_pointer() -> void:
	dragging = false
	pointer = -2
	if busy or ended or profile_open:
		return
	if chain.size() < 3:
		chain.clear()
		message = "En az 3 taş bağla; 5+ taş süre kazandırır." if timed_mode else "En az 3 taş bağla; hızlı zincirlerle kombo yap."
		combo = 0
		combo_left = 0.0
		queue_redraw()
		return
	started = true
	busy = true
	var count := chain.size()
	combo = mini(5, combo + 1) if combo_left > 0.0 else 1
	combo_left = COMBO_WINDOW
	prepare_resolution()
	var extra := maxi(0, clear_cells.size() + (1 if reward_anchor >= 0 else 0) - count)
	var gained := (count * 10 + maxi(0, count - 3) * 5 + extra * 10) * combo
	score += gained
	best = maxi(best, score)
	longest = maxi(longest, count)
	moves += 1
	var bonus := mini(5, count - 2) if count >= 5 and timed_mode else 0
	remaining = minf(ROUND_SECONDS, remaining + bonus)
	message = "%d taş • +%d puan%s" % [count, gained, " • +%d sn" % bonus if bonus > 0 else ""]
	update_progress(count, gained)
	if reward_kind != 0:
		message = "%s kazandın! Sonraki zincirde kullan." % ("Şimşek" if reward_kind == LIGHTNING else "Bomba")
	var middle := center(chain[chain.size() / 2])
	if effects:
		floaters.append({"pos": middle, "text": "+%d" % gained, "life": 1.0, "color": Color("ffd166")})
		if bonus > 0:
			floaters.append({"pos": middle + Vector2(0, 30), "text": "+%d SANİYE" % bonus, "life": 1.2, "color": Color("58d8ce")})
		impact = minf(1.0, count / 8.0)
		for index in clear_cells:
			for n in 8:
				var angle := rng.randf_range(0.0, TAU)
				particles.append({"pos": center(index), "velocity": Vector2.from_angle(angle) * rng.randf_range(60, 150), "life": rng.randf_range(0.35, 0.65), "color": palette[board[index]]})
	popping.assign(clear_cells)
	fall_tween = create_tween()
	fall_tween.tween_method(animate_pop, 0.0, 1.0, 0.12)
	fall_tween.tween_callback(start_fall)
	fall_tween.tween_method(animate_fall, 1.0, 0.0, 0.30).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	fall_tween.tween_callback(finish_fall)
	queue_redraw()

func prepare_resolution() -> void:
	clear_cells.assign(chain)
	resolution_active = true
	reward_anchor = chain.back() if chain.size() >= 5 else -1
	reward_kind = LIGHTNING if chain.size() >= 7 else (BOMB if chain.size() >= 5 else 0)
	var activated: Array[int] = []
	var cursor := 0
	while cursor < clear_cells.size():
		var index: int = clear_cells[cursor]
		cursor += 1
		if specials[index] == 0 or activated.has(index):
			continue
		activated.append(index)
		if effects:
			special_waves.append({"kind": specials[index], "pos": center(index), "age": 0.0})
		if specials[index] == LIGHTNING:
			var row := index / SIDE
			for x in SIDE:
				var affected := row * SIDE + x
				if not clear_cells.has(affected):
					clear_cells.append(affected)
		else:
			var pos := Vector2i(index % SIDE, index / SIDE)
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var cell := pos + Vector2i(dx, dy)
					if cell.x < 0 or cell.y < 0 or cell.x >= SIDE or cell.y >= SIDE:
						continue
					var affected := cell.y * SIDE + cell.x
					if not clear_cells.has(affected):
						clear_cells.append(affected)
	if reward_anchor >= 0:
		clear_cells.erase(reward_anchor)

func animate_pop(value: float) -> void:
	pop_progress = value
	queue_redraw()

func start_fall() -> void:
	collapse()
	chain.clear()
	popping.clear()
	pop_progress = 0.0

func collapse() -> void:
	var removed: Array[int] = clear_cells if resolution_active else chain
	for x in SIDE:
		var target := SIDE - 1
		for y in range(SIDE - 1, -1, -1):
			var source := y * SIDE + x
			if not removed.has(source):
				board[target * SIDE + x] = board[source]
				specials[target * SIDE + x] = reward_kind if source == reward_anchor and resolution_active else specials[source]
				offsets[target * SIDE + x] = float(y - target) * CELL
				target -= 1
		var missing := target + 1
		while target >= 0:
			board[target * SIDE + x] = rng.randi_range(0, COLORS.size() - 1)
			specials[target * SIDE + x] = 0
			offsets[target * SIDE + x] = -float(missing) * CELL
			target -= 1
	clear_cells.clear()
	resolution_active = false
	reward_anchor = -1
	reward_kind = 0

func animate_fall(value: float) -> void:
	fall_progress = value
	queue_redraw()

func finish_fall() -> void:
	offsets.fill(0.0)
	fall_progress = 0.0
	ensure_move()
	busy = false
	if timed_mode and remaining <= 0.0:
		end_round()
	queue_redraw()

func has_move() -> bool:
	var visited: Array[int] = []
	for start in board.size():
		if visited.has(start):
			continue
		var pending: Array[int] = [start]
		visited.append(start)
		var count := 0
		while not pending.is_empty():
			var current: int = pending.pop_back()
			count += 1
			if count >= 3:
				return true
			var pos := Vector2i(current % SIDE, current / SIDE)
			for direction in DIRECTIONS:
				var next: Vector2i = pos + direction
				if next.x < 0 or next.y < 0 or next.x >= SIDE or next.y >= SIDE:
					continue
				var index := next.y * SIDE + next.x
				if board[index] == board[start] and not visited.has(index):
					visited.append(index)
					pending.append(index)
	return false

func ensure_move() -> void:
	if has_move():
		return
	for i in board.size():
		board[i] = rng.randi_range(0, COLORS.size() - 1)
	board[1] = board[0]
	board[2] = board[0]
	message = "Hamle kalmadı; tahta yenilendi."

func center(index: int) -> Vector2:
	return ORIGIN + Vector2(index % SIDE + 0.5, index / SIDE + 0.5) * CELL

func text(value: String, y: float, size: int, color: Color = Color.WHITE) -> void:
	label_at(value, Vector2(240, y), size, color)

func label_at(value: String, pos: Vector2, size: int, color: Color) -> void:
	var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(font, pos - Vector2(width / 2, 0), value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func box(rect: Rect2, color: Color, radius: int = 16) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	draw_style_box(style, rect)

func draw_profile() -> void:
	draw_rect(Rect2(0, 0, 480, 800), Color("090d19"))
	text("HEDEFİNİ BÜYÜT", 47, 27)
	text("HEDEFLER VE ÖDÜLLER", 77, 18, Color("58d8ce"))
	text("SEVİYE %d  •  %d YILDIZ" % [player_level(), stars], 123, 26, Color("ffd166"))
	box(Rect2(37, 145, 406, 8), Color("172139"), 4)
	box(Rect2(37, 145, 406 * float(xp % 100) / 100.0, 8), Color("9381ff"), 4)
	text("Sonraki seviye: %d / 100 deneyim" % (xp % 100), 177, 16, Color("9caac7"))
	box(Rect2(37, 194, 406, 126), Color("172139"))
	text("GÖREV %d" % (quests_done + 1), 222, 16, Color("58d8ce"))
	text(quest_title(), 253, 23)
	text("İlerleme: %d / %d" % [quest_progress, quest_target()], 283, 18, Color("9caac7"))
	text("Ödül: 1 yıldız + 30 deneyim", 307, 15, Color("ffd166"))
	text("TEMALAR • Yıldızların harcanmaz", 344, 17, Color("9caac7"))
	for i in PALETTES.size():
		var y := 356 + i * 86
		var unlocked: bool = stars >= THEME_COSTS[i]
		box(Rect2(37, y, 406, 74), Color("25385a") if theme_index == i else Color("172139"))
		label_at(THEME_NAMES[i], Vector2(115, y + 29), 22, Color.WHITE if unlocked else Color("9caac7"))
		var status: String = "SEÇİLİ" if theme_index == i else ("SEÇ" if unlocked else "%d / %d yıldız" % [stars, THEME_COSTS[i]])
		label_at(status, Vector2(115, y + 54), 14, Color("58d8ce") if unlocked else Color("9caac7"))
		for j in 4:
			draw_circle(Vector2(250 + j * 45, y + 37), 15, Color(PALETTES[i][j], 1.0 if unlocked else 0.35))
	text("60 SN MADALYAN: %s" % medal(timed_best), 643, 19, Color("ffd166"))
	text("Süreli rekor: %d • %s" % [timed_best, next_medal(timed_best)], 671, 15, Color("9caac7"))
	text("Görevler ve deneyim her iki modda kazanılır.", 695, 14, Color("9caac7"))
	box(PROFILE_BACK, Color("526bd8"))
	text("Oyuna dön", 746, 22)
	text("Tur duraklatıldı • İlerleme bu cihazda saklanır", 788, 14, Color("9caac7"))

func _draw() -> void:
	if profile_open:
		draw_profile()
		return
	var accent := Color("ffd166") if remaining > 10 or not timed_mode else Color("ff6584")
	text("COLOR CHAIN", 52, 34)
	text("SV %d • %d yıldız • Hedefler ve ödüller ›" % [player_level(), stars], 78, 16, Color("58d8ce"))
	box(Rect2(37, 92, 195, 36), Color("172139"))
	box(Rect2(248, 92, 195, 36), Color("172139"))
	label_at("SÜRE  %02d" % ceili(remaining) if timed_mode else "RAHAT MOD  ∞", Vector2(134, 116), 18, accent)
	label_at("REKOR  %d" % best, Vector2(346, 116), 18, Color("58d8ce"))
	box(Rect2(37, 137, 406, 5), Color("172139"), 2)
	box(Rect2(37, 137, 406 * remaining / ROUND_SECONDS if timed_mode else 406, 5), accent, 2)
	text("SKOR  %d" % score, 181, 30, Color.WHITE.lerp(accent, impact))
	text(message, 211, 14, Color("9caac7"))
	text("5–6 taş: BOMBA  •  7+ taş: ŞİMŞEK", 151, 10, Color("9caac7"))
	var shake := Vector2(sin(elapsed * 55), cos(elapsed * 49)) * impact * 2 if effects else Vector2.ZERO
	draw_set_transform(shake)
	box(Rect2(ORIGIN - Vector2(9, 9), Vector2.ONE * (SIDE * CELL + 18)), Color("172139"), 20)
	for i in board.size():
		var pos := center(i) + Vector2(0, offsets[i] * fall_progress)
		if pos.y < ORIGIN.y:
			continue
		var selected := chain.has(i)
		var radius := 23.0
		if selected and effects:
			radius += 1.5 + sin(elapsed * 9) * 1.2
		if popping.has(i):
			radius *= 1.0 - pop_progress
		if selected and effects:
			draw_circle(pos, radius + 6, Color(palette[board[i]], 0.15))
		draw_circle(pos + Vector2(0, 4), radius, Color("080e1c"))
		draw_circle(pos, radius, palette[board[i]])
		if radius > 10:
			draw_circle(pos + Vector2(-7, -9), 5, Color(1, 1, 1, 0.18))
			if specials[i] == BOMB:
				draw_circle(pos, 10, Color("15213a"))
				draw_line(pos + Vector2(5, -7), pos + Vector2(11, -14), Color.WHITE, 2, true)
				draw_circle(pos + Vector2(12, -15), 2.5 + sin(elapsed * 10) * 0.7, Color("ffd166"))
			elif specials[i] == LIGHTNING:
				draw_colored_polygon(PackedVector2Array([pos + Vector2(3, -16), pos + Vector2(-9, 2), pos + Vector2(-1, 2), pos + Vector2(-4, 16), pos + Vector2(10, -3), pos + Vector2(2, -3)]), Color.WHITE)
			else:
				label_at(["1", "2", "3", "4"][board[i]], pos + Vector2(0, 7), 20, Color("15213a"))
			if specials[i] != 0:
				draw_arc(pos, radius + 2, 0, TAU, 40, Color.WHITE, 1.5, true)
	if chain.size() > 1 and not busy:
		for i in range(1, chain.size()):
			draw_line(center(chain[i - 1]), center(chain[i]), Color(1, 1, 1, 0.15), 12, true)
			draw_line(center(chain[i - 1]), center(chain[i]), Color.WHITE, 4, true)
	for index in chain:
		if not busy:
			draw_arc(center(index), 27, 0, TAU, 40, Color.WHITE, 2, true)
	for wave in special_waves:
		var age: float = wave["age"]
		var pos: Vector2 = wave["pos"]
		var alpha := 1.0 - age / 0.7
		if wave["kind"] == BOMB:
			draw_arc(pos, 15 + age * 140, 0, TAU, 64, Color(1, 0.82, 0.4, alpha), 5 * alpha + 1, true)
			draw_circle(pos, 15 + age * 60, Color(1, 0.65, 0.3, alpha * 0.12))
		else:
			var points := PackedVector2Array()
			for n in 29:
				points.append(Vector2(ORIGIN.x + n * CELL / 4, pos.y + sin(n * 2.3 + age * 50) * 10 * alpha))
			draw_polyline(points, Color(0.4, 0.9, 1, alpha * 0.2), 14, true)
			draw_polyline(points, Color(0.8, 1, 1, alpha), 3, true)
	for particle in particles:
		draw_circle(particle["pos"], 3.5, Color(particle["color"], minf(1.0, particle["life"] * 2)))
	for floater in floaters:
		label_at(floater["text"], floater["pos"], 24, Color(floater["color"], minf(1.0, floater["life"] * 2)))
	draw_set_transform(Vector2.ZERO)
	if combo >= 2 and not ended:
		text("KOMBO x%d" % combo, 662, 22, Color("ffd166"))
		box(Rect2(145, 672, 190 * combo_left / COMBO_WINDOW, 3), Color("ffd166"), 1)
	else:
		text("Görev: %s (%d/%d)" % [quest_title(), quest_progress, quest_target()], 662, 15, Color("9caac7"))
	box(RESTART, Color("526bd8"))
	text("Tekrar oyna" if ended else "Yeniden başlat", 723, 21)
	box(MODE_BUTTON, Color("172139"), 9)
	box(EFFECTS_BUTTON, Color("172139"), 9)
	label_at("Mod: 60 sn" if timed_mode else "Mod: Rahat", Vector2(134, 775), 15, Color("9caac7"))
	label_at("Efektler: Açık" if effects else "Efektler: Sade", Vector2(346, 775), 15, Color("9caac7"))
	if ended:
		draw_rect(Rect2(ORIGIN - Vector2(9, 9), Vector2.ONE * (SIDE * CELL + 18)), Color(0.03, 0.05, 0.1, 0.9))
		text("%s MADALYA" % medal(score) if score >= 100 else "TUR TAMAMLANDI", 354, 28, Color("ffd166"))
		text("%d PUAN" % score, 415, 38)
		text("En uzun zincir: %d taş" % longest, 465, 20, Color("58d8ce"))
		text("+%d deneyim • Seviye %d" % [round_xp, player_level()], 500, 19, Color("9caac7"))
		text(next_medal(score), 545, 20, Color("ffd166"))
		text("Yeni tur için Tekrar oyna'ya dokun.", 592, 16, Color("9caac7"))
