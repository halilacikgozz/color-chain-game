extends Node2D

const SIDE := 7
const CELL := 58.0
const ORIGIN := Vector2(37, 230)
const COLORS := [Color("ff6584"), Color("58d8ce"), Color("ffd166"), Color("9381ff")]
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const RESTART := Rect2(100, 690, 280, 52)
const MODE_BUTTON := Rect2(37, 754, 195, 32)
const EFFECTS_BUTTON := Rect2(248, 754, 195, 32)
const ROUND_SECONDS := 60.0
const COMBO_WINDOW := 4.0
var board: Array[int] = []
var chain: Array[int] = []
var offsets: Array[float] = []
var score := 0
var best := 0
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
	var config := ConfigFile.new()
	if config.load("user://color_chain.cfg") == OK:
		best = int(config.get_value("game", "best", 0))
	restart()

func save_best() -> void:
	var config := ConfigFile.new()
	config.set_value("game", "best", best)
	config.save("user://color_chain.cfg")

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
	longest = 0
	impact = 0.0
	pop_progress = 0.0
	fall_progress = 0.0
	particles.clear()
	floaters.clear()
	popping.clear()
	chain.clear()
	board.resize(SIDE * SIDE)
	offsets.resize(SIDE * SIDE)
	offsets.fill(0.0)
	for i in board.size():
		board[i] = rng.randi_range(0, COLORS.size() - 1)
	ensure_move()
	message = "Sürükle ve ilk zincirinle turu başlat!" if timed_mode else "Rahat mod • Süre sınırı yok"
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	impact = maxf(0.0, impact - delta * 3.0)
	if focused and started and not ended:
		combo_left = maxf(0.0, combo_left - delta)
		if combo_left <= 0.0:
			combo = 0
		if timed_mode:
			remaining = maxf(0.0, remaining - delta)
			if remaining <= 0.0 and not busy:
				end_round()
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
	if index < 0 or busy or ended:
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
	if busy or ended:
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
	var gained := (count * 10 + maxi(0, count - 3) * 5) * combo
	score += gained
	best = maxi(best, score)
	longest = maxi(longest, count)
	moves += 1
	var bonus := mini(5, count - 2) if count >= 5 and timed_mode else 0
	remaining = minf(ROUND_SECONDS, remaining + bonus)
	message = "%d taş • +%d puan%s" % [count, gained, " • +%d sn" % bonus if bonus > 0 else ""]
	var middle := center(chain[chain.size() / 2])
	if effects:
		floaters.append({"pos": middle, "text": "+%d" % gained, "life": 1.0, "color": Color("ffd166")})
		if bonus > 0:
			floaters.append({"pos": middle + Vector2(0, 30), "text": "+%d SANİYE" % bonus, "life": 1.2, "color": Color("58d8ce")})
		impact = minf(1.0, count / 8.0)
		for index in chain:
			for n in 8:
				var angle := rng.randf_range(0.0, TAU)
				particles.append({"pos": center(index), "velocity": Vector2.from_angle(angle) * rng.randf_range(60, 150), "life": rng.randf_range(0.35, 0.65), "color": COLORS[board[index]]})
	popping.assign(chain)
	fall_tween = create_tween()
	fall_tween.tween_method(animate_pop, 0.0, 1.0, 0.12)
	fall_tween.tween_callback(start_fall)
	fall_tween.tween_method(animate_fall, 1.0, 0.0, 0.30).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	fall_tween.tween_callback(finish_fall)
	queue_redraw()

func animate_pop(value: float) -> void:
	pop_progress = value
	queue_redraw()

func start_fall() -> void:
	collapse()
	chain.clear()
	popping.clear()
	pop_progress = 0.0

func collapse() -> void:
	for x in SIDE:
		var target := SIDE - 1
		for y in range(SIDE - 1, -1, -1):
			var source := y * SIDE + x
			if not chain.has(source):
				board[target * SIDE + x] = board[source]
				offsets[target * SIDE + x] = float(y - target) * CELL
				target -= 1
		var missing := target + 1
		while target >= 0:
			board[target * SIDE + x] = rng.randi_range(0, COLORS.size() - 1)
			offsets[target * SIDE + x] = -float(missing) * CELL
			target -= 1

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

