extends Ship

const BULLET := preload("uid://bsye47gtl6ebh")
const BIG_BULLET := preload("uid://cqg06swewr3u3")

@export var thrust_left: CPUParticles2D
@export var thrust_right: CPUParticles2D
@export var barrel_left: Marker2D
@export var barrel_right: Marker2D
@export var clip_component: ClipComponent
@export var clip_component_special: ClipComponent
#@export var special_bar: Meter
@export var boost_range := [1.0, 3.0]
#@export var angular_range := [-5.0, 5.0]
#@export var thrust_angle_range := [-1.0, 1.0]
#@export var thrust_force_range := [10.0, 30.0]
@export var thrust_speed_range := [1.0, 5.0]
@export var acceleration_range := [acceleration * boost_range[0], acceleration * boost_range[1]]
#@export var secondary_time := 1.0
#
#var secondary_timer := secondary_time


func _ready() -> void:
	super()
	
	#special_bar.max_value = secondary_time
	#special_bar.value = secondary_timer


func _process(delta) -> void:
	super(delta)
	
	#thrust_left.direction.y = remap(angular_velocity, angular_range[0], angular_range[1], thrust_angle_range[0], thrust_angle_range[1])
	#thrust_left.initial_velocity_min = remap(absf(angular_velocity), 0.0, angular_range[1], thrust_force_range[0], thrust_force_range[1])
	#thrust_left.initial_velocity_max = thrust_left.initial_velocity_min
	var speed_factor := remap(acceleration * acceleration_boost, acceleration_range[0], acceleration_range[1], thrust_speed_range[0], thrust_speed_range[1])
	thrust_left.speed_scale = speed_factor
	thrust_left.emitting = move_dir.x != 0.0
	thrust_right.speed_scale = speed_factor
	thrust_right.emitting = move_dir.x != 0.0


func _physics_process(delta) -> void:
	super(delta)
	
	if move_dir.x == 0.0:
		top_speed_boost = 1.0
		acceleration_boost = 1.0
	else: #the closer the difference between the angles is to 90 the higher the boost is
		var strafe := absf(Vector2.RIGHT.rotated(rotation).dot(linear_velocity.normalized()))
		var boost := clampf(remap(strafe, 1.0, 0.0, boost_range[0], boost_range[1]), boost_range[0], boost_range[1])
		top_speed_boost = boost
		acceleration_boost = boost


func primary() -> void:
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: return
	clip_component.use(1)
	
	var bullet_instance : Bullet
	bullet_instance = BULLET.instantiate()
	bullet_instance.position = barrel_left.get_global_position()
	bullet_instance.sprite.global_position = barrel_left.get_global_position()
	bullet_instance.rotation = rotation
	bullet_instance.sprite.global_rotation = barrel_left.get_global_rotation()
	bullet_instance.origin = self
	get_tree().current_scene.call_deferred("add_child", bullet_instance)

	set_projectile_player(bullet_instance)


func secondary() -> void:
	if clip_component_special.clip <= 0 or not clip_component_special.can_fire or block_tiles: return
	clip_component_special.use(1)

	
	var bullet_instance : Bullet
	bullet_instance = BIG_BULLET.instantiate()
	bullet_instance.position = barrel_right.get_global_position()
	bullet_instance.sprite.global_position = barrel_right.get_global_position()
	bullet_instance.rotation = rotation
	bullet_instance.sprite.global_rotation = barrel_right.get_global_rotation()
	bullet_instance.origin = self
	get_tree().current_scene.call_deferred("add_child", bullet_instance)

	set_projectile_player(bullet_instance)
