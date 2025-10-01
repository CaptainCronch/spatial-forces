extends Label
class_name PlayerNumber

const COUNTER := preload("uid://dh50vqrdb4gho")

@export var player_line: Line2D
@export var underline: Line2D
@export var camera: MultiTargetCamera
@export var counter_container: HBoxContainer
@export var player_id: Ship.PlayerIDs
#@export var fade_out_time := 0.5

var ship: Ship:
	set(new_ship):
		var score := Global.p1_score
		if new_ship.player_id == Ship.PlayerIDs.PLAYER_2:
			text = "P2"
			score = Global.p2_score
		for i in score:
			counter_container.add_child(COUNTER.instantiate())
		reset_line_reference()
		ship = new_ship

var leaving := false
var offset := 16.0
var multiplier := 0.0


func _ready() -> void:
	var color := Global.base_color
	(material as ShaderMaterial).set_shader_parameter("color_factor", color)
	#player_line.material = material
	#player_line.material.set_shader_parameter("color_factor", color)
	#var new_size := PackedVector2Array([])
	#new_size.resize(6)
	#player_line.points = new_size
	
	#if get_tree().current_scene.current_mode != get_tree().current_scene.Mode.GAME: return
	
	#var disappear := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	#disappear.tween_interval(3.0)
	#disappear.tween_method(
		#material.set_shader_parameter.bind("color_factor"),
		#color,
		#Color(color.r, color.g, color.b, 0),
		#fade_out_time
	#)


func _process(_delta: float) -> void:
	if not is_instance_valid(player_line): reset_line_reference()
	#player_line.visible = visible
	#print(player_line)
	if not ship or not visible: return
	if leaving:
		#player_line.global_position = get_global_transform_with_canvas().origin + offset
		offset = global_position.x
	var global_transform := player_line.to_local(ship.get_global_transform_with_canvas().origin + Vector2(offset - 16, 0))
	var ship_rect := Rect2(global_transform.x - 16 * camera.zoom.x, global_transform.y - 16 * camera.zoom.y, 32 * camera.zoom.x, 32 * camera.zoom.y)
	player_line.points[0] = ship_rect.position * multiplier
	player_line.points[1] = Vector2(ship_rect.position.x + ship_rect.size.x, ship_rect.position.y) * multiplier
	player_line.points[2] = Vector2(ship_rect.position.x + ship_rect.size.x, ship_rect.position.y + ship_rect.size.y) * multiplier
	player_line.points[3] = Vector2(ship_rect.position.x, ship_rect.position.y + ship_rect.size.y) * multiplier
	player_line.points[4] = ship_rect.position * multiplier
	player_line.points[5] = underline.get_global_transform_with_canvas().origin


func reset_line_reference():
	#if not is_instance_valid(new_ship):
		#new_ship = get_tree().get_first_node_in_group("Ship")
	if player_id == Ship.PlayerIDs.PLAYER_1: # i was annoyed when i wrote this because the player line would keep being null only after the scene was reset
		player_line = get_node("/root/Level").p1_line
	else:
		player_line = get_node("/root/Level").p2_line


func leave():
	leaving = true
	var mult_tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	mult_tween.tween_property(self, "multiplier", 0.0, 0.5)


func _on_visibility_changed() -> void:
	if visible:
		var mult_tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		mult_tween.tween_property(self, "multiplier", 1.0, 0.5)
	else:
		multiplier = 0.0