func _draw() -> void:
	var accent := Color("ffd166") if remaining > 10 or not timed_mode else Color("ff6584")
	text("COLOR CHAIN", 52, 34)
	text("Bir zincir daha!", 78, 17, Color("9caac7"))
	box(Rect2(37, 92, 195, 36), Color("172139"))
	box(Rect2(248, 92, 195, 36), Color("172139"))
	label_at("SÜRE  %02d" % ceili(remaining) if timed_mode else "RAHAT MOD  ∞", Vector2(134, 116), 18, accent)
	label_at("REKOR  %d" % best, Vector2(346, 116), 18, Color("58d8ce"))
	box(Rect2(37, 137, 406, 5), Color("172139"), 2)
	box(Rect2(37, 137, 406 * remaining / ROUND_SECONDS if timed_mode else 406, 5), accent, 2)
	text("SKOR  %d" % score, 181, 30, Color.WHITE.lerp(accent, impact))
	text(message, 211, 15, Color("9caac7"))
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
			draw_circle(pos, radius + 6, Color(COLORS[board[i]], 0.15))
		draw_circle(pos + Vector2(0, 4), radius, Color("080e1c"))
		draw_circle(pos, radius, COLORS[board[i]])
		if radius > 10:
			draw_circle(pos + Vector2(-7, -9), 5, Color(1, 1, 1, 0.18))
			label_at(["1", "2", "3", "4"][board[i]], pos + Vector2(0, 7), 20, Color("15213a"))
	if chain.size() > 1 and not busy:
		for i in range(1, chain.size()):
			draw_line(center(chain[i - 1]), center(chain[i]), Color(1, 1, 1, 0.15), 12, true)
			draw_line(center(chain[i - 1]), center(chain[i]), Color.WHITE, 4, true)
	for index in chain:
		if not busy:
			draw_arc(center(index), 27, 0, TAU, 40, Color.WHITE, 2, true)
	for particle in particles:
		draw_circle(particle["pos"], 3.5, Color(particle["color"], minf(1.0, particle["life"] * 2)))
	for floater in floaters:
		label_at(floater["text"], floater["pos"], 24, Color(floater["color"], minf(1.0, floater["life"] * 2)))
	draw_set_transform(Vector2.ZERO)
	if combo >= 2 and not ended:
		text("KOMBO x%d" % combo, 662, 22, Color("ffd166"))
		box(Rect2(145, 672, 190 * combo_left / COMBO_WINDOW, 3), Color("ffd166"), 1)
	else:
		text(("Zincir: %d  •  5+ taş = süre bonusu" if timed_mode else "Zincir: %d  •  Hızlı zincir = kombo") % chain.size(), 662, 16, Color("9caac7"))
	box(RESTART, Color("526bd8"))
	text("Tekrar oyna" if ended else "Yeniden başlat", 723, 21)
	box(MODE_BUTTON, Color("172139"), 9)
	box(EFFECTS_BUTTON, Color("172139"), 9)
	label_at("Mod: 60 sn" if timed_mode else "Mod: Rahat", Vector2(134, 775), 15, Color("9caac7"))
	label_at("Efektler: Açık" if effects else "Efektler: Sade", Vector2(346, 775), 15, Color("9caac7"))
	if ended:
		draw_rect(Rect2(ORIGIN - Vector2(9, 9), Vector2.ONE * (SIDE * CELL + 18)), Color(0.03, 0.05, 0.1, 0.9))
		text("SÜRE DOLDU!", 354, 30, Color("ffd166"))
		text("%d PUAN" % score, 415, 38)
		text("En uzun zincir: %d taş" % longest, 465, 20, Color("58d8ce"))
		text("%d başarılı hamle" % moves, 500, 19, Color("9caac7"))
		text("Rekor: %d" % best, 545, 23, Color("ffd166"))
		text("Yeni tur için Tekrar oyna'ya dokun.", 592, 16, Color("9caac7"))
