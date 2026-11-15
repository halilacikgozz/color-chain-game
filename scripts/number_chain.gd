extends Node2D
const COLS := 5
const ROWS := 7
const COUNT := COLS * ROWS
const ORIGIN := Vector2(40, 236)
const STEP := 80.0
const SAVE := "user://number_chain_v3.json"
const LEGACY_SAVES := ["user://number_chain_v2.json", "user://number_chain_v1.json"]
const COLORS := [Color("9874e6"),Color("5a87ef"),Color("19a78b"),Color("e77359"),Color("3cbbce"),Color("4775eb"),Color("eea0bd"),Color("c6d5ff"),Color("f2bd63"),Color("f18081"),Color("aa5287"),Color("dcc4b2")]
const COSTS := {"hammer":15,"shuffle":20,"magnet":25}
var board: Array[String] = []
var reserve: Array[String] = []
var chain: Array[int] = []
var score := "0"
var best := "0"
var largest := "2"
var goal := "1000"
var gems := 90
var ended := false
var end_dismissed := false
var busy := false
var dragging := false
var pointer_id := -2
var last_pointer := Vector2.ZERO
var phase := 0
var elapsed := 0.0
var motions: Array[Dictionary] = []
var effects := true
var sound_on := true
var save_path := SAVE
var rng := RandomNumberGenerator.new()
var font := ThemeDB.fallback_font
var message := "Aynı sayıyla başla, oluşan sayıyla devam et"
var overlay := ""
var active_tool := ""
var palette_cache := {}
var audio: AudioStreamPlayer
var sounds := {}
var reward_flash := 0.0
var distribution_store := OS.has_feature("play_store")
var updater: Node
var updates_auto_start := true
var update_requested := false
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

# Long chains round UP to the next binary tier, never to an arbitrary integer.
# Doubling decimal strings avoids float rounding near large powers of two.
static func power_at_least(value: String) -> String:
	var power := "2"
	while greater(value, power): power = add(power, power)
	return power

func merge_result() -> String:
	return power_at_least(total())

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


static func ratio(value: String, target: String) -> float:
	if value == "0": return 0.0
	if not greater(target, value): return 1.0
	var gap := value.length() - target.length()
	if gap < -12: return 0.0
	var a := value.substr(0, 8).to_float() / pow(10.0, mini(8, value.length()) - 1)
	var b := target.substr(0, 8).to_float() / pow(10.0, mini(8, target.length()) - 1)
	return clampf(a / b * pow(10.0, gap), 0.0, 1.0)

static func rank_of(value: String) -> int:
	var p := "2"
	var rank := 1
	while greater(value, p):
		p = add(p, p)
		rank += 1
	return rank

func _ready() -> void:
	rng.randomize()
	audio = AudioStreamPlayer.new()
	audio.volume_db = -17
	add_child(audio)
	if not load_progress(): new_game()
	var checker_path := "res://scripts/store_update_checker.gd" if distribution_store else "res://scripts/update_checker.gd"
	updater = load(checker_path).new()
	updater.auto_start = updates_auto_start
	updater.changed.connect(update_state_changed)
	add_child(updater)
	queue_redraw()

func new_game() -> void:
	board.clear()
	reserve.clear()
	for i in COUNT: board.append(["2","2","4","4","8"][rng.randi_range(0,4)])
	board[1] = board[0]
	score = "0"
	largest = "2"
	for value in board:
		if greater(value, largest): largest = value
	goal = "1000"
	ended = false
	end_dismissed = false
	busy = false
	phase = 0
	chain.clear()
	motions.clear()
	overlay = ""
	active_tool = ""
	pointer_id = -2
	dragging = false
	message = "Aynı sayıyla başla, oluşan sayıyla devam et"
	save_progress()
	queue_redraw()

func adjacent(a: int, b: int) -> bool:
	return a >= 0 and b >= 0 and a < COUNT and b < COUNT and a != b and maxi(absi(a % COLS - b % COLS),absi(a / COLS - b / COLS)) == 1

func center(i: int) -> Vector2:
	return ORIGIN + Vector2(i % COLS, i / COLS) * STEP + Vector2.ONE * STEP / 2.0

func cell_at(p: Vector2) -> int:
	if not Rect2(ORIGIN, Vector2(COLS,ROWS) * STEP).has_point(p): return -1
	var q := (p - ORIGIN) / STEP
	return int(q.y) * COLS + int(q.x)

