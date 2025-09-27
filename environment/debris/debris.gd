extends RigidBody2D
class_name Debris

@export var spawn_speed := 10.0
@export var spawn_rotation := PI
@export var attack_loss_threshold := 6.0
@export var size_multiplier := 1.0
@export var imbued_damage := 30
@export var imbued_particles: CPUParticles2D

var attack: Attack = null
var force_added := 0.0
var hitter: Node2D = null


func _ready() -> void:
	linear_velocity += Vector2(randfn(0, spawn_speed), randfn(0, spawn_speed))
	angular_velocity += randfn(0, spawn_rotation)
	@warning_ignore("narrowing_conversion")
	imbued_particles.amount *= size_multiplier


func _physics_process(_delta: float) -> void:
	if not attack == null and linear_velocity.length() < force_added / attack_loss_threshold:
		#await get_tree().create_timer(0.1)
		attack = null
		hitter = null
		imbued_particles.emitting = false
		#modulate = Color.WHITE


func add_attack(atk: Attack, added: float, origin: Node2D) -> void:
	attack = atk.duplicate()
	attack.attack_damage = imbued_damage
	force_added = added * size_multiplier
	#modulate = Color.RED
	hitter = origin
	imbued_particles.emitting = true
	#await get_tree().create_timer(0.1)



func _on_body_entered(body: Node) -> void:
	if body is Ship and not attack == null and not body == hitter:
		attack.attack_position = global_position
		attack.attack_direction = linear_velocity.normalized()
		attack.attack_damage *= hitter.damage_boost
		attack.knockback_force *= hitter.damage_boost
		body.hitbox.damage(attack)
		attack.attack_damage /= hitter.damage_boost
		attack.knockback_force /= hitter.damage_boost
		attack = null
		hitter = null
		imbued_particles.emitting = false
		#modulate = Color.WHITE
