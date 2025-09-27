extends RigidBody2D

const SPARKS = preload("uid://bvv4udo8hfkun")

signal collected

@export var spark_settings: ParticleSettings
@export var sprite: Sprite2D
@export var power := 200.0
@export var spawn_velocity := 100.0
@export var spawn_angular := 20.0


func _ready() -> void:
	sprite.rotation = randf_range(0, TAU)
	linear_velocity = Vector2(randf_range(spawn_velocity/2, spawn_velocity),0.0).rotated(sprite.rotation)
	angular_velocity = randf_range(-spawn_angular, spawn_angular)


func particulate(particle_scene: PackedScene, particle_settings: ParticleSettings) -> void:
	for i in particle_settings.loops:
		var particles := (particle_scene.instantiate() as CPUParticles2D)
		particles.rotation = rotation + (particle_settings.angle_offset * i) + randfn(0.0, particle_settings.angle_random)
		particles.scale_amount_min = particle_settings.scale_range / 2
		particles.scale_amount_max = particle_settings.scale_range
		particles.initial_velocity_min += 50 * (1 - particle_settings.random_range)
		particles.initial_velocity_max += 50 * (1 + particle_settings.random_range)
		particles.amount = particle_settings.amount
		particles.global_position = global_position
		if particle_settings.spawn_position:
			particles.global_position = particle_settings.spawn_position
		particles.local_coords = particle_settings.local
		var target := get_node_or_null(particle_settings.target)
		if is_instance_valid(target):
			particles.target = target
		particles.emitting = true
		get_tree().current_scene.add_child(particles)
		
		if is_instance_valid(particle_settings.subparticle):
			await get_tree().create_timer(particles.lifetime).timeout
			particulate(particle_settings.subparticle, particle_settings.subparticle_settings)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ship:
		body.apply_central_impulse(Vector2(power, 0.0).rotated(body.rotation))
		collected.emit()
		particulate(SPARKS, spark_settings)
		queue_free()
