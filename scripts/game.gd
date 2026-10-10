extends Node2D

const BOMB := 1
const LIGHTNING := 2
const RAINBOW := 3
const SIDE := 7
const CELL := 58.0
const ORIGIN := Vector2(37, 230)
const COLORS := [Color("ff6584"), Color("58d8ce"), Color("ffd166"), Color("9381ff")]
const PALETTES := [
	[Color("ff6584"), Color("58d8ce"), Color("ffd166"), Color("9381ff")],
	[Color("ff75dd"), Color("70f6ff"), Color("c7ff77"), Color("ae95ff")],
	[Color("ff968a"), Color("8ed6b1"), Color("ffe4a1"), Color("b7acff")],
	[Color("ff8eb8"), Color("8bdeb0"), Color("ffe08c"), Color("bb9ff5")]
]
const THEME_NAMES := ["Klasik", "Neon", "Pastel", "Çiçek Bahçesi"]
const THEME_COSTS := [0, 3, 6, 0]
const MAP_BUTTON := Rect2(37, 160, 70, 36)
const LEVELS := [
	{"name": "İlk Zincir", "moves": 12, "goal": 90, "ice": 0, "colors": 3, "hint": "Aynı renkte en az 3 komşu taşı bağla."},
	{"name": "Renk Patikası", "moves": 12, "goal": 180, "ice": 0, "colors": 3, "hint": "Uzun zincirler daha çok puan kazandırır."},
	{"name": "Bomba Bahçesi", "moves": 14, "goal": 240, "ice": 0, "colors": 3, "hint": "Bombayı zincire kat; çevresini temizle."},
	{"name": "İlk Buz", "moves": 16, "goal": 280, "ice": 6, "colors": 3, "hint": "Buzlu taşı seç veya patlamayla buzu kır."},
	{"name": "Donmuş Çiçekler", "moves": 16, "goal": 360, "ice": 8, "colors": 3, "hint": "Hem puan hedefini tamamla hem tüm buzu kır."},
	{"name": "Şimşek Yolu", "moves": 17, "goal": 450, "ice": 10, "colors": 4, "hint": "7 taş bağla; şimşekle bir satırı temizle."},
	{"name": "Kristal Yapraklar", "moves": 20, "goal": 550, "ice": 12, "colors": 4, "hint": "Özel taşları buzlu bölgeler için sakla."},
	{"name": "Renk Fırtınası", "moves": 21, "goal": 650, "ice": 14, "colors": 4, "hint": "Bombalar başka özel taşları tetikleyebilir."},
	{"name": "Gökkuşağı Köprüsü", "moves": 22, "goal": 800, "ice": 16, "colors": 4, "hint": "9 taşlık zincir gökkuşağı kazandırır."},
	{"name": "Bahçenin Kalbi", "moves": 24, "goal": 1000, "ice": 18, "colors": 4, "hint": "Final: tüm buzları kır ve 1000 puana ulaş!"}
]
const WORLD_NAMES := ["Palmiye Adası", "Buz Vadisi", "Yeraltı Adası"]
const WORLD_TABS := [Rect2(25, 95, 140, 94), Rect2(170, 95, 140, 94), Rect2(315, 95, 140, 94)]
const DAILY_BUTTON := Rect2(25, 652, 140, 40)
const COLLECTION_BUTTON := Rect2(170, 652, 140, 40)
const LEAGUE_BUTTON := Rect2(315, 652, 140, 40)
const EXTRA_LEVELS := [
 {"name":"Kar Kapısı","moves":26,"goal":700,"ice":8,"colors":3,"mission":"bomb","target":1},
 {"name":"Kristal Köprü","moves":27,"goal":850,"ice":10,"colors":3,"mission":"chain","target":7},
 {"name":"Buz Sarkıtları","moves":28,"goal":950,"ice":12,"colors":3,"mission":"lightning","target":1},
 {"name":"Çifte Don","moves":29,"goal":1000,"ice":10,"colors":3,"mission":"bomb","target":2},
 {"name":"Kutup Işığı","moves":30,"goal":1100,"ice":12,"colors":3,"mission":"rainbow","target":1},
 {"name":"Kar Fırtınası","moves":30,"goal":1200,"ice":14,"colors":4,"mission":"chain","target":8},
 {"name":"Donmuş Göl","moves":31,"goal":1300,"ice":14,"colors":3,"mission":"lightning","target":2},
 {"name":"Buz Labirenti","moves":32,"goal":1400,"ice":16,"colors":4,"mission":"bomb","target":3},
 {"name":"Kutup Zirvesi","moves":33,"goal":1500,"ice":16,"colors":3,"mission":"rainbow","target":1},
 {"name":"Buzun Kalbi","moves":34,"goal":1700,"ice":18,"colors":3,"mission":"chain","target":9},
 {"name":"Neon Kapısı","moves":27,"goal":1000,"ice":0,"colors":3,"mission":"relay","target":5},
 {"name":"Elektrik Bulvarı","moves":28,"goal":1200,"ice":0,"colors":3,"mission":"lightning","target":2},
 {"name":"Işık Köprüsü","moves":29,"goal":1400,"ice":0,"colors":3,"mission":"relay","target":7},
 {"name":"Enerji Hattı","moves":30,"goal":1500,"ice":0,"colors":4,"mission":"bomb","target":3},
 {"name":"Prizma Meydanı","moves":31,"goal":1700,"ice":0,"colors":3,"mission":"rainbow","target":2},
 {"name":"Neon Tüneli","moves":32,"goal":1900,"ice":0,"colors":4,"mission":"relay","target":9},
 {"name":"Voltaj Kulesi","moves":33,"goal":2100,"ice":0,"colors":3,"mission":"lightning","target":3},
 {"name":"Renk Fabrikası","moves":34,"goal":2300,"ice":0,"colors":3,"mission":"chain","target":10},
 {"name":"Gece Yarışı","moves":35,"goal":2500,"ice":0,"colors":4,"mission":"relay","target":11},
 {"name":"Şehrin Kalbi","moves":36,"goal":2800,"ice":0,"colors":3,"mission":"rainbow","target":2}
]
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
var campaign_mode := false
const HOME_JOURNEY := Rect2(100, 202, 280, 44)
const HOME_DAILY := Rect2(32, 272, 416, 94)
const HOME_COLLECTION := Rect2(32, 380, 416, 94)
const HOME_LEAGUE := Rect2(32, 488, 416, 94)
const HOME_PLAY := Rect2(32, 606, 416, 88)
const HOME_SETTINGS := Rect2(405, 741, 44, 44)
var home_open := false
var settings_open := false
var navigation_origin := "game"
var map_open := false
var stage := 0
var moves_left := 0
var stage_won := false
var stage_rating := 0
var ice: Array[int] = []
var level_stars: Array[int] = [0,0,0,0,0,0,0,0,0,0]
var level_bests: Array[int] = [0,0,0,0,0,0,0,0,0,0]
var prior_timed := true
var competition_client: Node
var league_open := false
var league_data: Dictionary = {}
var league_message := "Günlük yarış puanların haftalık lige sayılır."
var world_page := 0
var island_overview := true
var chapter_page := 0
var chapter_textures: Array[ImageTexture] = []
const CHAPTER_PREV := Rect2(22,660,112,40)
const CHAPTER_NEXT := Rect2(346,660,112,40)
var island_texture: ImageTexture
const ISLAND_ZONES := [Rect2(10, 454, 330, 231), Rect2(160, 254, 310, 198), Rect2(10, 65, 330, 189)]
const ISLAND_LABELS := [Vector2(178, 635), Vector2(330, 426), Vector2(157, 225)]
var daily_random := 1
var daily_replay: Array = []
var daily_mode := false
var daily_day := ""
var daily_best := 0
var daily_rewarded := ""
var daily_attempts := 0
var mission_count := 0
var relay: Array[int] = []
var crystals := 0
var owned_cosmetics: Array[int] = [0]
var cosmetic := 0
var collection_open := false
var celebration := 0.0
var arrival := 0.0
var new_unlock := -1
var fx_rng := RandomNumberGenerator.new()
var audio_player: AudioStreamPlayer
var sound_on := true
var sound_phase := 0.0
var last_tone := -1
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
	fx_rng.randomize()
	setup_sound()
	competition_client = load("res://scripts/competition.gd").new()
	add_child(competition_client)
	competition_client.updated.connect(league_updated)
	competition_client.failed.connect(league_failed)
	level_stars.resize(30)
	level_stars.fill(0)
	level_bests.resize(30)
	level_bests.fill(0)
	load_progress()
	save_best()
	restart()
	home_open = true

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
	level_stars.resize(30)
	level_bests.resize(30)
	for i in 30:
		level_stars[i] = clampi(int(config.get_value("garden", "stars_%d" % i, 0)), 0, 3)
		level_bests[i] = maxi(0, int(config.get_value("garden", "best_%d" % i, 0)))
	theme_index = clampi(int(config.get_value("progress", "theme", 0)), 0, PALETTES.size() - 1)
	if stars < THEME_COSTS[theme_index]:
		theme_index = 0
	if theme_index == 3 and not garden_unlocked():
		theme_index = 0
	palette = PALETTES[theme_index]
	crystals = maxi(0, int(config.get_value("collection", "crystals", 0)))
	if not config.has_section_key("collection", "crystals"):
		for rating in level_stars:
			if rating > 0: crystals += 25
	owned_cosmetics.assign(config.get_value("collection", "owned", [0]))
	if not owned_cosmetics.has(0): owned_cosmetics.append(0)
	cosmetic = clampi(int(config.get_value("collection", "active", 0)), 0, 3)
	if not owned_cosmetics.has(cosmetic): cosmetic = 0
	daily_day = str(config.get_value("daily", "day", ""))
	daily_best = maxi(0, int(config.get_value("daily", "best", 0)))
	daily_rewarded = str(config.get_value("daily", "rewarded", ""))
	daily_attempts = maxi(0, int(config.get_value("daily", "attempts", 0)))
	sound_on = bool(config.get_value("settings", "sound", true))

