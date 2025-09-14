extends Ship

const PUNCH_PARTICLES = preload("uid://dafrbpekm0rg8")
const WEIGHT = preload("uid://cwtxj55x5boyx")

@export var clip_component: ClipComponent
@export var punch_area: Area2D
@export var stasis_bar: TextureProgressBar
@export var push_attack: Attack
@export var debris_attack: Attack
@export var weight_attack: Attack
@export var punch_force := 256.0
@export var punch_weight_force := 300.0
@export var punch_stasis_factor := 1.3
@export var punch_air_force := 32.0
#@export var punch_wall_boost := -1.2
@export var stasis_damp := 10.0
@export var stasis_counter := 3

var stasis_count := 3
var stasing := false
var weight: Weight


func _ready() -> void:
	super()
	stasis_bar.max_value = stasis_counter
	stasis_bar.value = stasis_count
	if player_id == PlayerIDs.PLAYER_2:
		punch_area.set_collision_mask_value(2, true)
		punch_area.set_collision_mask_value(3, false)

	if not demo:
		var new_weight := WEIGHT.instantiate()
		new_weight.target = self
		var rand := Vector2(randf_range(-16, 16), randf_range(-16, 16))
		new_weight.global_position = global_position + rand
		get_parent().add_child(new_weight)
		weight = new_weight


func primary():
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: return # not checking for block tiles because this ship does not fire projectiles
	clip_component.use(1)

	for area in punch_area.get_overlapping_areas():
		if area is HitboxComponent:
			push_attack.attack_direction = Vector2.RIGHT.rotated(rotation)
			push_attack.attack_position = global_position
			area.damage(push_attack)

	for body in punch_area.get_overlapping_bodies():
		if body is RigidBody2D:
			#body.apply_central_impulse(Vector2.RIGHT.rotated(rotation) * punch_force)
			body.linear_velocity = Vector2.RIGHT.rotated(rotation) * punch_force
			if body is Debris:
				body.add_attack(debris_attack, punch_force, self)
				body.linear_velocity *= 1/body.size_multiplier
			if body is Weight:
				body.add_attack(weight_attack, punch_weight_force)
				body.linear_velocity = Vector2.RIGHT.rotated(rotation) * punch_weight_force

	apply_central_impulse(Vector2.RIGHT.rotated(rotation) * punch_air_force)
	#if hit_wall and not hit_something: # dont flip velocity if player meant to hit something else
		#linear_velocity = linear_velocity * punch_wall_boost

	var new_punch := PUNCH_PARTICLES.instantiate()
	new_punch.rotation = rotation
	new_punch.global_position = punch_area.global_position
	new_punch.target = self
	add_child(new_punch)
	new_punch.emitting = true

	stasis_count -= 1 if stasis_count > 0 else 0
	stasis_bar.value = stasis_count


func secondary():
	if stasis_count > 0: return
	stasing = true
	stasis_count = stasis_counter
	stasis_bar.value = stasis_count
	weight.linear_damp = stasis_damp
	weight.pointer.show()


func secondary_release():
	if not stasing: return
	stasing = false
	weight.linear_damp = ProjectSettings.get_setting("physics/2d/default_linear_damp")
	weight.linear_velocity = Vector2.RIGHT.rotated(rotation) * punch_weight_force * punch_stasis_factor
	weight.add_attack(debris_attack, punch_weight_force)
	weight.pointer.hide()
