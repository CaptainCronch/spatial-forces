extends HurtAreaComponent
class_name Lance

const SPARKS = preload("uid://bvv4udo8hfkun")

@export var polygon: Polygon2D
@export var spark_settings: ParticleSettings
@export var reflection_strength := 400.0

var ship: Ship
var reflect_mode := false


func _ready() -> void:
	super()
	hit.connect(func(hitbox):
		spark_settings.spawn_position = hitbox.global_position
		particulate(SPARKS, spark_settings)
	)


func _physics_process(delta):
	if flash_speed > 0.0: # if has flash speed and time out then check collisions and restart timer
		flash_timer += delta
		if flash_timer >= flash_speed:
			flash_timer = 0.0
		else: return
	if not monitoring or not enabled: return
	for area in get_overlapping_areas():
		if area is HitboxComponent:
			if area.is_in_group("Player"):
				attack.attack_position = global_position
				attack.attack_direction = Vector2.RIGHT.rotated(global_rotation)
				hit.emit(area)
				attack.attack_damage *= ship.damage_boost
				attack.knockback_force *= ship.damage_boost
				area.damage(attack)
				attack.attack_damage /= ship.damage_boost
				attack.knockback_force /= ship.damage_boost
				break


func particulate(particle_scene: PackedScene, particle_settings: ParticleSettings) -> void:
	for i in particle_settings.loops:
		var particles := (particle_scene.instantiate() as CPUParticles2D)
		particles.rotation = global_rotation + (particle_settings.angle_offset * i) + randf_range(-particle_settings.angle_random, particle_settings.angle_random)
		particles.scale_amount_min = particle_settings.scale_range / 2
		particles.scale_amount_max = particle_settings.scale_range
		particles.initial_velocity_min += get_parent().get_parent().linear_velocity.length() * particle_settings.velocity_inherit * (1 - particle_settings.random_range)
		particles.initial_velocity_max += get_parent().get_parent().linear_velocity.length() * particle_settings.velocity_inherit * (1 + particle_settings.random_range)
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


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and reflect_mode:
		body.linear_velocity = Vector2.RIGHT.rotated(global_rotation) * reflection_strength
		flash_timer = 0.0
