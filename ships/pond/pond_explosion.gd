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
	
	await get_tree().create_timer(0.1).timeout
	#monitoring = false #explosions should last as little time as possible!
	particles.emitting = true
	$CollisionShape2D.disabled = true
	
	#for area in get_overlapping_areas():
		#if area.is_in_group("Player") and area is HitboxComponent:
			#attack.attack_position = global_position
			#attack.attack_direction = global_position.direction_to(area.global_position)
			#if area.target in previous_hits:
				#attack.attack_damage *= previous_hit_bonus
				#attack.knockback_force *= previous_hit_bonus
			#area.damage(attack)


#func particulate(particle_scene: PackedScene, particle_settings: ParticleSettings) -> void:
	#for i in particle_settings.loops:
		#var particles := (particle_scene.instantiate() as CPUParticles2D)
		#particles.rotation = attack.attack_direction.angle() + (particle_settings.angle_offset * i) + randfn(0.0, particle_settings.angle_random)
		#particles.scale_amount_min = particle_settings.scale_range / 2
		#particles.scale_amount_max = particle_settings.scale_range
		#particles.initial_velocity_min += 100 * particle_settings.velocity_inherit * (1 - particle_settings.random_range)
		#particles.initial_velocity_max += 100 * particle_settings.velocity_inherit * (1 + particle_settings.random_range)
		#particles.amount = particle_settings.amount
		#particles.global_position = global_position
		#if particle_settings.spawn_position:
			#particles.global_position = particle_settings.spawn_position
		#particles.local_coords = particle_settings.local
		#var target := get_node_or_null(particle_settings.target)
		#if is_instance_valid(target):
			#particles.target = target
		#particles.emitting = true
		#get_tree().current_scene.add_child(particles)
		#
		#if is_instance_valid(particle_settings.subparticle):
			#await get_tree().create_timer(particles.lifetime).timeout
			#particulate(particle_settings.subparticle, particle_settings.subparticle_settings)


func _on_cpu_particles_2d_finished() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area is HitboxComponent:
			attack.attack_position = global_position
			attack.attack_direction = global_position.direction_to(area.global_position)
			if area.target in previous_hits:
				attack.attack_damage *= previous_hit_bonus
				attack.knockback_force *= previous_hit_bonus
				@warning_ignore("narrowing_conversion")
				particles.amount *= previous_hit_bonus
				particles.scale_amount_max *= previous_hit_bonus
				particles.emitting = true
			area.damage(attack)


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if ((is_in_group("Player1") and body.is_in_group("Player2")) #dont impulse enemy player
		or (is_in_group("Player2") and body.is_in_group("Player1"))): return
		body.apply_central_impulse(global_position.direction_to(body.global_position) * attack.knockback_force)
