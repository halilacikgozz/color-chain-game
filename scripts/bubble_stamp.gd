extends Node2D
# Render once into a small texture; gameplay reuses the resulting sprite.
var color := Color.WHITE
var color_index := 0
var shell_only := false
func _draw() -> void:
	var pos := Vector2(32,32)
	var radius := 23.0
	var selected := false
	var effects := false
	var time := 0.0
	var phase := 0.0
	var direction := Vector2.RIGHT
	var shell := PackedVector2Array()
	for n in 40:
		var angle := n * TAU / 40
		var wave := sin(angle * 3 + phase) * 0.035 + cos(angle * 5 - phase * 0.5) * 0.018
		var point := Vector2.from_angle(angle) * radius * (1.0 + wave)
		if false: point += direction * maxf(0.0, point.normalized().dot(direction)) * radius * 0.045
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
	if radius < 8 or shell_only: return
	var light := color.lightened(0.72)
	match color_index:
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
			var merge := 0.65 + sin(time * 5) * 0.12 if false else (0.72 if selected else 0.0)
			for n in 3:
				var offset := Vector2.from_angle(n * TAU / 3 + phase * 0.32) * radius * 0.43 * (1.0 - merge)
				var drop := pos + offset
				var size := radius * (0.21 + merge * 0.045)
				draw_circle(drop + Vector2(0, 1), size + 0.6, color.darkened(0.25))
				draw_circle(drop, size, light)
				draw_circle(drop - Vector2(size * 0.3, size * 0.35), size * 0.25, Color.WHITE)
		2:
			var pulse := sin(time * (6 if selected else 2.4)) * 0.06 if false else 0.0
			for n in 3:
				var ring := radius * (0.28 + n * 0.19 + pulse)
				draw_arc(pos, ring, 0, TAU, 32, Color(light, 0.9 - n * 0.17), maxf(1, radius * 0.065), true)
			draw_circle(pos, radius * 0.16, light)
			draw_circle(pos - Vector2(1, 1), radius * 0.07, Color.WHITE)
		3:
			var rotation := time * (2.6 if selected else 0.65) + (0.0 if selected else 0.0)
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