func save_best() -> void:
	var config := ConfigFile.new()
	config.set_value("game", "best", best)
	config.set_value("progress", "timed_best", timed_best)
	config.set_value("progress", "xp", xp)
	config.set_value("progress", "stars", stars)
	config.set_value("progress", "quests_done", quests_done)
	config.set_value("progress", "quest_progress", quest_progress)
	config.set_value("progress", "theme", theme_index)
	for i in 30:
		config.set_value("garden", "stars_%d" % i, level_stars[i])
		config.set_value("garden", "best_%d" % i, level_bests[i])
	config.set_value("collection", "crystals", crystals)
	config.set_value("collection", "owned", owned_cosmetics)
	config.set_value("collection", "active", cosmetic)
	config.set_value("daily", "day", daily_day)
	config.set_value("daily", "best", daily_best)
	config.set_value("daily", "rewarded", daily_rewarded)
	config.set_value("daily", "attempts", daily_attempts)
	config.set_value("settings", "sound", sound_on)
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
	if timed_mode and not campaign_mode and not daily_mode:
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
	if index < 0 or index >= PALETTES.size() or stars < THEME_COSTS[index] or (index == 3 and not garden_unlocked()):
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
	map_open = false
	home_open = false
	settings_open = false
	stage_won = false
	stage_rating = 0
	mission_count = 0
	celebration = 0.0
	arrival = 0.0
	new_unlock = -1
	collection_open = false
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
	ice.resize(SIDE * SIDE)
	ice.fill(0)
	relay.resize(49)
	relay.fill(0)
	board.resize(SIDE * SIDE)
	specials.resize(SIDE * SIDE)
	specials.fill(0)
	offsets.resize(SIDE * SIDE)
	offsets.fill(0.0)
	for i in board.size():
		board[i] = random_color(active_colors())
	ensure_move()
	board[1] = board[0]
	board[2] = board[0]
	specials[1] = BOMB
	message = "Bomba taşını aynı renkte 3+ zincire kat!" if timed_mode else "Rahat mod • Bomba ile başla"
	if daily_mode:
		setup_daily()
	elif campaign_mode:
		setup_stage()
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	arrival = maxf(0.0, arrival - delta)
	if ended: celebration += delta
	feed_sound()
	impact = maxf(0.0, impact - delta * 3.0)
	if focused and started and not ended and not profile_open and not collection_open and not league_open and not map_open and not home_open and not settings_open:
		combo_left = maxf(0.0, combo_left - delta)
		if combo_left <= 0.0:
			combo = 0
		if timed_mode and not campaign_mode and not daily_mode:
			remaining = maxf(0.0, remaining - delta)
			if remaining <= 0.0 and not busy:
				end_round()
	for i in range(special_waves.size() - 1, -1, -1):
		special_waves[i]["age"] += delta
		if special_waves[i]["age"] >= 0.9:
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

func chain_color() -> int:
	for index in chain:
		if specials[index] != RAINBOW:
			return board[index]
	return -1

func can_join_chain(index: int) -> bool:
	var color := chain_color()
	return specials[index] == RAINBOW or color == -1 or board[index] == color

func select_cell(index: int) -> void:
	if index < 0 or busy or ended or profile_open or collection_open or league_open or map_open or home_open or settings_open:
		return
	if chain.is_empty():
		chain.append(index)
	elif chain.size() >= 2 and index == chain[chain.size() - 2]:
		chain.pop_back()
	elif not chain.has(index) and adjacent(chain.back(), index) and can_join_chain(index):
		chain.append(index)
	if chain.size() != last_tone:
		last_tone = chain.size()
		play_tone(260 + chain.size() * 45, 0.06)
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
		open_home()

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
	if settings_open:
		if PROFILE_BACK.has_point(pos): open_home()
		elif Rect2(37,210,406,64).has_point(pos): sound_on = not sound_on
		elif Rect2(37,290,406,64).has_point(pos): effects = not effects
		save_best()
		return
	if home_open:
		if HOME_JOURNEY.has_point(pos):
			home_open = false
			island_overview = true
			map_open = true
		elif HOME_DAILY.has_point(pos): start_daily()
		elif HOME_COLLECTION.has_point(pos):
			home_open = false
			collection_open = true
			navigation_origin = "home"
		elif HOME_LEAGUE.has_point(pos):
			home_open = false
			league_open = true
			navigation_origin = "home"
			league_message = "Sıralama yükleniyor…"
			competition_client.send({"action":"leaderboard"})
		elif HOME_PLAY.has_point(pos): start_free_play()
		elif HOME_SETTINGS.has_point(pos):
			home_open = false
			settings_open = true
		return
	if league_open:
		if PROFILE_BACK.has_point(pos):
			league_open = false
			if navigation_origin == "home": open_home()
		elif Rect2(37, 620, 406, 48).has_point(pos):
			league_message = "Lig yükleniyor…"
			competition_client.send({"action":"leaderboard"})
		return
	if daily_mode and ended and Rect2(80, 570, 320, 55).has_point(pos):
		league_open = true
		navigation_origin = "game"
		league_message = "Puan gönderiliyor…"
		competition_client.send({"action":"submit", "day":daily_day, "moves":daily_replay})
		return
	if collection_open:
		if PROFILE_BACK.has_point(pos):
			collection_open = false
			if navigation_origin == "home": open_home()
			else: map_open = true
		elif Rect2(37, 630, 406, 44).has_point(pos):
			sound_on = not sound_on
			save_best()
		else:
			for i in 4:
				if Rect2(37, 180 + i * 95, 406, 80).has_point(pos): buy_cosmetic(i)
		return
	if map_open:
		if island_overview:
			if PROFILE_BACK.has_point(pos): open_home()
			else:
				for i in 3:
					if ISLAND_ZONES[i].has_point(pos):
						world_page = i
						chapter_page = chapter_default_page(i)
						island_overview = false
			return
		if Rect2(12,12,48,48).has_point(pos):
			island_overview = true
			return
		if PROFILE_BACK.has_point(pos):
			island_overview = true
			return
		if CHAPTER_PREV.has_point(pos):
			chapter_page = 0
			return
		if CHAPTER_NEXT.has_point(pos):
			chapter_page = 1
			return
		for i in range(chapter_page*5,chapter_page*5+5):
			if map_node(i).distance_to(pos) <= 32 and stage_unlocked(world_page * 10 + i):
				start_stage(world_page * 10 + i)
		return
	if MAP_BUTTON.has_point(pos) and not profile_open:
		if not busy:
			if not campaign_mode:
				prior_timed = timed_mode
			open_home()
		return
	if profile_open:
		if PROFILE_BACK.has_point(pos):
			profile_open = false
		else:
			for i in PALETTES.size():
				if Rect2(37, 350 + i * 66, 406, 60).has_point(pos):
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
		if campaign_mode and stage_won:
			if stage < 29:
				start_stage(stage + 1)
			else:
				map_open = true
		else:
			restart()
		return
	if MODE_BUTTON.has_point(pos):
		if campaign_mode or daily_mode:
			map_open = true
			return
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
	if busy or ended or profile_open or collection_open or league_open or map_open or home_open or settings_open:
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
	combo = 1 if daily_mode else (mini(5, combo + 1) if combo_left > 0.0 else 1)
	combo_left = COMBO_WINDOW
	if daily_mode: daily_replay.append(chain.duplicate())
	prepare_resolution()
	var extra := maxi(0, clear_cells.size() + (1 if reward_anchor >= 0 else 0) - count)
	var gained := (count * 10 + maxi(0, count - 3) * 5 + extra * 10) * combo
	score += gained
	best = maxi(best, score)
	longest = maxi(longest, count)
	moves += 1
	if campaign_mode or daily_mode:
		moves_left -= 1
		if stage_data().get("mission", "") == "chain" and campaign_mode:
			mission_count = maxi(mission_count, count)
	var bonus := mini(5, count - 2) if count >= 5 and timed_mode and not campaign_mode and not daily_mode else 0
	remaining = minf(ROUND_SECONDS, remaining + bonus)
	message = "%d taş • +%d puan%s" % [count, gained, " • +%d sn" % bonus if bonus > 0 else ""]
	update_progress(count, gained)
	if reward_kind != 0:
		message = "%s kazandın! Sonraki zincirde kullan." % special_name(reward_kind)
	var middle := center(chain[chain.size() / 2])
	if effects:
		floaters.append({"pos": middle, "text": "+%d" % gained, "life": 1.0, "color": Color("ffd166")})
		if bonus > 0:
			floaters.append({"pos": middle + Vector2(0, 30), "text": "+%d SANİYE" % bonus, "life": 1.2, "color": Color("58d8ce")})
		impact = minf(1.0, count / 8.0)
		for index in clear_cells:
			for n in 8:
				var angle := fx_rng.randf_range(0.0, TAU)
				particles.append({"pos": center(index), "velocity": Vector2.from_angle(angle) * fx_rng.randf_range(60, 150), "life": fx_rng.randf_range(0.35, 0.65), "color": palette[board[index]]})
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
	reward_kind = RAINBOW if chain.size() >= 9 else (LIGHTNING if chain.size() >= 7 else (BOMB if chain.size() >= 5 else 0))
	var target_color := chain_color()
	if target_color < 0:
		target_color = board[chain.front()]
	var paired := []
	for index in chain:
		if specials[index] > 0: paired.append(specials[index])
	if paired.has(BOMB) and paired.has(LIGHTNING):
		for index in chain:
			if specials[index] == LIGHTNING:
				for other in 49:
					if absi(other / 7 - index / 7) <= 1 or other % 7 == index % 7:
						if not clear_cells.has(other): clear_cells.append(other)
		combo_notice("BOMBA + ŞİMŞEK!")
	if paired.has(RAINBOW) and (paired.has(BOMB) or paired.has(LIGHTNING)):
		for other in 49:
			if board[other] == target_color and specials[other] == 0:
				specials[other] = BOMB if paired.has(BOMB) else LIGHTNING
		combo_notice("GÖKKUŞAĞI KOMBİNASYONU!")
	var activated: Array[int] = []
	var cursor := 0
	while cursor < clear_cells.size():
		var index: int = clear_cells[cursor]
		cursor += 1
		if specials[index] == 0 or activated.has(index):
			continue
		activated.append(index)
		if campaign_mode and stage_data().get("mission", "") == special_name_key(specials[index]): mission_count += 1
		if effects:
			var targets := PackedVector2Array()
			if specials[index] == RAINBOW:
				for target in board.size():
					if board[target] == target_color or specials[target] == RAINBOW:
						targets.append(center(target))
			special_waves.append({"kind": specials[index], "pos": center(index), "age": 0.0, "targets": targets})
		if specials[index] == LIGHTNING:
			var row := index / SIDE
			for x in SIDE:
				var affected := row * SIDE + x
				if not clear_cells.has(affected):
					clear_cells.append(affected)
		elif specials[index] == RAINBOW:
			for target in board.size():
				if (board[target] == target_color or specials[target] == RAINBOW) and not clear_cells.has(target):
					clear_cells.append(target)
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
	if campaign_mode:
		for index in clear_cells:
			if ice[index] > 0:
				ice[index] -= 1
				if effects:
					floaters.append({"pos": center(index), "text": "BUZ!", "life": 0.7, "color": Color("b9f5ff")})
	if campaign_mode and stage >= 20:
		for index in clear_cells:
			if relay[index] > 0:
				relay[index] = 0
				mission_count += 1
	if reward_anchor >= 0:
		clear_cells.erase(reward_anchor)
		board[reward_anchor] = target_color

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
			board[target * SIDE + x] = random_color(active_colors())
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
	arrival = 0.32 if effects else 0.0
	ensure_move()
	busy = false
	if daily_mode:
		if moves_left <= 0: finish_daily()
	elif campaign_mode:
		check_stage_end()
	elif timed_mode and remaining <= 0.0:
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
		board[i] = random_color(active_colors())
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
		var y := 350 + i * 66
		var unlocked: bool = stars >= THEME_COSTS[i] and (i != 3 or garden_unlocked())
		box(Rect2(37, y, 406, 60), Color("25385a") if theme_index == i else Color("172139"))
		label_at(THEME_NAMES[i], Vector2(115, y + 24), 18, Color.WHITE if unlocked else Color("9caac7"))
		var status: String = "SEÇİLİ" if theme_index == i else ("SEÇ" if unlocked else "%d / %d yıldız" % [stars, THEME_COSTS[i]])
		if i == 3 and not unlocked:
			status = "10 bölümü tamamla"
		label_at(status, Vector2(115, y + 48), 13, Color("58d8ce") if unlocked else Color("9caac7"))
		for j in 4:
			draw_circle(Vector2(250 + j * 45, y + 30), 13, Color(PALETTES[i][j], 1.0 if unlocked else 0.35))
	text("60 SN MADALYAN: %s" % medal(timed_best), 643, 19, Color("ffd166"))
	text("Süreli rekor: %d • %s" % [timed_best, next_medal(timed_best)], 671, 15, Color("9caac7"))
	text("Görevler ve deneyim her iki modda kazanılır.", 695, 14, Color("9caac7"))
	box(PROFILE_BACK, Color("526bd8"))
	text("Oyuna dön", 746, 22)
	text("Tur duraklatıldı • İlerleme bu cihazda saklanır", 788, 14, Color("9caac7"))

