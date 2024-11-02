extends Ship

const BULLET := preload("res://scenes/projectiles/kelu_bullet.tscn")

@export var turbo_bar: Meter
@export var left_engine: CPUParticles2D
@export var right_engine: CPUParticles2D
@export var weapon_component: WeaponComponent
@export var delimiter_component: DelimiterComponent

var turbo_timer := 0.0
var emit_scale := 1.0

@export var fire_time := 0.1
@export var turbo_time := 1.0


func _ready() -> void:
	super()
	turbo_bar.max_value = turbo_time
	turbo_bar.value = turbo_timer
	delimiter_component.label.text = "P" + str(player_id + 1)
	if modulate == Color.WHITE:
		emit_scale = 0.1
		left_engine.lifetime = 0.2
		right_engine.lifetime = 0.2
		left_engine.amount = 10
		right_engine.amount = 10


func _process(_delta: float) -> void:
	super(_delta)
	turbo(_delta)
	set_engines()


func secondary_hold():
	if turbo_timer < turbo_time:
		top_speed_boost = 2.0
		turbo_timer += get_process_delta_time()
		turbo_bar.value = turbo_timer


func secondary_release():
	top_speed_boost = 1.0


func turbo(_delta: float):
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


func primary():
	if weapon_component.clip <= 0 or not weapon_component.can_fire or	 block_tiles: return
	weapon_component.use(1)

	var bullet_instance : RigidBody2D
	for i in 3:
		bullet_instance = BULLET.instantiate()
		bullet_instance.position = weapon_component.get_global_position()
		bullet_instance.sprite.global_position = weapon_component.get_global_position()
		bullet_instance.rotation = rotation
		#bullet_instance.apply_central_impulse(Vector2(bullet_speed, 0).rotated(rotation))
		get_tree().current_scene.call_deferred("add_child", bullet_instance)
		bullet_instance.modulate = Types.COLOR_VALUES[player_color]

		set_projectile_player(bullet_instance)
		await get_tree().create_timer(fire_time).timeout


func _on_rushdown_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area.is_in_group("Player1" if player_id == PlayerIDs.PLAYER_2 else "Player2"):
		acceleration_boost = 3.0


func _on_rushdown_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player") and area.is_in_group("Player1" if player_id == PlayerIDs.PLAYER_2 else "Player2"):
		acceleration_boost = 1.0
