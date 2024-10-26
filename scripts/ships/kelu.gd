extends "res://scripts/player_controller.gd"

const BULLET := preload("res://scenes/bullet.tscn")

@export var turbo_bar: Meter
@export var left_engine: CPUParticles2D
@export var right_engine: CPUParticles2D
@export var weapon_component: WeaponComponent

var turbo_timer := 0.0
var emit_scale := 1.0
var bullet_instance: Node2D

@export var fire_time := 0.1
@export var turbo_time := 1.0


func _ready() -> void:
	super()
	turbo_bar.max_value = turbo_time
	turbo_bar.value = turbo_timer


func _process(_delta: float) -> void:
	super(_delta)
	set_engines()
	turbo(_delta)


func turbo(_delta: float):
	if Input.is_action_pressed(inputs[PlayerInputs.SECONDARY]) and turbo_timer < turbo_time:
		top_speed_boost = 2.0
		turbo_timer += _delta
		turbo_bar.value = turbo_timer
	else:
		top_speed_boost = 1.0

	if is_zero_approx(move_dir.length_squared()) and turbo_timer > 0.0:
		turbo_timer -= _delta
		turbo_bar.value = turbo_timer


func set_engines():
	left_engine.speed_scale = 0
	right_engine.speed_scale = 0
	if move_dir.x > 0:
		left_engine.speed_scale += emit_scale
		right_engine.speed_scale += emit_scale
	if rotation_dir > 0:
		left_engine.speed_scale += emit_scale
	if rotation_dir < 0:
		right_engine.speed_scale += emit_scale
	left_engine.speed_scale *= top_speed_boost
	right_engine.speed_scale *= top_speed_boost


func fire():
	if weapon_component.clip <= 0 or not weapon_component.can_fire: return
	weapon_component.use(1)

	for i in 3:
		bullet_instance = BULLET.instantiate()
		bullet_instance.position = weapon_component.get_global_position()
		bullet_instance.rotation = rotation
		bullet_instance.apply_impulse(Vector2(bullet_speed, 0).rotated(rotation), Vector2())
		get_tree().current_scene.call_deferred("add_child", bullet_instance)
		bullet_instance.modulate = COLOR_VALUES[player_color]

		if player_id == PlayerIDs.PLAYER_2:
			bullet_instance.set_collision_layer_value(2, false)
			bullet_instance.set_collision_layer_value(3, true)
			bullet_instance.hurtbox.set_collision_layer_value(2, false)
			bullet_instance.hurtbox.set_collision_layer_value(3, true)
			bullet_instance.hurtbox.set_collision_mask_value(2, true)
			bullet_instance.hurtbox.set_collision_mask_value(3, false)
		await get_tree().create_timer(fire_time).timeout


func _on_rushdown_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area.is_in_group("Player1" if player_id == PlayerIDs.PLAYER_2 else "Player2"):
		acceleration_boost = 3.0


func _on_rushdown_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player") and area.is_in_group("Player1" if player_id == PlayerIDs.PLAYER_2 else "Player2"):
		acceleration_boost = 1.0
