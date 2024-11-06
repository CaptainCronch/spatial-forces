extends RigidBody2D
class_name Weight

@export var target: Ship
@export var imbued_particles: CPUParticles2D
@export var line: Line2D
@export var pointer: Polygon2D
@export var distance_threshold := 32.0
@export var back_force := 48.0
@export var max_factor := 4.0

var attack: Attack = null
var force_added: float
var distance_factor := 0.0


func _process(_delta: float) -> void:
	line.points[0] = global_position
	line.points[1] = (target.global_position + global_position) / 2
	line.points[2] = target.global_position
	line.width = distance_factor

	pointer.global_rotation = target.global_rotation


func _physics_process(_delta: float) -> void:
	#if not attack == null and linear_velocity.length() < force_added / attack_loss_threshold:
		#await get_tree().create_timer(0.1)
		#attack = null
		#imbued_particles.emitting = false

	#if global_position.distance_to(target.global_position) > distance_threshold:
	distance_factor = clampf(inverse_lerp(distance_threshold/2, distance_threshold, global_position.distance_to(target.global_position)), 0, max_factor)
	if distance_factor <= 1.0 and linear_velocity.length() < back_force * 2:
		attack = null
		imbued_particles.emitting = false
	apply_central_force(global_position.direction_to(target.global_position) * back_force * distance_factor)


func add_attack(atk: Attack, added: float) -> void:
	attack = atk.duplicate()
	force_added = added
	imbued_particles.emitting = true


func _on_body_entered(body: Node) -> void:
	if body is Ship and not attack == null and not body == target:
		attack.attack_position = global_position
		attack.attack_direction = linear_velocity.normalized()
		body.hitbox.damage(attack)
		attack = null
		imbued_particles.emitting = false