func can_extend(i: int) -> bool:
	if i < 0 or i >= COUNT or chain.is_empty() or chain.has(i): return false
	if not adjacent(chain.back(),i): return false
	# Start with an equal pair, then continue at the last tier or at the
	# actual merged tier displayed in the preview. Backtracking recomputes it.
	if board[i] == board[chain.back()]: return true
	if chain.size() < 2: return false
	return board[i] == merge_result()

func select_cell(i: int) -> void:
	if i < 0 or i >= COUNT or busy or ended or not overlay.is_empty(): return
	var before := chain.size()
	if chain.is_empty(): chain.append(i)
	elif chain.size() > 1 and i == chain[chain.size()-2]: chain.pop_back()
	elif can_extend(i): chain.append(i)
	if chain.size() > before: tone(mini(chain.size(),8))
	queue_redraw()

func total() -> String:
	var sum := "0"
	for i in chain: sum = add(sum,board[i])
	return sum

func has_move() -> bool:
	for i in COUNT:
		for offset in [1,COLS-1,COLS,COLS+1]:
			var j: int = i + offset
			if j < COUNT and adjacent(i,j) and board[i] == board[j]: return true
	return false

func release_chain() -> void:
	dragging = false
	pointer_id = -2
	if chain.size() < 2:
		chain.clear()
		queue_redraw()
		return
	busy = true
	phase = 1
	elapsed = 0.0
	motions.clear()
	for i in chain: motions.append({"value":board[i],"from":center(i),"to":center(chain.back())})
	tone(10)
	if not effects: finish_merge()
	queue_redraw()

func finish_merge() -> void:
	var consumed := total()
	var result := merge_result()
	var target: int = chain.back()
	var count := chain.size()
	for i in chain: board[i] = ""
	board[target] = result
	score = add(score,consumed)
	if greater(score,best): best = score
	if greater(result,largest): largest = result
	message = str(count)+" taş birleşti • +"+compact(consumed)+" puan"
	advance_goal(true)
	chain.clear()
	collapse()

func advance_goal(reward: bool) -> void:
	var earned := 0
	while not greater(goal,score):
		goal = add(goal,goal)
		if reward: earned += 20
	if earned > 0:
		gems += earned
		message = "HEDEF TAMAM • +"+str(earned)+" elmas"
		reward_flash = 0.8 if effects else 0.0

func collapse() -> void:
	motions.clear()
	busy = true
	for col in COLS:
		var write := ROWS-1
		for row in range(ROWS-1,-1,-1):
			var source := row*COLS+col
			if board[source].is_empty(): continue
			var destination := write*COLS+col
			var value := board[source]
			board[source] = ""
			board[destination] = value
			motions.append({"value":value,"from":center(source),"to":center(destination)})
			write -= 1
		for row in range(write,-1,-1):
			var destination := row*COLS+col
			var value := spawn_value()
			board[destination] = value
			motions.append({"value":value,"from":center(destination)-Vector2(0,(write+1)*STEP),"to":center(destination)})
	phase = 2
	elapsed = 0.0
	if not effects: finish_fall()
	queue_redraw()

func spawn_value() -> String:
	if not reserve.is_empty(): return reserve.pop_front()
	if rng.randf() < 0.22:
		var live: Array[String] = []
		for value in board:
			if not value.is_empty(): live.append(value)
		if not live.is_empty(): return live[rng.randi_range(0,live.size()-1)]
	var minimum := maxi(1,rank_of(largest)-6)
	var rank := minimum+rng.randi_range(0,2)
	var value := "2"
	for i in range(1,rank): value = add(value,value)
	return value

func finish_fall() -> void:
	busy = false
	phase = 0
	motions.clear()
	ended = not has_move()
	end_dismissed = false
	save_progress()
	queue_redraw()

func tone(note: int) -> void:
	if not sound_on or audio == null: return
	if not sounds.has(note):
		var data := PackedByteArray()
		var count := 1800
		data.resize(count*2)
		var frequency := 300.0+note*45
		for i in count:
			var sample := sin(TAU*frequency*i/22050.0)*sin(PI*i/count)*0.4
			data.encode_s16(i*2,int(sample*32767))
		var stream := AudioStreamWAV.new()
		stream.format = AudioStreamWAV.FORMAT_16_BITS
		stream.mix_rate = 22050
		stream.data = data
		sounds[note] = stream
	audio.stream = sounds[note]
	audio.play()