func stage_data() -> Dictionary:
	return LEVELS[stage] if stage < 10 else EXTRA_LEVELS[stage - 10]

func active_colors() -> int:
	return int(stage_data()["colors"]) if campaign_mode else 4

func garden_unlocked() -> bool:
	return level_stars.size() >= 10 and level_stars[9] > 0

func stage_unlocked(index: int) -> bool:
	return index >= 0 and index < 30 and (index == 0 or level_stars[index - 1] > 0)

func start_stage(index: int) -> bool:
	if not stage_unlocked(index):
		return false
	if not campaign_mode:
		prior_timed = timed_mode
	daily_mode = false
	campaign_mode = true
	timed_mode = false
	stage = index
	world_page = stage / 10
	restart()
	return true

func leave_campaign() -> void:
	campaign_mode = false
	daily_mode = false
	timed_mode = prior_timed
	restart()

func setup_stage() -> void:
	rng.seed = 8123 + stage * 173
	moves_left = int(stage_data()["moves"])
	for i in 49:
		board[i] = random_color(active_colors())
		specials[i] = 0
		ice[i] = 0
	# A visible opening chain teaches each mechanic without a random dead start.
	for x in 7:
		board[x] = 0 if x < (3 if stage == 0 else 5) else 1
	if stage >= 2:
		specials[1] = BOMB
	if stage >= 5:
		specials[4] = LIGHTNING
	if stage >= 8:
		specials[3] = RAINBOW
	var candidates: Array[int] = []
	for i in range(7, 49):
		candidates.append(i)
	for n in int(stage_data()["ice"]):
		var pick := rng.randi_range(0, candidates.size() - 1)
		ice[candidates[pick]] = 1
		candidates.remove_at(pick)
	if stage == 6:
		ice.fill(0)
		for i in range(7, 19):
			ice[i] = 1
			board[i] = 0
	if stage >= 10:
		for i in range(0, 14): board[i] = 0
		specials[1] = BOMB
		specials[4] = LIGHTNING
		specials[10] = RAINBOW
		if stage < 20:
			for i in 49:
				if ice[i] > 0: ice[i] = 2
		else:
			for i in int(stage_data().get("target", 5)):
				relay[7 + i] = 1
	ensure_move()
	message = str(stage_data().get("hint", mission_label()))

func ice_left() -> int:
	var total := 0
	for layer in ice: total += layer
	return total

func check_stage_end() -> void:
	if ended:
		return
	if score >= int(stage_data()["goal"]) and ice_left() == 0 and mission_complete():
		stage_won = true
		var budget: int = stage_data()["moves"]
		stage_rating = 3 if moves_left >= ceili(budget * 0.5) else (2 if moves_left >= ceili(budget * 0.2) else 1)
		var first_win := level_stars[stage] == 0
		level_stars[stage] = maxi(level_stars[stage], stage_rating)
		level_bests[stage] = maxi(level_bests[stage], score)
		if first_win:
			xp += 50
			round_xp += 50
			crystals += 25
		new_unlock = stage + 1
		celebration = 0.0
		play_tone(880, 0.25)
		ended = true
		cancel_selection()
		save_best()
	elif moves_left <= 0:
		ended = true
		stage_won = false
		stage_rating = 0
		cancel_selection()
	queue_redraw()

func map_node(index: int) -> Vector2:
	var positions := [
		[Vector2(172,606),Vector2(256,493),Vector2(154,316),Vector2(353,326),Vector2(309,146)],
		[Vector2(164,605),Vector2(279,499),Vector2(330,351),Vector2(165,268),Vector2(294,159)],
		[Vector2(238,625),Vector2(267,458),Vector2(145,286),Vector2(345,267),Vector2(246,129)]
	]
	return positions[world_page][index % 5]

func draw_garden_background() -> void:
	draw_rect(Rect2(0, 0, 480, 800), Color("0d241e"))
	for n in 14:
		var x := 12.0 + float(n % 2) * 450
		var y := 38.0 + n * 52
		draw_circle(Vector2(x, y), 25, Color(0.2, 0.5, 0.3, 0.14))
		for j in 5:
			draw_circle(Vector2(x, y) + Vector2.from_angle(j * TAU / 5) * 8, 4, Color(1, 0.65, 0.75, 0.25))

func load_island_art() -> void:
	if island_texture != null: return
	var image := Image.new()
	var bytes := Marshalls.base64_to_raw(FileAccess.get_file_as_string("res://assets/island-map.txt"))
	if image.load_jpg_from_buffer(bytes) == OK:
		island_texture = ImageTexture.create_from_image(image)

