extends Line2D
class_name Trail

@export var target: Node2D
@export var max_length := 20
@export var resolution_factor := 1
@export var deletion_factor := 5
@export var randomness_range := 0.0
@export var sway_range := 0.0
@export var sway_speed := 0.0

var res_count := resolution_factor
var delete_count := deletion_factor
var sway_count := 0.0
var sway_direction := 1


func _physics_process(delta: float) -> void:
	res_count -= 1
	if res_count > 0:
		if get_point_count() > 0:
			points[maxi(0, get_point_count() - 1)] = target.global_position
		return
	res_count = resolution_factor
	sway_count += sway_speed * sway_direction * delta
	if sway_count > sway_range or sway_count < -sway_range: sway_direction *= -1
	var sway := Vector2(0.0, sway_count).rotated(target.global_rotation)
	var random := Vector2(randfn(0.0, randomness_range), randfn(0.0, randomness_range))
	add_point(target.global_position + random + sway)
	#set_point_position(get_point_count()-2, get_point_position(get_point_count()-2) + random + sway)
	if get_point_count() > max_length:
		remove_point(0)
		if get_point_count() > max_length:
			delete_count -= 1
			if delete_count <= 0:
				delete_count = deletion_factor
				remove_point(0)