func update_state_changed() -> void:
	if updater.has_update() and updater.manual and overlay == "settings" and not busy:
		overlay = "update"
		updater.mark_prompted()
	update_requested = updater.should_prompt()
	queue_redraw()

func show_pending_update() -> void:
	if update_requested and not busy and not dragging and overlay.is_empty() and not ended:
		active_tool = ""
		overlay = "update"
		updater.mark_prompted()
		update_requested = false
		queue_redraw()

func _process(delta: float) -> void:
	show_pending_update()
	if reward_flash > 0:
		reward_flash = maxf(0,reward_flash-delta)
		queue_redraw()
	if not busy: return
	elapsed += delta
	if phase == 1 and elapsed >= 0.18: finish_merge()
	elif phase == 2 and elapsed >= 0.26: finish_fall()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		cancel_pointer()
		overlay = "settings" if overlay.is_empty() else ""
		queue_redraw()
	elif event is InputEventScreenTouch:
		if event.pressed and pointer_id == -2: pointer_down(event.position,event.index)
		elif not event.pressed and pointer_id == event.index:
			if event.canceled: cancel_pointer()
			else:
				drag_to(event.position)
				release_chain()
	elif event is InputEventScreenDrag and event.index == pointer_id and dragging: drag_to(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and pointer_id == -2: pointer_down(event.position,-1)
		elif not event.pressed and pointer_id == -1:
			drag_to(event.position)
			release_chain()
	elif event is InputEventMouseMotion and pointer_id == -1 and dragging: drag_to(event.position)

func drag_to(p: Vector2) -> void:
	if not dragging: return
	var steps := maxi(1,int(last_pointer.distance_to(p)/10.0))
	for step in range(1,steps+1):
		var sample := last_pointer.lerp(p,float(step)/steps)
		var cell := cell_at(sample)
		if cell >= 0:
			var diff := (sample-center(cell)).abs()
			if diff.x <= STEP*0.36 and diff.y <= STEP*0.36: select_cell(cell)
	last_pointer = p

func cancel_pointer() -> void:
	dragging = false
	pointer_id = -2
	if not busy: chain.clear()
	queue_redraw()

func pointer_down(p: Vector2, id: int = -1) -> void:
	if busy: return
	if not overlay.is_empty():
		overlay_press(p)
		return
	if Rect2(408,22,48,48).has_point(p):
		cancel_pointer()
		active_tool = ""
		overlay = "settings"
		queue_redraw()
		return
	if ended and not end_dismissed:
		if Rect2(90,544,300,56).has_point(p): new_game()
		elif Rect2(90,616,300,48).has_point(p):
			end_dismissed = true
			queue_redraw()
		return
	for i in 3:
		if p.distance_to(Vector2(128+i*112,844)) <= 38:
			choose_tool(["hammer","shuffle","magnet"][i])
			return
	var cell := cell_at(p)
	if cell < 0:
		active_tool = ""
		queue_redraw()
		return
	if not active_tool.is_empty():
		apply_tool(cell)
		return
	if ended: return
	dragging = true
	pointer_id = id
	last_pointer = p
	chain.clear()
	select_cell(cell)

func choose_tool(tool: String) -> void:
	cancel_pointer()
	if gems < COSTS[tool]:
		message = "Yeterli elmas yok • Hedeflere ulaşarak kazan"
		queue_redraw()
		return
	if tool == "shuffle":
		shuffle_board()
		return
	active_tool = "" if active_tool == tool else tool
	if active_tool == "hammer": message = "Kırılacak kareyi seç • İptal için çekiçe dokun"
	elif active_tool == "magnet": message = "Aynı sayıları toplamak için bir kare seç"
	else: message = "Aynı sayıyla başla, oluşan sayıyla devam et"
	queue_redraw()

func shuffle_board() -> void:
	if gems < COSTS.shuffle: return
	var first := -1
	var second := -1
	var seen := {}
	for i in COUNT:
		if seen.has(board[i]):
			first = int(seen[board[i]])
			second = i
			break
		seen[board[i]] = i
	if first < 0:
		message = "Aynı sayı çifti yok • Çekiç kullanabilirsin"
		queue_redraw()
		return
	gems -= COSTS.shuffle
	active_tool = ""
	var matching: String = board[first]
	for i in range(COUNT-1,0,-1):
		var j := rng.randi_range(0,i)
		var temp := board[i]
		board[i] = board[j]
		board[j] = temp
	if not has_move():
		var a := board.find(matching)
		var temp := board[0]
		board[0] = board[a]
		board[a] = temp
		var b := board.find(matching,1)
		temp = board[1]
		board[1] = board[b]
		board[b] = temp
	message = "Tahta karıştırıldı • Yeni hamleler hazır"
	tone(5)
	finish_fall()

func apply_tool(cell: int) -> void:
	var tool := active_tool
	if tool.is_empty() or gems < COSTS[tool]: return
	if tool == "hammer":
		gems -= COSTS.hammer
		board[cell] = ""
		active_tool = ""
		message = "Kare kırıldı • Yeni bir fırsat"
		tone(3)
		collapse()
	elif tool == "magnet":
		var matches: Array[int] = []
		for i in COUNT:
			if i != cell and board[i] == board[cell]: matches.append(i)
		if matches.is_empty():
			message = "Bu sayının eşi yok • Başka kare seç"
			queue_redraw()
			return
		matches.append(cell)
		gems -= COSTS.magnet
		active_tool = ""
		ended = false
		chain = matches
		release_chain()

func overlay_press(p: Vector2) -> void:
	if overlay == "update":
		if Rect2(90,544,300,56).has_point(p):
			save_progress()
			var error: Error = updater.open_download()
			if error == OK: overlay = "install_help"
			else: updater.status = "İndirme açılamadı. Daha sonra tekrar dene."
		elif Rect2(90,616,300,48).has_point(p):
			updater.dismiss()
			update_requested = false
			overlay = ""
	elif overlay == "install_help":
		if Rect2(90,650,300,56).has_point(p): overlay = ""
	elif overlay == "restart":
		if Rect2(90,500,300,56).has_point(p): new_game()
		elif Rect2(90,576,300,48).has_point(p): overlay = "settings"
	elif overlay == "rules":
		if Rect2(90,678,300,48).has_point(p): overlay = "settings"
	elif overlay == "settings":
		if Rect2(90,316,300,48).has_point(p): sound_on = not sound_on
		elif Rect2(90,378,300,48).has_point(p): effects = not effects
		elif Rect2(90,440,300,48).has_point(p): overlay = "rules"
		elif Rect2(90,502,300,48).has_point(p): overlay = "restart"
		elif Rect2(90,564,300,48).has_point(p):
			if distribution_store:
				updater.open_store()
			elif updater.has_update():
				overlay = "update"
				updater.mark_prompted()
			else: updater.check(true)
		elif Rect2(90,626,300,48).has_point(p): OS.shell_open("https://halilacikgozz.github.io/color-chain-game/privacy.html")
		elif Rect2(90,688,300,48).has_point(p): overlay = ""
	save_progress()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT: cancel_pointer()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		cancel_pointer()
		overlay = "settings" if overlay.is_empty() else ""
		queue_redraw()

func save_progress() -> void:
	var file := FileAccess.open(save_path,FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"version":3,"board":board,"reserve":reserve,"score":score,"best":best,"largest":largest,"gems":gems,"sound":sound_on,"effects":effects}))