func draw_island_overview() -> void:
	load_island_art()
	if island_texture != null:
		draw_texture_rect(island_texture, Rect2(0,0,480,800), false)
	else: draw_rect(Rect2(0,0,480,800), Color("23b5d0"))
	if effects:
		for sparkle in 8:
			var point := Vector2(378 + sin(sparkle*2.7)*51, 106 + sparkle*76)
			var alpha := maxf(0.0,sin(elapsed*1.7+sparkle))*0.6
			draw_line(point-Vector2(3,0),point+Vector2(3,0),Color(1,1,0.88,alpha),1,true)
			draw_line(point-Vector2(0,3),point+Vector2(0,3),Color(1,1,0.88,alpha),1,true)
	# The illustration stays decorative; all labels, locks and progress are live.
	box(Rect2(70,12,340,48), Color("85522c"), 18)
	label_at("ADA YOLCULUĞU", Vector2(240,44), 27, Color("fff2d2"))
	box(Rect2(121,63,238,26), Color(0.04,0.25,0.35,0.82), 12)
	label_at("Yeni dünyaları keşfet", Vector2(240,81), 14, Color.WHITE)
	var centers := [Vector2(177,552), Vector2(343,337), Vector2(166,159)]
	for world in 3:
		var completed := 0
		var stars := 0
		for level in range(world*10,world*10+10):
			if level_stars[level] > 0: completed += 1
			stars += level_stars[level]
		var unlocked := stage_unlocked(world*10)
		var accent: Color = [Color("ff658b"),Color("47c8f4"),Color("af70e3")][world]
		var label: Vector2 = ISLAND_LABELS[world]
		if world > 0:
			var previous: Vector2 = centers[world-1]
			for dot in range(1,9):
				var point := previous.lerp(centers[world], float(dot)/9)
				point.x += sin(float(dot)/9*PI)*42
				draw_circle(point, 2.5, Color(1,1,0.85,0.55 + (sin(elapsed*2-dot)*0.2 if effects else 0)))
		box(Rect2(label-Vector2(109,20),Vector2(218,35)),Color("233b59"),12)
		box(Rect2(label-Vector2(106,23),Vector2(212,33)),accent,12)
		label_at(WORLD_NAMES[world].to_upper(),label+Vector2(0,1),18,Color.WHITE)
		var bar := Rect2(label+Vector2(-96,17),Vector2(192,23))
		box(bar,Color("233b59"),11)
		if completed > 0:
			box(Rect2(bar.position+Vector2(3,3),Vector2(186.0*completed/10,17)), Color("a9ec48") if world==0 else accent,8)
		label_at("%d / 10 bölüm" % completed,bar.get_center()+Vector2(0,5),14,Color.WHITE)
		box(Rect2(label+Vector2(-71,43),Vector2(142,21)),Color(0.04,0.19,0.3,0.84),9)
		label_at("%d / 30 yıldız" % stars if unlocked else "KİLİTLİ • Önceki final",label+Vector2(0,58),11,Color("fff0b6"))
	box(PROFILE_BACK,Color("168dda"),22)
	text("Ana menü",746,23,Color.WHITE)

func draw_world_card(world: int) -> void:
	var rect: Rect2 = WORLD_TABS[world]
	var origin := rect.position
	var selected := world == world_page
	var accent: Color = [Color("a5e988"), Color("9ce8ff"), Color("ee9dff")][world]
	box(rect, [Color("193e2b"), Color("163854"), Color("2a1946")][world], 12)
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color.TRANSPARENT
	frame.border_color = accent if selected else Color(accent, 0.25)
	frame.set_border_width_all(2 if selected else 1)
	frame.set_corner_radius_all(12)
	draw_style_box(frame, rect)
	var t := elapsed if effects else 0.0
	if world == 0:
		# A tiny garden: rolling grass, curved leaves and a blooming flower.
		draw_colored_polygon(PackedVector2Array([origin+Vector2(9,56),origin+Vector2(36,43),origin+Vector2(75,51),origin+Vector2(108,39),origin+Vector2(131,53),origin+Vector2(131,63),origin+Vector2(9,63)]), Color("2e6842"))
		for n in 3:
			var stem := origin + Vector2(34+n*35, 55)
			var tip := stem + Vector2(sin(t*1.4+n)*2, -24-n%2*7)
			draw_line(stem, tip, Color("95d783"), 2, true)
			draw_colored_polygon(PackedVector2Array([stem+Vector2(0,-8),stem+Vector2(-13,-18),stem+Vector2(-15,-9),stem]), Color("69bd75"))
			for petal in 5:
				draw_circle(tip+Vector2.from_angle(petal*TAU/5)*6, 4, Color("ffb9cf") if n%2==0 else Color("ffdc8c"))
			draw_circle(tip, 3, Color("fff3b4"))
		draw_circle(origin+Vector2(119,20), 7, Color("efdc90"))
	elif world == 1:
		for n in 3:
			var base := origin+Vector2(12+n*38,60)
			var peak := base+Vector2(21,-39+n%2*9)
			draw_colored_polygon(PackedVector2Array([base,peak,base+Vector2(45,0)]), Color("477fa6"))
			draw_colored_polygon(PackedVector2Array([peak,peak+Vector2(-10,18),peak+Vector2(0,13),peak+Vector2(11,19)]), Color("e1f6ff"))
		var crystal := origin+Vector2(79,47)
		draw_colored_polygon(PackedVector2Array([crystal+Vector2(0,-21),crystal+Vector2(9,-7),crystal+Vector2(7,12),crystal+Vector2(-7,12),crystal+Vector2(-9,-7)]), Color("77d5ef"))
		draw_line(crystal+Vector2(0,-21),crystal+Vector2(0,12),Color("d9faff"),2,true)
		for n in 4:
			var snow := origin+Vector2(20+n*29,16+sin(t+n)*3)
			draw_circle(snow, 1.6, Color("daf7ff"))
	else:
		for n in 5:
			var height := 23.0 + float((n*17)%27)
			var building := Rect2(origin+Vector2(13+n*24,62-height),Vector2(18,height))
			draw_rect(building,Color("442466"))
			draw_line(building.position,building.position+Vector2(18,0),Color("ef88eb"),2,true)
			for row in int(height/9):
				draw_rect(Rect2(building.position+Vector2(4,5+row*9),Vector2(3,3)),Color("77e6ef"))
			draw_line(origin+Vector2(10,63),origin+Vector2(130,63),Color("66d6eb"),1,true)
		draw_arc(origin+Vector2(110,23),9,0,TAU,24,Color("e3a2ff"),2,true)
		draw_circle(origin+Vector2(110+cos(t)*9,23+sin(t)*9),2,Color("f7d4ff"))
	label_at(["Bahçe", "Buz Vadisi", "Neo Şehir"][world], origin+Vector2(70,83), 15, accent if selected else Color("d1dce2"))
	if selected: draw_circle(origin+Vector2(126,80),3,accent)

func chapter_default_page(world: int) -> int:
	for local_stage in 10:
		var level := world*10+local_stage
		if stage_unlocked(level) and level_stars[level] == 0: return local_stage / 5
	return 1 if level_stars[world*10+9] > 0 else 0

func load_chapter_art() -> void:
	if chapter_textures.size() == 3: return
	chapter_textures.clear()
	for world in 3:
		var picture := Image.new()
		var bytes := Marshalls.base64_to_raw(FileAccess.get_file_as_string("res://assets/chapter-%d.txt" % world))
		if picture.load_jpg_from_buffer(bytes) == OK:
			chapter_textures.append(ImageTexture.create_from_image(picture))
		else: chapter_textures.append(null)

func draw_map() -> void:
	if island_overview:
		draw_island_overview()
		return
	load_chapter_art()
	if chapter_textures[world_page] != null:
		draw_texture_rect(chapter_textures[world_page],Rect2(0,0,480,800),false)
	else: draw_world_background(world_page)
	var colors := [Color("865126"),Color("25648d"),Color("57316e")]
	var panel: Color = colors[world_page]
	box(Rect2(65,12,345,45),panel,16)
	label_at(WORLD_NAMES[world_page].to_upper(),Vector2(238,41),25,Color("fff5dc"))
	box(Rect2(12,12,45,45),panel,22)
	label_at("‹",Vector2(34,43),35,Color.WHITE)
	var total := 0
	for level in range(world_page*10,world_page*10+10): total += level_stars[level]
	box(Rect2(131,62,218,26),Color(0.02,0.10,0.19,0.85),12)
	label_at("%d / 30 yıldız • Bölümler %d–%d" % [total,chapter_page*5+1,chapter_page*5+5],Vector2(240,80),13,Color("ffeab3"))
	var next_level := -1
	for level in range(world_page*10,world_page*10+10):
		if stage_unlocked(level) and level_stars[level] == 0:
			next_level = level
			break
	for local_stage in range(chapter_page*5,chapter_page*5+5):
		var level := world_page*10+local_stage
		var point := map_node(local_stage)
		var unlocked := stage_unlocked(level)
		var active := level == next_level
		if active:
			draw_circle(point,33+(sin(elapsed*3)*3 if effects else 0),Color(1,0.87,0.3,0.35))
			var bubble := point+Vector2(0,-42+(sin(elapsed*2)*4 if effects else 0))
			draw_circle(bubble,13,Color(0.7,0.9,1,0.65))
			draw_arc(bubble,13,0,TAU,32,Color(1,1,1,0.9),2,true)
			draw_circle(bubble+Vector2(-4,-5),3,Color.WHITE)
		draw_circle(point+Vector2(0,3),26,Color(0.03,0.05,0.1,0.7))
		draw_circle(point,25,panel if unlocked else Color("46515b"))
		draw_arc(point,25,0,TAU,40,Color("ffe098") if unlocked else Color("a3afb9"),3,true)
		label_at(str(local_stage+1),point+Vector2(0,8),26,Color.WHITE)
		if not unlocked:
			var lock := point+Vector2(18,16)
			draw_arc(lock-Vector2(0,3),5,PI,TAU,12,Color("ffdb88"),2,true)
			box(Rect2(lock-Vector2(6,1),Vector2(12,10)),Color("b79861"),2)
		var data: Dictionary = LEVELS[level] if level < 10 else EXTRA_LEVELS[level-10]
		box(Rect2(point+Vector2(-91,28),Vector2(182,24)),Color(panel,0.94),7)
		label_at(data["name"],point+Vector2(0,45),13,Color.WHITE)
		draw_rating(point+Vector2(0,58),level_stars[level],6)
	if effects:
		for particle in 8:
			var point := Vector2(19+particle*62,105+fmod(particle*91.0+elapsed*(8 if world_page==1 else -5),490))
			draw_circle(point,2,Color(0.7,0.9,1,0.45) if world_page==1 else Color(1,0.8,0.4,0.45))
	box(CHAPTER_PREV,panel if chapter_page==1 else Color(panel,0.65),14)
	label_at("‹ 1–5",CHAPTER_PREV.get_center()+Vector2(0,6),18,Color.WHITE)
	box(CHAPTER_NEXT,panel if chapter_page==0 else Color(panel,0.65),14)
	label_at("6–10 ›",CHAPTER_NEXT.get_center()+Vector2(0,6),18,Color.WHITE)
	box(PROFILE_BACK,panel,20)
	text("Adalara dön",746,23,Color.WHITE)

