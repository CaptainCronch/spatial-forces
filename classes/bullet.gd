extends RigidBody2D
class_name Bullet

const SPARKS := preload("uid://bvv4udo8hfkun")
const DUST = preload("uid://dd0fhwk16qj7i")
const BOUNCE_DUST = preload("uid://bjsrwbu6ty1bh")


signal hit(pos: Vector2)

@export var attack: Attack
@export var hurtbox: Area2D
@export var sprite: Node2D
@export var death_timer: Timer
@export var death_time := 1.5
@export var speed := 400.0
@export var lifetime_randomness := 0.2
@export var spin_speed := 0.0
@export var poof_settings := preload("uid://s65jx7n87yxj")
@export var hit_settings := preload("uid://degp8t1fo02uc")
@export var bounce_settings := preload("uid://bp570hmofpsls")
@export var spawn_settings := preload("uid://da77n10kueu4x")
#@export var particle_settings_poof := [0.5, 3, 0.3, 4.0, 0.0, null] ## velocity inherit factor, amount, random range, scale range, angle offset, target
#@export var particle_settings_hit := [0.2, 5, 0.3, 4.0, 0.0, null] ## velocity inherit factor, amount, random range, scale range, angle offset, target
#@export var particle_settings_bounce := [0.1, 1, 0.3, 2.0, 0.0, null] ## velocity inherit factor, amount, random range, scale range, angle offset, target
#@export var particle_settings_spawn := [0.01, 1, 0.3, 2.0, 0.0, origin] ## velocity inherit factor, amount, random range, scale range, angle offset, target

var disabled := false
var origin: Node2D


func _ready() -> void:
	linear_velocity = Vector2.RIGHT.rotated(rotation) * speed
	sprite.global_position = global_position
	#sprite.rotation = rotation
	death_timer.start(death_time + randf_range(-lifetime_randomness, lifetime_randomness))
	body_entered.connect(_on_body_entered)
	contact_monitor = true
	max_contacts_reported = 1
	spawn_settings.target = origin.get_path()
	#particle_settings_spawn.angle_offset = randf_range(-PI/5, PI/5)
	particulate(BOUNCE_DUST, spawn_settings)
	#particle_settings_spawn.angle_offset = randf_range(-PI/5 + PI, PI/5 + PI)
	#particulate(BOUNCE_DUST, spawn_settings)


func _process(delta: float) -> void:
	sprite.global_position = global_position
	if spin_speed != 0.0:
		sprite.rotation += spin_speed * delta


func _physics_process(_delta: float) -> void:
	if spin_speed == 0.0:
		sprite.rotation = linear_velocity.angle()


func particulate(particle_scene: PackedScene, particle_settings: ParticleSettings) -> void:
	for i in particle_settings.loops:
		var particles := (particle_scene.instantiate() as CPUParticles2D)
		particles.rotation = linear_velocity.angle() + (particle_settings.angle_offset * i) + randfn(0.0, particle_settings.angle_random)
		particles.scale_amount_min = particle_settings.scale_range / 2
		particles.scale_amount_max = particle_settings.scale_range
		particles.initial_velocity_min += linear_velocity.length() * particle_settings.velocity_inherit * (1 - particle_settings.random_range)
		particles.initial_velocity_max += linear_velocity.length() * particle_settings.velocity_inherit * (1 + particle_settings.random_range)
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


func _on_death_timeout() -> void:
	particulate(DUST, poof_settings)
	queue_free()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area is HitboxComponent and not disabled:
		attack.attack_position = global_position
		if linear_velocity.length_squared() != 0.0:
			attack.attack_direction = linear_velocity.normalized()
		else:
			attack.attack_direction = Vector2.RIGHT.rotated(rotation)
		area.damage(attack)
		hit.emit(global_position)
		particulate(SPARKS, hit_settings)
	if not area.is_in_group("Projectile"): queue_free()


func _on_body_entered(_body: Node) -> void:
	#particle_settings_bounce.angle_offset = 0.0
	particulate(BOUNCE_DUST, bounce_settings)
	#particle_settings_bounce.angle_offset = PI
	#particulate(BOUNCE_DUST, particle_settings_bounce)
	#particle_settings_bounce.angle_offset = 0.0
