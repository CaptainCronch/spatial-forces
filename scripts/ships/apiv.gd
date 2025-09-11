extends Ship

const PLASMA_BALL = preload("res://scenes/projectiles/plasma_ball.tscn")

@export var clip_comp: ClipComponent
@export var rotate_bar: Meter
@export var bullet_grow_speed := 5.0
@export var ammo_consumption_speed := 5.0
@export var min_ammo_consumption := 2
@export var hold_acceleration_boost := 2.0
@export var rotate_time := 1.0
@export var max_rotates := 3

var bullets: Array[PlasmaBall]
var rotate_timer := 0.0
var rotate_charges := max_rotates


func _ready() -> void:
	super()
	rotate_bar.max_value = max_rotates
	rotate_bar.value = rotate_charges


func _process(delta: float) -> void:
	if rotate_charges < max_rotates:
		rotate_timer += delta
		if rotate_timer >= rotate_time:
			rotate_timer = 0.0
			rotate_charges += 1
			rotate_bar.value = rotate_charges


func primary() -> void:
	if clip_comp.clip <= 0 or not clip_comp.can_fire or block_tiles: return

	var bullet_instance: PlasmaBall = (PLASMA_BALL.instantiate() as PlasmaBall)
	bullet_instance.position = clip_comp.get_global_position()
	bullet_instance.rotation = rotation
	get_tree().current_scene.call_deferred("add_child", bullet_instance)

	set_projectile_player(bullet_instance)
	bullets.push_front(bullet_instance)
	
	acceleration_boost = hold_acceleration_boost

func primary_hold() -> void:
	if is_instance_valid(bullets[0]) and not bullets[0].shot:
		bullets[0].increase_size(bullet_grow_speed * get_process_delta_time())
		bullets[0].position = clip_comp.get_global_position()
		bullets[0].rotation = rotation
		clip_comp.hold(ammo_consumption_speed * get_process_delta_time())
		if clip_comp.clip <= 0 or not clip_comp.can_fire or block_tiles:
			fire()
	else:
		acceleration_boost = 1.0

func primary_release() -> void:
	if is_instance_valid(bullets[0]) and not bullets[0].shot:
		fire()


func fire() -> void:
	acceleration_boost = 1.0
	clip_comp.use(min_ammo_consumption)
	bullets[0].shoot()
	# launch projectile


func secondary() -> void:
	if rotate_charges <= 0: return
	var bullet_exists := false
	for bullet in bullets:
		if is_instance_valid(bullet) and bullet.shot:
			bullet.linear_velocity = bullet.linear_velocity.rotated(-TAU/4)
			bullet_exists = true
	#linear_velocity = linear_velocity.rotated(-TAU/4)
	if bullet_exists:
		rotate_charges -= 1
		rotate_bar.value = rotate_charges
