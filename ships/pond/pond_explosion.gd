extends Area2D

@export var collider: CollisionShape2D
@export var particles: CPUParticles2D
@export var attack: Attack

@export var previous_hit_bonus := 2.0
@export var radius := 60.0

var previous_hits: Array[Ship] = []

func _ready() -> void:
	(collider.shape as CircleShape2D).radius = radius
	particles.emission_sphere_radius = radius*0.75
	particles.emitting = true
	
	await get_tree().create_timer(0.1).timeout
	#monitoring = false #explosions should last as little time as possible!
	$CollisionShape2D.disabled = true
	
	#for area in get_overlapping_areas():
		#if area.is_in_group("Player") and area is HitboxComponent:
			#attack.attack_position = global_position
			#attack.attack_direction = global_position.direction_to(area.global_position)
			#if area.target in previous_hits:
				#attack.attack_damage *= previous_hit_bonus
				#attack.knockback_force *= previous_hit_bonus
			#area.damage(attack)


func _on_cpu_particles_2d_finished() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area is HitboxComponent:
			attack.attack_position = global_position
			attack.attack_direction = global_position.direction_to(area.global_position)
			if area.target in previous_hits:
				attack.attack_damage *= previous_hit_bonus
				attack.knockback_force *= previous_hit_bonus
			area.damage(attack)


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if ((is_in_group("Player1") and body.is_in_group("Player2")) #dont impulse enemy player
		or (is_in_group("Player2") and body.is_in_group("Player1"))): return
		body.apply_central_impulse(global_position.direction_to(body.global_position) * attack.knockback_force)
