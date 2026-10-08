extends Node2D

const SIDE := 7
const CELL := 58.0
const ORIGIN := Vector2(37, 230)
const COLORS := [Color("ff6584"), Color("58d8ce"), Color("ffd166"), Color("9381ff")]
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const RESTART := Rect2(100, 690, 280, 56)
var board: Array[int] = []
var chain: Array[int] = []
var offsets: Array[float] = []
var score := 0
var dragging := false
var pointer := -2
var busy := false
var message := "En az 3 aynı renk taşı birleştir."
var fall_tween: Tween
var rng := RandomNumberGenerator.new()
var font: Font = ThemeDB.fallback_font

func _ready() -> void:
	rng.randomize()
	restart()

func restart() -> void:
	if fall_tween != null and fall_tween.is_valid():
		fall_tween.kill()
	busy = false
	dragging = false
	pointer = -2
	score = 0
	chain.clear()
	board.resize(SIDE * SIDE)
	offsets.resize(SIDE * SIDE)
	offsets.fill(0.0)
	for i in board.size():
		board[i] = rng.randi_range(0, COLORS.size() - 1)
	ensure_move()
	message = "En az 3 aynı renk taşı birleştir."
	queue_redraw()

func cell_at(pos: Vector2) -> int:
	var local := pos - ORIGIN
	if local.x < 0 or local.y < 0 or local.x >= SIDE * CELL or local.y >= SIDE * CELL:
		return -1
	return int(local.y / CELL) * SIDE + int(local.x / CELL)

func adjacent(a: int, b: int) -> bool:
	return absi(a % SIDE - b % SIDE) + absi(a / SIDE - b / SIDE) == 1

func select_cell(index: int) -> void:
	if index < 0 or busy:
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
		chain.clear()
		dragging = false
		pointer = -2
		queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		chain.clear()
		dragging = false
		pointer = -2
		queue_redraw()

func press(pos: Vector2, id: int) -> void:
	if RESTART.has_point(pos):
		restart()
		return
	if busy or cell_at(pos) < 0:
		return
	pointer = id
	dragging = true
	chain.clear()
	select_cell(cell_at(pos))

func release_pointer() -> void:
	dragging = false
	pointer = -2
	if chain.size() < 3:
		chain.clear()
		message = "Zincir için en az 3 taş gerekli."
		queue_redraw()
		return
	busy = true
	var count := chain.size()
	score += count * 10 + maxi(0, count - 3) * 5
	message = "%d taş • +%d puan" % [count, count * 10 + maxi(0, count - 3) * 5]
	collapse()
	chain.clear()
	fall_tween = create_tween()
	fall_tween.tween_method(animate_fall, 1.0, 0.0, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	fall_tween.tween_callback(finish_fall)
	queue_redraw()

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

var fall_progress := 0.0
func animate_fall(value: float) -> void:
	fall_progress = value
	queue_redraw()

func finish_fall() -> void:
	offsets.fill(0.0)
	fall_progress = 0.0
	ensure_move()
	busy = false
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
	# Guaranteed playable fallback, with no unbounded shuffle loop.
	board[1] = board[0]
	board[2] = board[0]
	message = "Hamle kalmadı; tahta yenilendi."

func center(index: int) -> Vector2:
	return ORIGIN + Vector2(index % SIDE + 0.5, index / SIDE + 0.5) * CELL

func text(value: String, y: float, size: int, color: Color = Color.WHITE) -> void:
	var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(font, Vector2((480 - width) / 2, y), value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw() -> void:
	text("COLOR CHAIN", 74, 38)
	text("Renkleri bağla, zinciri büyüt", 110, 18, Color("9caac7"))
	text("SKOR  %d" % score, 176, 30)
	text(message, 208, 16, Color("9caac7"))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("172139")
	panel.set_corner_radius_all(20)
	draw_style_box(panel, Rect2(ORIGIN - Vector2(9, 9), Vector2.ONE * (SIDE * CELL + 18)))
	for i in board.size():
		var pos := center(i) + Vector2(0, offsets[i] * fall_progress)
		if pos.y < ORIGIN.y:
			continue
		draw_circle(pos + Vector2(0, 4), 23, Color("080e1c"))
		draw_circle(pos, 23, COLORS[board[i]])
		# Symbols keep colors distinguishable for players with color vision differences.
		draw_string(font, pos + Vector2(-6, 7), ["1", "2", "3", "4"][board[i]], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("15213a"))
	if chain.size() > 1:
		for i in range(1, chain.size()):
			draw_line(center(chain[i - 1]), center(chain[i]), Color.WHITE, 5, true)
	for index in chain:
		draw_arc(center(index), 26, 0, TAU, 40, Color.WHITE, 3, true)
	text("Zincir: %d / en az 3" % chain.size(), 663, 18, Color("9caac7"))
	panel.bg_color = Color("334469")
	draw_style_box(panel, RESTART)
	text("Yeniden başlat", 726, 22)
	text("Sürükle • Bağla • Bırak", 778, 17, Color("9caac7"))
