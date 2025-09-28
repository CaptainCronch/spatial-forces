extends RigidBody2D
class_name Ship

const DAMAGE_UP = preload("uid://cv2lsek22eg5s")
const DEATH_FIZZLE = preload("uid://7ff2833gs4p3")
#const BOUNCE_DUST = preload("uid://bjsrwbu6ty1bh")

#const DEATH_EXPLOSION = preload("uid://bw0lp7lixpqbg")
const SPEED_LIMIT := 300.0

enum PlayerIDs {PLAYER_1, PLAYER_2}
var player_id: PlayerIDs

@export var hitbox : HitboxComponent
@export var input: InputComponent
@export var steering: SteeringComponent
@export var death_fizzle_settings := preload("uid://c0gsf88jb66kr")
#@export var bounce_settings := preload("uid://bp570hmofpsls")
#@export var death_explosion_settings := preload("uid://d3u1j0udrop20")

@export var rotation_speed := 360.0
@export var acceleration := 128.0
@export var back_acceleration := 16.0
@export var top_speed := 128.0

var top_speed_boost := 1.0
var acceleration_boost := 1.0
var rotational_boost := 1.0
var damage_boost := 1.0
var rotation_dir := 0
var move_dir := Vector2()
var last_damage: Attack
var block_tiles: Array[RID] = []
var demo := false
var dead := false
#var timer = 0

#@onready var bullet_spawn


func _ready() -> void:
	call_deferred("initialize")
	hitbox.body_shape_entered.connect(_on_hitbox_body_shape_entered)
	hitbox.body_shape_exited.connect(_on_hitbox_body_shape_exited)
	#body_entered.connect(func(): particulate(BOUNCE_DUST, bounce_settings))
	#contact_monitor = true
	#max_contacts_reported = 5
	death_fizzle_settings = death_fizzle_settings.duplicate()
	death_fizzle_settings.target = self.get_path()


func initialize() -> void:
	if not demo: get_tree().current_scene.camera.add_target(self)

	if player_id == PlayerIDs.PLAYER_2:
		remove_from_group("Player1")
		add_to_group("Player2")
		if is_instance_valid(input): input.inputs = input.PLAYER2_INPUTS
		hitbox.set_collision_layer_value(2, false)
		hitbox.set_collision_layer_value(3, true)
		hitbox.set_collision_mask_value(2, true)
		hitbox.set_collision_mask_value(3, false)
		hitbox.remove_from_group("Player1")
		hitbox.add_to_group("Player2")


func _physics_process(_delta) -> void:
	apply_torque(rotation_dir * rotation_speed * rotational_boost) # spin
	apply_central_force(move_dir.rotated(rotation)) # move

	var back_factor := minf(pow(2, # exponential curve so we get pushed back more the closer we are to the top speed
		(linear_velocity.length() - (top_speed * top_speed_boost))),
		acceleration * acceleration_boost # make sure we dont get slingshotted back by limiting the back force
		) * absf(signf(move_dir.length())) # only apply a force if we're actually trying to move

	apply_central_force(linear_velocity.normalized() * -1 * back_factor) # drag


func _process(_delta) -> void:
	pass
	#$Label.text = str(roundf(linear_velocity.length())) # debug


func _integrate_forces(state) -> void: # if ship_going_faster_than_speed_limit: dont()
	if state.linear_velocity.length() > SPEED_LIMIT:
		state.linear_velocity = state.linear_velocity.normalized() * SPEED_LIMIT


func primary() -> void: pass
func primary_release() -> void: pass
func primary_hold() -> void: pass

func secondary() -> void: pass
func secondary_release() -> void: pass
func secondary_hold() -> void: pass


func die() -> void:
	if demo: return
	dead = true
	if is_instance_valid(input): input.disabled = true
	if is_instance_valid(steering): steering.disabled = true
	
	#print(death_fizzle_settings.target)
	particulate(DEATH_FIZZLE, death_fizzle_settings)
	await get_tree().create_timer(1.0).timeout
	var stable_force := minf(500, last_damage.knockback_force * 100)
	apply_central_impulse(last_damage.attack_direction * stable_force)
	await get_tree().create_timer(1.0).timeout
	get_tree().current_scene.camera.remove_target(self)
	get_tree().current_scene.camera.zoom_scale = 2.0
	await get_tree().create_timer(2.0).timeout
	get_tree().current_scene.camera.zoom_scale = 1.0
	await get_tree().create_timer(2.0).timeout
	get_tree().current_scene.end_round()
	#queue_free()


func set_projectile_player(projectile: CollisionObject2D) -> void:
	if player_id == PlayerIDs.PLAYER_2:
		#projectile.set_collision_layer_value(2, false)
		#projectile.set_collision_layer_value(3, true)
		projectile.hurtbox.set_collision_layer_value(2, false)
		projectile.hurtbox.set_collision_layer_value(3, true)
		projectile.hurtbox.set_collision_mask_value(2, true)
		projectile.hurtbox.set_collision_mask_value(3, false)


func particulate(particle_scene: PackedScene, particle_settings: ParticleSettings) -> void:
	for i in particle_settings.loops:
		var particles := (particle_scene.instantiate() as CPUParticles2D)
		particles.rotation = rotation + (particle_settings.angle_offset * i) + randf_range(-particle_settings.angle_random, particle_settings.angle_random)
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


func powerup(amount: float, duration: float) -> void:
	if dead: return
	damage_boost += amount
	var particles := DAMAGE_UP.instantiate()
	#particles.target = self
	add_child(particles)
	await get_tree().create_timer(duration).timeout
	damage_boost -= amount
	particles.queue_free()


func _on_hitbox_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		block_tiles.append(body_rid)


func _on_hitbox_body_shape_exited(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		block_tiles.erase(body_rid)