func draw_rating(center: Vector2, rating: int, radius: float) -> void:
	for n in 3:
		var pos := center + Vector2((n - 1) * radius * 2.8, 0)
		var points := PackedVector2Array()
		for j in 10:
			points.append(pos + Vector2.from_angle(-PI / 2 + j * TAU / 10) * radius * (1.0 if j % 2 == 0 else 0.45))
		draw_colored_polygon(points, Color("ffd166") if n < rating else Color("355b44"))
		points.append(points[0])
		draw_polyline(points, Color("ffe6a3") if n < rating else Color("63806c"), 1.0, true)

func draw_stage_result() -> void:
	draw_rect(Rect2(ORIGIN - Vector2(9, 9), Vector2.ONE * (SIDE * CELL + 18)), Color(0.03, 0.1, 0.08, 0.94))
	text("BÖLÜM TAMAMLANDI!" if stage_won else "BİR KEZ DAHA DENE", 340, 27, Color("b8f0cc"))
	draw_rating(Vector2(240, 388), mini(stage_rating, int(celebration / 0.25) + 1) if stage_won and effects else stage_rating, 20)
	text("%d PUAN • %d HAMLE KALDI" % [score, moves_left], 448, 19)
	text("İlk başarı: +50 deneyim +25 kristal" if stage_won else "Hedef: %d puan ve tüm buzlar" % stage_data()["goal"], 493, 18, Color("9eb8a6"))
	text("Çiçek Bahçesi teması açıldı!" if stage_won and stage == 9 else ("Bölüm yıldızların kaydedildi." if stage_won else "%d buz kaldı; özel taşları kullan." % ice_left()), 540, 19, Color("ffd166"))
	text("3 yıldız: hamlelerin en az yarısı kalsın.", 588, 15, Color("9eb8a6"))

func special_name(kind: int) -> String:
	match kind:
		BOMB: return "Bomba"
		LIGHTNING: return "Şimşek"
		_: return "Gökkuşağı"

func draw_special_icon(kind: int, pos: Vector2, radius: float) -> void:
	var time := elapsed if effects else 0.0
	draw_arc(pos, radius + 2, 0, TAU, 48, Color(1, 1, 1, 0.85), 1.5, true)
	if kind == BOMB:
		draw_circle(pos + Vector2(0, 2), 13, Color("090e22"))
		draw_circle(pos + Vector2(-2, 0), 10, Color("283652"))
		draw_circle(pos + Vector2(-5, -4), 3.5, Color("92a4c5"))
		draw_arc(pos + Vector2(4, -9), 7, -PI * 0.8, -PI * 0.05, 16, Color("ffd166"), 2.5, true)
		var spark := pos + Vector2(11, -14)
		for n in 6:
			var ray := Vector2.from_angle(n * TAU / 6 + time * 2)
			draw_line(spark + ray * 2, spark + ray * (4.5 + sin(time * 12)), Color("fff4b3"), 1.5, true)
		draw_circle(spark, 2.3, Color.WHITE)
	elif kind == LIGHTNING:
		var bolt := PackedVector2Array([Vector2(3, -17), Vector2(-10, 2), Vector2(-1, 2), Vector2(-4, 17), Vector2(11, -4), Vector2(2, -4)])
		var outline := PackedVector2Array()
		for point in bolt:
			outline.append(pos + point)
		draw_circle(pos, 17, Color(0.1, 0.3, 0.7, 0.55))
		draw_colored_polygon(outline, Color("fff4b3"))
		for n in 3:
			var angle := time * 2 + n * TAU / 3
			draw_arc(pos, 19, angle, angle + 0.65, 12, Color(0.7, 1, 1, 0.75), 2, true)
	else:
		draw_circle(pos, 17, Color("172139"))
		for n in 8:
			var angle := n * TAU / 8 + time * 0.8
			var color := Color.from_hsv(float(n) / 8, 0.7, 1.0)
			draw_arc(pos, 13, angle, angle + TAU / 8 - 0.05, 12, color, 5, true)
			draw_circle(pos + Vector2.from_angle(angle) * 20, 2, color)
		var star := PackedVector2Array([pos + Vector2(0, -8), pos + Vector2(3, -2), pos + Vector2(8, 0), pos + Vector2(3, 2), pos + Vector2(0, 8), pos + Vector2(-3, 2), pos + Vector2(-8, 0), pos + Vector2(-3, -2)])
		draw_colored_polygon(star, Color.WHITE)

func draw_special_effect(wave: Dictionary) -> void:
	var age: float = wave["age"]
	var pos: Vector2 = wave["pos"]
	var alpha := clampf(1.0 - age / 0.9, 0.0, 1.0)
	if wave["kind"] == BOMB:
		# Concentric blast rings, radial sparks, and a short-lived hot core.
		for n in 3:
			var progress := maxf(0.0, age - n * 0.08)
			draw_arc(pos, 15 + progress * 170, 0, TAU, 64, Color(1, 0.65 + n * 0.12, 0.25, alpha), 5 - n, true)
		draw_circle(pos, 20 + age * 90, Color(1, 0.5, 0.15, alpha * alpha * 0.18))
		for n in 16:
			var ray := Vector2.from_angle(n * TAU / 16)
			draw_line(pos + ray * (15 + age * 110), pos + ray * (25 + age * 160), Color(1, 0.9, 0.5, alpha), 3 * alpha + 1, true)
	elif wave["kind"] == LIGHTNING:
		for layer in 3:
			var points := PackedVector2Array()
			for n in 29:
				points.append(Vector2(ORIGIN.x + n * CELL / 4, pos.y + sin(n * 2.3 + age * 50 + layer) * (7 + layer * 5) * alpha))
			draw_polyline(points, Color(0.3, 0.85, 1, alpha * 0.18), 18 - layer * 3, true)
			draw_polyline(points, Color(0.8, 1, 1, alpha), 3 - layer * 0.7, true)
		for n in 7:
			var spark := Vector2(ORIGIN.x + (n + 0.5) * CELL, pos.y)
			draw_line(spark, spark + Vector2(12 * sin(n * 3 + age * 20), -25 * alpha), Color(0.7, 1, 1, alpha), 2, true)
			draw_arc(spark, 10 + age * 20, 0, TAU, 20, Color(0.6, 0.9, 1, alpha * 0.5), 2, true)
	else:
		for n in 8:
			var angle := n * TAU / 8 + age * 3
			var color := Color.from_hsv(float(n) / 8, 0.65, 1.0, alpha)
			draw_arc(pos, 20 + age * 150, angle, angle + TAU / 8, 16, color, 4, true)
		var targets: PackedVector2Array = wave.get("targets", PackedVector2Array())
		for n in targets.size():
			var color := Color.from_hsv(fmod(float(n) / 7 + age, 1.0), 0.6, 1.0, alpha)
			var tip := pos.lerp(targets[n], minf(1.0, age * 4))
			draw_line(pos, tip, Color(color, alpha * 0.22), 6, true)
			draw_circle(tip, 4 * alpha + 1, color)
			draw_arc(targets[n], 8 + age * 22, 0, TAU, 24, color, 2, true)

