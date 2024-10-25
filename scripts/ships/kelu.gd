extends "res://scripts/player_controller.gd"

const BULLET := preload("res://scenes/bullet.tscn")

@export var left_engine : CPUParticles2D
@export var right_engine : CPUParticles2D
@export var weapon_component : WeaponComponent

var emit_scale := 1
var bullet_instance : Node2D

@export var fire_time := 0.1


func _ready() -> void:
	left_engine.modulate = COLOR_VALUES[player_color]
	right_engine.modulate = COLOR_VALUES[player_color]
	super()


func _process(_delta: float) -> void:
	super(_delta)
	set_engines()


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

		if player_id == 1:
			bullet_instance.set_collision_layer_value(1, false)
			bullet_instance.set_collision_layer_value(2, true)
			bullet_instance.hurtbox.set_collision_layer_value(1, false)
			bullet_instance.hurtbox.set_collision_layer_value(2, true)
			bullet_instance.hurtbox.set_collision_mask_value(1, true)
			bullet_instance.hurtbox.set_collision_mask_value(2, false)
		await get_tree().create_timer(fire_time).timeout
