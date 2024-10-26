extends Camera2D
class_name MultiTargetCamera

@export var move_speed := 0.5
@export var zoom_speed := 0.05
@export var min_zoom := 1.0
@export var max_zoom := 5.0
@export var margin := Vector2(400, 200)

var targets := []

@onready var screen_size = get_viewport_rect().size


func add_target(t):
	if not t in targets:
		targets.append(t)


func remove_target(t):
	targets.erase(t)


func _process(_delta):
	if !targets:
		return

	var p := Vector2.ZERO
	for target in targets:
		p += target.global_position
	p /= targets.size()
	global_position = global_position.lerp(p, move_speed)

	var r := Rect2(global_position, Vector2.ONE)
	for target in targets:
		r = r.expand(target.global_position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	#var d := maxf(r.size.x, r.size.y)
	var z : float #= clampf((1 / d) * screen_size.length(), min_zoom, max_zoom)
	if r.size.x > r.size.y * screen_size.aspect():
		z = clampf((1 / r.size.x) * screen_size.x, min_zoom, max_zoom)
	else:
		z = clampf((1 / r.size.y) * screen_size.y, min_zoom, max_zoom)
	zoom = zoom.lerp(Vector2.ONE * z, zoom_speed)

	#$Line2D.set_point_position(0, r.position + Vector2(r.size.x, r.size.y))
	#$Line2D.set_point_position(1, r.position + Vector2(r.size.x, 0))
	#$Line2D.set_point_position(2, r.position + Vector2(0, 0))
	#$Line2D.set_point_position(3, r.position + Vector2(0, r.size.y))