func _draw() -> void:
	if home_open:
		draw_home()
		return
	if settings_open:
		draw_settings()
		return
	if league_open:
		draw_league()
		return
	if collection_open:
		draw_collection()
		return
	if map_open:
		draw_map()
		return
	if profile_open:
		draw_profile()
		return
	if campaign_mode:
		draw_world_background(stage / 10)
	elif theme_index == 3:
		draw_garden_background()
	var tension := campaign_mode or daily_mode
	var urgent := tension and moves_left <= 3 and not ended
	var accent := Color("ffd166") if remaining > 10 or not timed_mode else Color("ff6584")
	text("%s %d" % [WORLD_NAMES[stage / 10].to_upper(), stage % 10 + 1] if campaign_mode else ("GÜNLÜK YARIŞ" if daily_mode else "COLOR CHAIN"), 52, 30)
	text("SV %d • %d yıldız • Hedefler ve ödüller ›" % [player_level(), stars], 78, 16, Color("58d8ce"))
	box(Rect2(37, 92, 195, 36), Color("172139"))
	box(Rect2(248, 92, 195, 36), Color("172139"))
	label_at("HAMLE  %d" % moves_left if campaign_mode or daily_mode else ("SÜRE  %02d" % ceili(remaining) if timed_mode else "RAHAT MOD  ∞"), Vector2(134, 116), 18, accent)
	label_at("BUZ  %d" % ice_left() if campaign_mode else ("GÜNLÜK  %d" % daily_best if daily_mode else "REKOR  %d" % best), Vector2(346, 116), 18, Color("58d8ce"))
	box(Rect2(37, 137, 406, 5), Color("172139"), 2)
	box(Rect2(37, 137, 406 * remaining / ROUND_SECONDS if timed_mode else 406, 5), accent, 2)
	if urgent:
		box(Rect2(37, 92, 195, 36), Color(1, 0.2, 0.4, 0.2 + (sin(elapsed * 5) * 0.1 if effects else 0.0)), 12)
	text("SKOR  %d" % score, 181, 30, Color.WHITE.lerp(accent, impact))
	box(MAP_BUTTON, Color("285b51"), 8)
	label_at("MENÜ", Vector2(72, 183), 12, Color("b8f0cc"))
	text(message, 211, 14, Color("9caac7"))
	text("5+: BOMBA  •  7+: ŞİMŞEK  •  9+: GÖKKUŞAĞI", 151, 10, Color("9caac7"))
	var shake := Vector2(sin(elapsed * 55), cos(elapsed * 49)) * impact * 2 if effects else Vector2.ZERO
	draw_set_transform(shake)
	box(Rect2(ORIGIN - Vector2(9, 9), Vector2.ONE * (SIDE * CELL + 18)), Color("172139"), 20)
	for i in board.size():
		var pos := center(i) + Vector2(0, offsets[i] * fall_progress + (sin(arrival * 30 + i % 7 * 0.3) * arrival * 8 if effects and not busy else 0))
		if pos.y < ORIGIN.y:
			continue
		var selected := chain.has(i)
		var radius := 23.0
		if selected and effects:
			radius += 1.5 + sin(elapsed * 9) * 1.2
		if popping.has(i):
			radius *= 1.0 - pop_progress
		if campaign_mode and relay[i] > 0:
			draw_arc(pos, 26, 0, TAU, 32, Color("70f6ff"), 3, true)
		if campaign_mode and ice[i] > 0:
			box(Rect2(pos - Vector2(26, 26), Vector2(52, 52)), Color(0.6, 0.9, 1.0, 0.22), 10)
			draw_line(pos + Vector2(-19, -18), pos + Vector2(14, -18), Color("c2f5ff"), 2, true)
			draw_line(pos + Vector2(19, -13), pos + Vector2(19, 16), Color("c2f5ff"), 2, true)
		if selected and effects:
			draw_circle(pos, radius + 6, Color(palette[board[i]], 0.15))
		draw_living_bubble(i, pos, radius, selected)
		if cosmetic == 1: draw_arc(pos, radius - 3, 0, TAU, 32, Color(1, 1, 1, 0.7), 1.5, true)
		elif cosmetic == 2: draw_line(pos + Vector2(-12, -6), pos + Vector2(12, 6), Color(1, 1, 1, 0.5), 2, true)
		elif cosmetic == 3: draw_arc(pos, radius + 1, elapsed if effects else 0.0, (elapsed if effects else 0.0) + PI, 24, Color("fff4b3"), 2, true)
		if radius > 10:
			if specials[i] != 0:
				draw_special_icon(specials[i], pos, radius)


	if chain.size() > 1 and not busy:
		for i in range(1, chain.size()):
			draw_line(center(chain[i - 1]), center(chain[i]), Color(palette[board[chain[i]]], 0.25), 16, true)
			draw_line(center(chain[i - 1]), center(chain[i]), Color("fff4b3") if cosmetic == 3 else Color.WHITE, 4 + minf(3, chain.size() / 3.0), true)
	if effects and chain.size() > 1 and not busy:
		var segment := int(elapsed * 5) % (chain.size() - 1)
		draw_circle(center(chain[segment]).lerp(center(chain[segment + 1]), fmod(elapsed * 5, 1.0)), 5, Color("ffd166"))
	for index in chain:
		if not busy:
			draw_arc(center(index), 27, 0, TAU, 40, Color.WHITE, 2, true)
	for wave in special_waves:
		draw_special_effect(wave)
	for particle in particles:
		draw_circle(particle["pos"], 3.5, Color(particle["color"], minf(1.0, particle["life"] * 2)))
	for floater in floaters:
		label_at(floater["text"], floater["pos"], 24, Color(floater["color"], minf(1.0, floater["life"] * 2)))
	draw_set_transform(Vector2.ZERO)
	if daily_mode:
		text("UTC %s • 20 hamlede en yüksek puan" % daily_day, 662, 15, Color("b8f0cc"))
	elif campaign_mode:
		text("Hedef: %d / %d puan • %d buz kaldı" % [score, stage_data()["goal"], ice_left()], 655, 14, Color("b8f0cc"))
		if stage >= 10: text(mission_label(), 678, 13, Color("70f6ff"))
	elif combo >= 2 and not ended:
		text("KOMBO x%d" % combo, 662, 22, Color("ffd166"))
		box(Rect2(145, 672, 190 * combo_left / COMBO_WINDOW, 3), Color("ffd166"), 1)
	else:
		text("Görev: %s (%d/%d)" % [quest_title(), quest_progress, quest_target()], 662, 15, Color("9caac7"))
	box(RESTART, Color("526bd8"))
	text(("Sonraki bölüm" if stage < 29 else "Dünyalar tamamlandı!") if campaign_mode and stage_won else ("Tekrar dene" if ended else "Yeniden başlat"), 723, 21)
	box(MODE_BUTTON, Color("172139"), 9)
	box(EFFECTS_BUTTON, Color("172139"), 9)
	label_at("Bölüm haritası" if campaign_mode or daily_mode else ("Mod: 60 sn" if timed_mode else "Mod: Rahat"), Vector2(134, 775), 15, Color("9caac7"))
	label_at("Efektler: Açık" if effects else "Efektler: Sade", Vector2(346, 775), 15, Color("9caac7"))
	if campaign_mode and ended:
		draw_stage_result()
	elif daily_mode and ended:
		draw_daily_result()
	elif ended:
		draw_rect(Rect2(ORIGIN - Vector2(9, 9), Vector2.ONE * (SIDE * CELL + 18)), Color(0.03, 0.05, 0.1, 0.9))
		text("%s MADALYA" % medal(score) if score >= 100 else "TUR TAMAMLANDI", 354, 28, Color("ffd166"))
		text("%d PUAN" % score, 415, 38)
		text("En uzun zincir: %d taş" % longest, 465, 20, Color("58d8ce"))
		text("+%d deneyim • Seviye %d" % [round_xp, player_level()], 500, 19, Color("9caac7"))
		text(next_medal(score), 545, 20, Color("ffd166"))
		text("Yeni tur için Tekrar oyna'ya dokun.", 592, 16, Color("9caac7"))

func special_name_key(kind: int) -> String:
	return ["", "bomb", "lightning", "rainbow"][kind]

func mission_complete() -> bool:
	return stage < 10 or mission_count >= int(stage_data().get("target", 0))

func mission_label() -> String:
	if not campaign_mode or stage < 10: return "Uzun zincirler kur, özel taşları birleştir!"
	var kind: String = stage_data().get("mission", "")
	var title: String = {"bomb":"Bomba etkinleştir", "lightning":"Şimşek etkinleştir", "rainbow":"Gökkuşağı etkinleştir", "chain":"En uzun zincir", "relay":"Enerji düğümü temizle"}.get(kind, "Görev")
	return "%s: %d / %d" % [title, mission_count, stage_data().get("target", 0)]

func combo_notice(value: String) -> void:
	if effects:
		floaters.append({"pos":Vector2(240, 410), "text":value, "life":1.5, "color":Color("70f6ff")})
	play_tone(540, 0.15)

func utc_day() -> String:
	return Time.get_date_string_from_system(true)

func setup_daily() -> void:
	var today := utc_day()
	if daily_day != today:
		daily_day = today
		daily_best = 0
		daily_attempts = 0
	daily_random = (int(daily_day.replace("-", "")) * 71 + 501) & 2147483647
	daily_replay.clear()
	moves_left = 20
	for i in 49:
		board[i] = random_color(4)
		specials[i] = 0
	board[1] = board[0]
	board[2] = board[0]
	specials[1] = BOMB
	ensure_move()
	message = "Aynı günlük tahta • Kombo x1 • 20 hamle"

func start_daily() -> void:
	if not campaign_mode and not daily_mode: prior_timed = timed_mode
	campaign_mode = false
	daily_mode = true
	timed_mode = false
	restart()

func finish_daily() -> void:
	ended = true
	daily_attempts += 1
	daily_best = maxi(daily_best, score)
	if daily_rewarded != daily_day and score >= 500:
		daily_rewarded = daily_day
		crystals += 40
		xp += 50
		round_xp += 50
	celebration = 0.0
	cancel_selection()
	save_best()