func load_progress() -> bool:
	var source := save_path
	if not FileAccess.file_exists(source) and save_path == SAVE:
		for previous in LEGACY_SAVES:
			if FileAccess.file_exists(previous):
				source = previous
				break
	if not FileAccess.file_exists(source): return false
	var data = JSON.parse_string(FileAccess.get_file_as_string(source))
	if not data is Dictionary: return false
	var version := int(data.get("version",0))
	if version < 1 or version > 3: return false
	var cells: int = COUNT if version == 3 else 49
	if not data.get("board") is Array or data.board.size() != cells: return false
	var saved_reserve = data.get("reserve",[])
	if not saved_reserve is Array or saved_reserve.size() > 49: return false
	for value in data.board+saved_reserve:
		if not value is String or not valid_number(value): return false
		if version >= 2 and power_at_least(value) != value: return false
	for key in ["score","best","largest"]:
		if not data.get(key) is String or not valid_number(data[key],key != "largest"): return false
	if version >= 2 and power_at_least(data.largest) != data.largest: return false
	var stored_gems = data.get("gems",90)
	if not (stored_gems is int or stored_gems is float) or stored_gems < 0 or stored_gems > 1000000 or stored_gems != int(stored_gems): return false
	board.clear()
	reserve.clear()
	for i in data.board.size():
		var value := power_at_least(data.board[i])
		if version < 3 and i < cells-COUNT: reserve.append(value)
		else: board.append(value)
	for value in saved_reserve: reserve.append(value)
	score = data.score
	best = data.best
	if greater(score,best): best = score
	largest = power_at_least(data.largest)
	for value in board+reserve:
		if greater(value,largest): largest = value
	gems = int(stored_gems)
	sound_on = bool(data.get("sound",true))
	effects = bool(data.get("effects",true))
	goal = "1000"
	advance_goal(false)
	ended = not has_move()
	if version < 3:
		message = "Yeni tahta • Puanın ve taşların korundu"
		save_progress()
	return true

