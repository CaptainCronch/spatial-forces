extends Line2D
class_name Trail

@export var target: Node2D
@export var max_length := 20
@export var resolution_factor := 1
@export var deletion_factor := 5
@export var randomness_range := 0.0

var res_count := resolution_factor
var delete_count := deletion_factor


func _physics_process(_delta: float) -> void:
	res_count -= 1
	if res_count > 0:
		if get_point_count() > 0:
			points[maxi(0, get_point_count() - 1)] = target.global_position
		return
	res_count = resolution_factor
	#trail.global_position = Vector2()
	#trail.global_rotation = 0
	#trail_point = trail_start_point.global_position
	add_point(target.global_position + Vector2(randfn(0.0, randomness_range), randfn(0.0, randomness_range)))
	if get_point_count() > max_length:
		remove_point(0)
		if get_point_count() > max_length:
			delete_count -= 1
			if delete_count <= 0:
				delete_count = deletion_factor
				remove_point(0)