func draw_daily_result() -> void:
	draw_rect(Rect2(ORIGIN - Vector2(9, 9), Vector2.ONE * (SIDE * CELL + 18)), Color(0.03, 0.05, 0.1, 0.94))
	text("GÜNLÜK YARIŞ TAMAMLANDI", 340, 24, Color("70f6ff"))
	text("%d PUAN" % score, 401, 36)
	text("Bugünün en iyisi: %d" % daily_best, 451, 22, Color("ffd166"))
	text("500 puan: günde bir +40 kristal", 502, 17, Color("9eb8a6"))
	text("Ödül kazanıldı" if daily_rewarded == daily_day else "Ödül için tekrar dene", 545, 20, Color("ffd166"))
	box(Rect2(80, 570, 320, 55), Color("526bd8"))
	text("Haftalık lige gönder", 604, 20)
	text("Lig için internet bağlantısı gerekir.", 643, 13, Color("9eb8a6"))

func buy_cosmetic(index: int) -> bool:
	if index < 0 or index > 3: return false
	var cost: int = [0, 75, 125, 200][index]
	if not owned_cosmetics.has(index):
		if crystals < cost: return false
		crystals -= cost
		owned_cosmetics.append(index)
	cosmetic = index
	save_best()
	return true

func draw_collection() -> void:
	draw_world_background(2)
	text("KOLEKSİYON", 50, 30, Color("70f6ff"))
	text("%d KRİSTAL" % crystals, 96, 26, Color("ffd166"))
	text("Bölüm ilk başarıları ve günlük yarış ödülleri", 131, 15, Color("9eb8a6"))
	for i in 4:
		var y := 180 + i * 95
		box(Rect2(37, y, 406, 80), Color("25385a") if cosmetic == i else Color("172139"))
		label_at(["Klasik", "İnci Halkası", "Kristal Kesim", "Altın Yörünge"][i], Vector2(180, y + 29), 22, Color.WHITE)
		var status := "SEÇİLİ" if cosmetic == i else ("SEÇ" if owned_cosmetics.has(i) else "%d kristal" % [0,75,125,200][i])
		label_at(status, Vector2(180, y + 58), 16, Color("ffd166"))
		draw_circle(Vector2(374, y + 39), 22, PALETTES[1][i])
		if i == 1: draw_arc(Vector2(374, y + 39), 20, 0, TAU, 32, Color.WHITE, 1.5, true)
		elif i == 2: draw_line(Vector2(362,y+33),Vector2(386,y+45),Color.WHITE,2,true)
		elif i == 3: draw_arc(Vector2(374, y + 39), 25, elapsed if effects else 0.0, (elapsed if effects else 0.0)+PI, 32, Color("fff4b3"), 2, true)
	text("Görünümler güç avantajı sağlamaz.", 592, 16, Color("9eb8a6"))
	box(Rect2(37, 630, 406, 44), Color("25385a"))
	text("Ses: Açık" if sound_on else "Ses: Kapalı", 659, 20)
	box(PROFILE_BACK, Color("526bd8"))
	text("Oyuna dön", 746, 22)

func draw_world_background(world: int) -> void:
	if world == 0:
		draw_garden_background()
	else:
		draw_rect(Rect2(0, 0, 480, 800), Color("0b2138") if world == 1 else Color("130b2b"))
		for i in 22:
			var movement := elapsed * (9 if world == 1 else 4) if effects else 0.0
			var pos := Vector2(fmod(i * 131.0 + sin(elapsed + i) * (9 if effects else 0), 470) + 5, fmod(i * 67.0 + movement, 800))
			if world == 1:
				draw_line(pos - Vector2(3,0), pos + Vector2(3,0), Color(0.7,0.9,1,0.35), 1, true)
				draw_line(pos - Vector2(0,3), pos + Vector2(0,3), Color(0.7,0.9,1,0.35), 1, true)
			else:
				draw_rect(Rect2(pos, Vector2(18, 25)), Color(0.6,0.2,1,0.12))
				draw_line(pos, pos + Vector2(18,0), Color(0.3,0.9,1,0.3), 2, true)
	if ended and stage_won and effects:
		for i in 26:
			var pos := Vector2(fmod(i * 97.0, 460) + 10, fmod(i * 53.0 + celebration * 100, 800))
			draw_rect(Rect2(pos, Vector2(4,7)), Color.from_hsv(float(i) / 26, 0.6, 1.0, maxf(0,1-celebration/6)))

func setup_sound() -> void:
	if DisplayServer.get_name() == "headless": return
	audio_player = AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = 0.15
	audio_player.stream = stream
	audio_player.volume_db = -18
	add_child(audio_player)

var tone_frequency := 0.0
var tone_remaining := 0.0
func play_tone(frequency: float, duration: float) -> void:
	if not sound_on or not effects or audio_player == null: return
	if not audio_player.playing: audio_player.play()
	tone_frequency = frequency
	tone_remaining = duration

func feed_sound() -> void:
	if audio_player == null or not audio_player.playing: return
	var playback = audio_player.get_stream_playback()
	if playback == null: return
	for i in mini(playback.get_frames_available(), 4096):
		var value := 0.0
		if tone_remaining > 0 and sound_on:
			value = sin(sound_phase) * minf(1.0, tone_remaining * 40) * 0.35
			sound_phase = fmod(sound_phase + TAU * tone_frequency / 22050, TAU)
			tone_remaining = maxf(0.0, tone_remaining - 1.0/22050)
		playback.push_frame(Vector2(value, value))

func random_color(count: int) -> int:
	if not daily_mode: return rng.randi_range(0, count - 1)
	daily_random = (daily_random * 1103515245 + 12345) & 2147483647
	return (daily_random >> 16) % count

func league_updated(data: Dictionary) -> void:
	league_data = data
	league_message = "İlk 5 oyuncu sonraki hafta yükselir."
func league_failed(value: String) -> void:
	league_message = value
func draw_league() -> void:
	draw_world_background(2)
	text("HAFTALIK LİG", 50, 30, Color("70f6ff"))
	var tier := clampi(int(league_data.get("tier",0)), 0, 3)
	text(["Bronz", "Gümüş", "Altın", "Elmas"][tier], 98, 27, Color("ffd166"))
	text(league_message, 143, 14, Color("9eb8a6"))
	var rows: Array = league_data.get("rows", [])
	if rows.is_empty():
		text("Gerçek oyuncuların sonuçları burada görünür.", 260, 17, Color("9eb8a6"))
		text("Günlük en iyi puanların haftalık toplamı yarışır.", 305, 15, Color("9eb8a6"))
		text("Hesap bağlantısı tamamlanınca lig açılır.", 348, 16, Color("ffd166"))
	else:
		var self_rank := 0
		for row in rows:
			if row.get("self",false): self_rank = int(row["rank"])
		text("Sıran: %d / %d" % [self_rank, rows.size()], 188, 19, Color("ffd166"))
		var shown: Array = rows.slice(0,8)
		if self_rank > 8: shown.append(rows[self_rank-1])
		for i in shown.size():
			var row: Dictionary = shown[i]
			var y := 218 + i * 40
			box(Rect2(37,y,406,34),Color("25385a") if row.get("self",false) else Color("172139"),7)
			label_at("%d. %s" % [row["rank"],row["name"]],Vector2(170,y+23),16,Color.WHITE)
			label_at(str(int(row["score"])),Vector2(380,y+23),16,Color("ffd166"))
	box(Rect2(37,620,406,48),Color("526bd8"))
	text("Sıralamayı yenile",650,20)
	box(PROFILE_BACK,Color("355b44"))
	text("Oyuna dön",746,22)