func panel(rect: Rect2, color: Color, radius: int = 16, border: Color = Color.TRANSPARENT, line: int = 0) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(line)
	style.set_corner_radius_all(radius)
	draw_style_box(style,rect)

func label(value: String,p: Vector2,size: int,color: Color = Color("f4f3f7"),max_width: float = 420) -> void:
	while size > 10 and font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x > max_width: size -= 1
	var width := font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	draw_string(font,p-Vector2(width/2,0),value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func tile_color(value: String) -> Color:
	if not palette_cache.has(value): palette_cache[value] = COLORS[(rank_of(value)-1)%COLORS.size()]
	return palette_cache[value]

func stone(value: String,p: Vector2,selected: bool = false) -> void:
	var color := tile_color(value)
	var rect := Rect2(p-Vector2(32,32),Vector2(64,64))
	panel(Rect2(rect.position+Vector2(0,3),rect.size),Color("16171c"),12)
	var border := Color.WHITE if selected else Color.TRANSPARENT
	panel(rect.grow(3) if selected else rect,color,12,border,3 if selected else 0)
	var ink := Color("272532") if color.get_luminance() > 0.48 else Color.WHITE
	label(compact(value),p+Vector2(0,10),29,ink,58)

func trophy(p: Vector2) -> void:
	var gold := Color("ffc45f")
	draw_colored_polygon(PackedVector2Array([p+Vector2(-11,-10),p+Vector2(11,-10),p+Vector2(8,4),p+Vector2(0,10),p+Vector2(-8,4)]),gold)
	draw_arc(p+Vector2(-10,-5),7,PI/2,PI*1.5,12,gold,3,true)
	draw_arc(p+Vector2(10,-5),7,-PI/2,PI/2,12,gold,3,true)
	draw_line(p+Vector2(0,7),p+Vector2(0,16),gold,3,true)
	draw_line(p+Vector2(-7,17),p+Vector2(7,17),gold,3,true)

func diamond(p: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-11),p+Vector2(11,0),p+Vector2(0,11),p+Vector2(-11,0)]),Color("b29bff"))
	draw_line(p+Vector2(0,-8),p+Vector2(7,0),Color("e6dfff"),2,true)

func gear(p: Vector2) -> void:
	for i in 8:
		var v := Vector2.from_angle(i*TAU/8)
		draw_line(p+v*12,p+v*19,Color("e7e6ed"),5,true)
	draw_arc(p,12,0,TAU,24,Color("e7e6ed"),5,true)
	draw_circle(p,4,Color("e7e6ed"))

func tool_icon(tool: String,p: Vector2) -> void:
	if tool == "hammer":
		draw_line(p+Vector2(-10,16),p+Vector2(8,-7),Color("f5c576"),9,true)
		draw_line(p+Vector2(-3,-17),p+Vector2(19,-1),Color("a6b9fa"),16,true)
	elif tool == "shuffle":
		panel(Rect2(p+Vector2(-18,-15),Vector2(24,24)),Color("e9b651"),5)
		panel(Rect2(p+Vector2(-3,-1),Vector2(24,24)),Color("ae8cec"),5)
		draw_line(p+Vector2(-21,6),p+Vector2(-21,-12),Color.WHITE,2,true)
		draw_polyline(PackedVector2Array([p+Vector2(-27,-5),p+Vector2(-21,-12),p+Vector2(-15,-5)]),Color.WHITE,2,true)
		draw_line(p+Vector2(26,-5),p+Vector2(26,14),Color.WHITE,2,true)
		draw_polyline(PackedVector2Array([p+Vector2(20,7),p+Vector2(26,14),p+Vector2(32,7)]),Color.WHITE,2,true)
	else:
		draw_arc(p+Vector2(0,-3),16,0,PI,24,Color("fa8a87"),9,true)
		draw_line(p+Vector2(-16,-3),p+Vector2(-16,-17),Color("92b5fa"),9,true)
		draw_line(p+Vector2(16,-3),p+Vector2(16,-17),Color("92b5fa"),9,true)

