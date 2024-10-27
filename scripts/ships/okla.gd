extends Ship

const BULLET := preload("res://scenes/projectiles/okla_bullet.tscn")

@export var slugger_bar: Meter
@export var engine: CPUParticles2D
@export var weapon_component: WeaponComponent

@export var bullet_amount := 7
@export var bullet_angle_variance := 5.0 * PI/180
@export var fire_knockback := 96
#@export var bullet_position_variance := 5.0

var emit_scale := 1.0


func _process(_delta: float) -> void:
	super(_delta)
	set_engine()


func set_engine():
	engine.speed_scale = 0
	if move_dir.x > 0:
		engine.speed_scale += emit_scale
	engine.speed_scale *= top_speed_boost


func fire():
	var mult := 1.0
	if weapon_component.clip == 1: mult = 2.0 # charm passive

	if weapon_component.clip <= 0 or not weapon_component.can_fire: return
	weapon_component.use(1, mult)

	var bullet_instance : RigidBody2D
	for i in bullet_amount * mult:
		bullet_instance = BULLET.instantiate()
		#var pos_var := absf(randfn(0, bullet_position_variance * mult))
		bullet_instance.position = weapon_component.get_global_position()
		bullet_instance.rotation = rotation + randfn(0, bullet_angle_variance * mult)
		bullet_instance.apply_central_impulse(Vector2(bullet_speed, 0).rotated(bullet_instance.rotation))
		get_tree().current_scene.call_deferred("add_child", bullet_instance)
		bullet_instance.modulate = Types.COLOR_VALUES[player_color]

		if player_id == PlayerIDs.PLAYER_2:
			bullet_instance.set_collision_layer_value(2, false)
			bullet_instance.set_collision_layer_value(3, true)
			bullet_instance.hurtbox.set_collision_layer_value(2, false)
			bullet_instance.hurtbox.set_collision_layer_value(3, true)
			bullet_instance.hurtbox.set_collision_mask_value(2, true)
			bullet_instance.hurtbox.set_collision_mask_value(3, false)

	apply_central_impulse(Vector2.LEFT.rotated(rotation) * fire_knockback * mult)