func draw_living_bubble(index: int, pos: Vector2, radius: float, selected: bool) -> void:
	if radius < 0.5: return
	var color: Color = palette[board[index]]
	var time := elapsed if effects else 0.0
	var phase := time * 1.8 + (0.0 if selected else index * 0.73)
	var direction := Vector2.RIGHT
	var link := chain.find(index)
	if selected and chain.size() > 1:
		var other: int = chain[link + 1] if link < chain.size() - 1 else chain[link - 1]
		direction = (center(other) - center(index)).normalized()
	var shell := PackedVector2Array()
	for n in 40:
		var angle := n * TAU / 40
		var wave := sin(angle * 3 + phase) * 0.035 + cos(angle * 5 - phase * 0.5) * 0.018
		var point := Vector2.from_angle(angle) * radius * (1.0 + wave)
		if selected and effects: point += direction * maxf(0.0, point.normalized().dot(direction)) * radius * 0.045
		shell.append(pos + point)
	var shadow := PackedVector2Array()
	for point in shell: shadow.append(point + Vector2(0, 3))
	draw_colored_polygon(shadow, Color("070f22"))
	draw_colored_polygon(shell, color.darkened(0.45))
	draw_circle(pos - Vector2(1, 2), radius * 0.87, Color(color, 0.52))
	draw_circle(pos - Vector2(radius * 0.13, radius * 0.18), radius * 0.68, Color(color.lightened(0.2), 0.17))
	shell.append(shell[0])
	draw_polyline(shell, Color(color.lightened(0.55), 0.82), maxf(0.7, radius * 0.045), true)
	draw_arc(pos, radius * 0.9, PI * 1.12, PI * 1.78, 18, Color(1, 1, 1, 0.67), maxf(0.8, radius * 0.075), true)
	draw_arc(pos + Vector2(0, 1), radius * 0.85, 0.2, 1.1, 12, Color(color.lightened(0.6), 0.45), 1, true)
	if radius < 8 or specials[index] != 0: return
	var light := color.lightened(0.72)
	match board[index]:
		0:
			var ribbon := PackedVector2Array()
			var angle := direction.angle() if selected else sin(phase * 0.4) * 0.13
			for n in 28:
				var t := float(n) / 27
				var point := Vector2(sin(t * TAU + 0.3) * radius * 0.36, (t - 0.5) * radius * 1.23)
				ribbon.append(pos + point.rotated(angle))
			draw_polyline(ribbon, color.darkened(0.3), radius * 0.3, true)
			draw_polyline(ribbon, light, radius * 0.23, true)
			var gleam := PackedVector2Array()
			for point in ribbon: gleam.append(point + Vector2(-radius * 0.055, -radius * 0.025))
			draw_polyline(gleam, Color(1, 1, 1, 0.65), radius * 0.055, true)
		1:
			var merge := 0.65 + sin(time * 5) * 0.12 if selected and effects else (0.72 if selected else 0.0)
			for n in 3:
				var offset := Vector2.from_angle(n * TAU / 3 + phase * 0.32) * radius * 0.43 * (1.0 - merge)
				var drop := pos + offset
				var size := radius * (0.21 + merge * 0.045)
				draw_circle(drop + Vector2(0, 1), size + 0.6, color.darkened(0.25))
				draw_circle(drop, size, light)
				draw_circle(drop - Vector2(size * 0.3, size * 0.35), size * 0.25, Color.WHITE)
		2:
			var pulse := sin(time * (6 if selected else 2.4)) * 0.06 if effects else 0.0
			for n in 3:
				var ring := radius * (0.28 + n * 0.19 + pulse)
				draw_arc(pos, ring, 0, TAU, 32, Color(light, 0.9 - n * 0.17), maxf(1, radius * 0.065), true)
			draw_circle(pos, radius * 0.16, light)
			draw_circle(pos - Vector2(1, 1), radius * 0.07, Color.WHITE)
		3:
			var rotation := time * (2.6 if selected else 0.65) + (0.0 if selected else index * 0.73)
			var orbit := PackedVector2Array()
			for n in 41:
				var t := n * TAU / 40
				orbit.append(pos + Vector2(cos(t) * radius * 0.66, sin(t) * radius * 0.36).rotated(-0.65))
			draw_polyline(orbit, Color(light, 0.7), maxf(1, radius * 0.06), true)
			for n in 2:
				var t := rotation + n * PI
				var core := pos + Vector2(cos(t) * radius * 0.66, sin(t) * radius * 0.36).rotated(-0.65)
				draw_circle(core, radius * 0.24, Color(light, 0.14))
				draw_circle(core, radius * 0.17, light)
				draw_circle(core - Vector2(1, 1), radius * 0.055, Color.WHITE)

func open_home() -> void:
	cancel_selection()
	home_open = true
	map_open = false
	profile_open = false
	collection_open = false
	league_open = false
	settings_open = false
	queue_redraw()

func start_free_play() -> void:
	campaign_mode = false
	daily_mode = false
	timed_mode = false
	prior_timed = false
	restart()

func menu_icon(kind: String, pos: Vector2, color: Color) -> void:
	match kind:
		"play":
			draw_colored_polygon(PackedVector2Array([pos+Vector2(-10,-16),pos+Vector2(17,0),pos+Vector2(-10,16)]),color)
		"trophy":
			var cup := PackedVector2Array([pos+Vector2(-15,-19),pos+Vector2(15,-19),pos+Vector2(12,1),pos+Vector2(5,8),pos+Vector2(-5,8),pos+Vector2(-12,1)])
			draw_colored_polygon(cup,color)
			draw_arc(pos+Vector2(-14,-11),10,PI*0.5,PI*1.5,16,color,3,true)
			draw_arc(pos+Vector2(14,-11),10,-PI*0.5,PI*0.5,16,color,3,true)
			draw_line(pos+Vector2(0,7),pos+Vector2(0,19),color,5,true)
			box(Rect2(pos+Vector2(-13,18),Vector2(26,5)),color,2)
		"layers":
			var top := PackedVector2Array([pos+Vector2(-20,-9),pos+Vector2(0,1),pos+Vector2(20,-9),pos+Vector2(0,-19),pos+Vector2(-20,-9)])
			draw_polyline(top,color,3,true)
			for i in 2:
				var y := 1 + i * 10
				draw_polyline(PackedVector2Array([pos+Vector2(-20,y),pos+Vector2(0,y+10),pos+Vector2(20,y)]),color,3,true)
		"medal":
			draw_line(pos+Vector2(-13,-22),pos+Vector2(-4,-6),color,6,true)
			draw_line(pos+Vector2(13,-22),pos+Vector2(4,-6),color,6,true)
			draw_arc(pos+Vector2(0,8),14,0,TAU,32,color,3,true)
			draw_circle(pos+Vector2(0,8),5,color)
		"path":
			draw_line(pos+Vector2(0,-11),pos+Vector2(0,2),color,2,true)
			draw_line(pos+Vector2(0,2),pos+Vector2(-13,10),color,2,true)
			draw_line(pos+Vector2(0,2),pos+Vector2(13,10),color,2,true)
			for offset in [Vector2(0,-12),Vector2(-14,11),Vector2(14,11)]: draw_arc(pos+offset,4,0,TAU,16,color,2,true)
		"gear":
			draw_arc(pos,9,0,TAU,24,color,3,true)
			for i in 8:
				var direction := Vector2.from_angle(i*TAU/8)
				draw_line(pos+direction*10,pos+direction*15,color,4,true)

func home_card(rect: Rect2, title: String, subtitle: String, kind: String, gold: bool = false) -> void:
	box(Rect2(rect.position+Vector2(0,4),rect.size),Color(0.01,0.06,0.04,0.55),20)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("263f2b") if gold else Color("163d2d")
	style.border_color = Color("d5b567") if gold else Color("37654d")
	style.set_border_width_all(2 if gold else 1)
	style.set_corner_radius_all(20)
	draw_style_box(style,rect)
	var accent := Color("f2cf7f") if gold else Color("bce2c2")
	menu_icon(kind,rect.position+Vector2(49,46),accent)
	var x := rect.position.x+96
	draw_string(font,Vector2(x,rect.position.y+41),title,HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("eef6d7"))
	draw_string(font,Vector2(x,rect.position.y+68),subtitle,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("a8c9ae"))
	var arrow := rect.position+Vector2(rect.size.x-25,46)
	draw_polyline(PackedVector2Array([arrow+Vector2(-4,-7),arrow+Vector2(3,0),arrow+Vector2(-4,7)]),accent,2.5,true)

func draw_home() -> void:
	draw_rect(Rect2(0,0,480,800),Color("09281b"))
	for i in 8:
		var pos := Vector2(-20 if i%2==0 else 493,25+i*106)
		draw_circle(pos,48,Color(0.2,0.4,0.25,0.14))
		draw_arc(pos,48,0,TAU,32,Color(0.4,0.6,0.35,0.12),1,true)
	text("COLOR CHAIN",89,39,Color("e3f4d4"))
	if board.size() >= 4:
		for i in 4:
			var old_color: int = board[i]
			var old_special: int = specials[i]
			board[i] = i
			specials[i] = 0
			draw_living_bubble(i,Vector2(126+i*76,155),27,false)
			board[i] = old_color
			specials[i] = old_special
	menu_icon("path",Vector2(111,225),Color("bce2c2"))
	label_at("Bölüm Yolculuğu",Vector2(255,232),20,Color("cee7cb"))
	draw_polyline(PackedVector2Array([Vector2(365,218),Vector2(372,225),Vector2(365,232)]),Color("bce2c2"),2.5,true)
	home_card(HOME_DAILY,"Günlük Etkinlik","Bugünün meydan okuması","trophy",true)
	home_card(HOME_COLLECTION,"Koleksiyon","Baloncuk görünümlerini keşfet","layers")
	home_card(HOME_LEAGUE,"Haftalık Sıralama","Bu haftanın en iyileri","medal")
	box(Rect2(HOME_PLAY.position+Vector2(0,4),HOME_PLAY.size),Color("062015"),20)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("14864c")
	style.border_color = Color("50cb85")
	style.set_border_width_all(2)
	style.set_corner_radius_all(20)
	draw_style_box(style,HOME_PLAY)
	menu_icon("play",Vector2(91,648),Color("e3f4d4"))
	label_at("Serbest Oyna",Vector2(271,647),27,Color("eef6d7"))
	label_at("Sınırsız hamle, rahat oyun",Vector2(271,675),15,Color("c4e6c3"))
	menu_icon("gear",HOME_SETTINGS.get_center(),Color("a6d3b0"))

func draw_settings() -> void:
	draw_rect(Rect2(0,0,480,800),Color("09281b"))
	text("AYARLAR",80,30,Color("e3f4d4"))
	box(Rect2(37,210,406,64),Color("163d2d"))
	text("Ses: Açık" if sound_on else "Ses: Kapalı",250,23)
	box(Rect2(37,290,406,64),Color("163d2d"))
	text("Animasyonlar: Açık" if effects else "Animasyonlar: Sade",330,23)
	box(PROFILE_BACK,Color("14864c"))
	text("Ana menüye dön",746,22)