func button(rect: Rect2,title: String,primary: bool = false) -> void:
	panel(rect,Color("9472dd") if primary else Color("41424c"),14)
	label(title,rect.get_center()+Vector2(0,7),20)

func _draw() -> void:
	draw_rect(Rect2(0,0,480,920),Color("303137"))
	trophy(Vector2(40,42))
	label(compact(best),Vector2(116,52),25,Color("ffc45f"),112)
	panel(Rect2(300,24,98,42),Color("24252c"),21)
	diamond(Vector2(320,45))
	label(str(gems),Vector2(364,52),20,Color("e9e2ff"),57)
	panel(Rect2(408,22,48,48),Color("24252c"),24)
	gear(Vector2(432,46))
	if updater != null and updater.has_update(): draw_circle(Vector2(449,27),5,Color("b69aff"))
	if chain.size() >= 2:
		label("OLUŞACAK TAŞ",Vector2(240,91),12,Color("c8b2fa"))
		label(compact(merge_result()),Vector2(240,139),48,tile_color(merge_result()),380)
	else:
		label("PUAN",Vector2(240,91),12,Color("b9bac5"))
		label(compact(score),Vector2(240,140),52,Color.WHITE,390)
	label("HEDEF "+compact(goal),Vector2(363,172),13,Color("c9c9d3"),150)
	label("+20 elmas",Vector2(87,172),12,Color("bfa6ef"))
	panel(Rect2(40,182,400,12),Color("1c1d22"),6)
	var progress := ratio(score,goal)
	if progress > 0: panel(Rect2(40,182,maxf(12,400*progress),12),Color("a27ee8"),6)
	if reward_flash > 0: panel(Rect2(40,182,400,12),Color(0.85,0.73,1,reward_flash*0.6),6)
	var hint := message
	if chain.size() >= 2:
		hint = str(chain.size())+" taş • Toplam "+compact(total())
	label(hint,Vector2(240,219),15,Color("d0ceda"),408)
	panel(Rect2(32,228,416,576),Color("1b1c20"),24,Color("41424a"),2)
	if phase == 2:
		var t := 1.0-pow(1.0-minf(elapsed/0.26,1),3)
		for m in motions: stone(m.value,m.from.lerp(m.to,t))
	else:
		if chain.size() >= 2:
			var points := PackedVector2Array()
			for i in chain: points.append(center(i))
			draw_polyline(points,Color("d0b9ff"),8,true)
		for i in board.size():
			if phase == 1 and chain.has(i): continue
			stone(board[i],center(i),chain.has(i))
		if phase == 1:
			var t := minf(elapsed/0.18,1)
			for m in motions: stone(m.value,m.from.lerp(m.to,t),true)
	for i in 3:
		var tool: String = ["hammer","shuffle","magnet"][i]
		var p := Vector2(128+i*112,844)
		draw_circle(p+Vector2(0,3),34,Color("202126"))
		draw_circle(p,34,Color("4a3a66") if active_tool == tool else Color("24252c"))
		if active_tool == tool: draw_arc(p,36,0,TAU,32,Color("bda0ff"),2,true)
		tool_icon(tool,p)
		label(["Çekiç","Karıştır","Mıknatıs"][i],p+Vector2(0,51),13,Color("e0dce9"))
		label(str(COSTS[tool])+" elmas",p+Vector2(0,68),11,Color("b8a7d6"))
	if ended and not end_dismissed: draw_end()
	if not overlay.is_empty(): draw_overlay()

func dim() -> void:
	draw_rect(Rect2(0,0,480,920),Color(0.04,0.04,0.06,0.86))
	panel(Rect2(58,230,364,520),Color("2d2e37"),24,Color("50505e"),1)

