extends Area2D
class_name SteeringComponent

const DEFAULT_DIR := Vector2.RIGHT

@export var target: Ship
@export var raycast: RayCast2D
@export var ray_extent := 128

var disabled := false
var casts := 8
var rays: Array[RayCast2D] = []
var ray_directions: Array[Vector2] = []
var interest_directions: Array[Vector2] = []
var interest: Array[float] = []
var danger: Array[float] = []
var chosen_dir := Vector2()


func _ready() -> void:
	for i in casts - 1:
		var new := raycast.duplicate()
		add_child(new)
		rays.append(new)
	rays.append(raycast)

	for i in rays.size():
		var angle := (i * 2 * (PI) / rays.size())# - (PI/2)
		rays[i].target_position = Vector2.RIGHT.rotated(angle) * ray_extent
		ray_directions.append(Vector2.RIGHT.rotated(angle))

	#var last := raycast.duplicate()
	#add_child(last)
	#rays.append(last)
	#ray_directions.append(Vector2.RIGHT.rotated(PI/2))
	#last.target_position = Vector2.RIGHT.rotated(PI/2) * ray_extent

	interest_directions.resize(casts)
	interest.resize(casts)
	danger.resize(casts)

	#target.acceleration_boost = 0.5
	target.rotation_speed *= 0.5


func _physics_process(_delta: float) -> void:
	if disabled: return
	target.rotation_dir = 0
	target.move_dir = Vector2(target.acceleration * target.acceleration_boost, 0)

	check_interest()
	check_danger()

	for i in casts:
		interest[i] = maxf(0, interest[i] - danger[i])

	chosen_dir = Vector2.ZERO
	for i in casts:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir /= casts
	chosen_dir = chosen_dir.normalized()
	var result := chosen_dir.cross(Vector2.RIGHT)

	#target.rotation_dir = result * -2
	if result > 0:
		target.rotation_dir = -1
	elif result < 0:
		target.rotation_dir = 1
	else:
		target.rotation_dir = 0


func check_interest() -> void:
	var boids: Array[Ship] = []

	for area in get_overlapping_areas():
		if area is HitboxComponent and not area == target.hitbox:
			boids.append(area.get_parent())

	if boids.size() <= 0:
		for i in casts:
			interest[i] = absf(Vector2.RIGHT.dot(ray_directions[i]))
		return

	#var cohesion := Vector2()
	#for boid in boids:
		#cohesion += boid.global_position
	#cohesion /= boids.size()
	#cohesion -= global_position

	var alignment := Vector2()
	for boid in boids:
		alignment += Vector2.RIGHT.rotated(boid.rotation)
	alignment /= boids.size()

	#var separation := Vector2()
	#for boid in boids:
		#separation += boid.global_position - global_position
	#separation /= boids.size()

	var total := alignment.normalized()#((cohesion + alignment + separation) / 3).normalized()

	for i in casts:
		interest[i] = absf(total.dot(ray_directions[i]))


func check_danger() -> void:
	for i in casts:
		if rays[i].is_colliding():
			danger[i] = global_position.distance_to(rays[i].get_collision_point()) / ray_extent
		else:
			danger[i] = 0.0