func draw_end() -> void:
	dim()
	label("HAMLE KALMADI",Vector2(240,302),28,Color("f3c67b"))
	label("Bu turdaki puanın",Vector2(240,350),18)
	label(compact(score),Vector2(240,413),44)
	label("En büyük taş: "+compact(largest),Vector2(240,456),18,Color("c4adee"))
	button(Rect2(90,544,300,56),"Yeni tur",true)
	button(Rect2(90,616,300,48),"Yardımcı hamle kullan")
	label("Yeni tur kendiliğinden başlamaz",Vector2(240,714),13,Color("b3b2be"))

func draw_overlay() -> void:
	dim()
	if overlay == "settings":
		label("AYARLAR",Vector2(240,276),28)
		label("Sürüm "+updater.current_name,Vector2(240,300),12,Color("b7a4d7"))
		button(Rect2(90,316,300,48),"Ses: "+("Açık" if sound_on else "Kapalı"))
		button(Rect2(90,378,300,48),"Animasyon: "+("Açık" if effects else "Sade"))
		button(Rect2(90,440,300,48),"Nasıl oynanır?")
		button(Rect2(90,502,300,48),"Yeni tur başlat")
		var update_label := "Play Store’da aç" if distribution_store else "Güncellemeleri denetle"
		if updater.checking: update_label = "Denetleniyor…"
		elif updater.has_update(): update_label = "Yeni sürüm: "+updater.latest_name
		button(Rect2(90,564,300,48),update_label)
		label(updater.status,Vector2(240,624),10,Color("c6b5de"),316)
		button(Rect2(90,626,300,48),"Gizlilik ve destek")
		button(Rect2(90,688,300,48),"Oyuna dön",true)
	elif overlay == "update":
		label("GÜNCELLEME VAR",Vector2(240,287),26,Color("d2bcff"))
		label("Yeni sürüm: "+updater.latest_name,Vector2(240,333),20)
		label("Yüklü sürüm: "+updater.current_name,Vector2(240,363),14,Color("b9b6c5"))
		for i in updater.notes.size(): label(updater.notes[i],Vector2(240,404+i*24),14,Color("e1dce9"),320)
		if updater.status.begins_with("İndirme açılamadı"): label(updater.status,Vector2(240,524),12,Color("f0a4a4"),316)
		button(Rect2(90,544,300,56),"Güncellemeyi indir",true)
		button(Rect2(90,616,300,48),"Daha sonra")
		label("Kurulum Android onayıyla tamamlanır.",Vector2(240,705),13,Color("b3b2be"))
	elif overlay == "install_help":
		label("İNDİRME AÇILDI",Vector2(240,292),25,Color("d2bcff"))
		var steps := ["1. Tarayıcıda APK indirmesini tamamla.","2. İndirilen dosyayı aç.","3. Android ekranında Güncelle'ye dokun.","Uygulamayı silmeden üzerine kur.","Puanın ve kayıtların korunur."]
		for i in steps.size(): label(steps[i],Vector2(240,369+i*43),15,Color("ded9e7"),320)
		button(Rect2(90,650,300,56),"Oyuna dön",true)
	elif overlay == "restart":
		label("YENİ TUR",Vector2(240,304),28)
		label("Bu turdaki tahta ve puan sıfırlanır.",Vector2(240,383),17)
		label("Rekorun ve elmasların korunur.",Vector2(240,414),17,Color("c5adeb"))
		button(Rect2(90,500,300,56),"Yeni tur başlat",true)
		button(Rect2(90,576,300,48),"Vazgeç")
	else:
		label("SAYI ZİNCİRİ",Vector2(240,280),27)
		var lines := ["İki aynı kareyle zinciri başlat.","Yatay, dikey ve çapraz bağlayabilirsin.","Oluşacak değeri de zincire ekleyebilirsin.","Örnek: 2 + 2 + 4 + 8 toplam 16.","Son kareyle aynı sayıyla da devam et.","Uzun zincir üst 2 kuvvetine tamamlanır.","Geri sürükleyerek seçimi kısaltabilirsin.","Çekiç bir kareyi kırar.","Karıştırma yeni eşleşmeler oluşturur.","Mıknatıs aynı sayıların hepsini toplar.","Her puan hedefi 20 elmas kazandırır."]
		for i in lines.size(): label(lines[i],Vector2(240,324+i*28),14,Color("d6d3df"),320)
		button(Rect2(90,678,300,48),"Geri",true)
