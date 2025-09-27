extends Ship

const SPARKS = preload("uid://bvv4udo8hfkun")
const BOUNCE_DUST = preload("uid://bjsrwbu6ty1bh")

@export var clip_component: ClipComponent
@export var raycast: RayCast2D
@export var shapecast: ShapeCast2D
@export var laser_line: Line2D
@export var attack: Attack
@export var dodge_arrow: Polygon2D
@export var dodge_bar: Meter
@export var trail_left: Trail
@export var trail_right: Trail
@export var spark_settings: ParticleSettings
@export var bounce_settings: ParticleSettings
@export var laser_range := 1000.0
@export var laser_rotation_boost := 0.1
@export var laser_tick_time := 0.1
@export var laser_speed := 500.0
@export var laser_return_speed := 1000.0
@export var ammo_consumption := 20.0
@export var hit_reload_amount := 10.0
@export var laser_buffer_distance := 0.0
@export var dodge_force := 150.0
@export var tween_time := 0.5
@export var dodge_time := 1.5
@export var trail_length_range := [0.0, 20.0]
@export var trail_width_range := [3.0, 5.0]
@export var trail_time := 10.0

var laser_tick_timer := laser_tick_time
var shooting := false
var dodge_angle := 0.0
var dodge_tween: Tween
var dodge_timer := dodge_time
var trail_tween: Tween


func _ready() -> void:
	super()
	#dodge_bar.max_value = dodge_time
	#dodge_bar.value = dodge_timer
	if player_id == PlayerIDs.PLAYER_2:
		shapecast.set_collision_mask_value(3, false)
		shapecast.set_collision_mask_value(2, true)
	if demo:
		dodge_arrow.hide()


func _process(delta) -> void:
	super(delta)
	if dodge_timer < dodge_time:
		dodge_timer += delta
		dodge_bar.value = dodge_timer
	else:
		dodge_arrow.polygon[2].x = 20
	
	trail_right.width = trail_width_range[0]
	trail_left.width = trail_width_range[0]
	if rotation_dir < 0.0:
		trail_right.width = trail_width_range[1]
	elif rotation_dir > 0.0:
		trail_left.width = trail_width_range[1]
		
	if move_dir.x <= 0.0:
		trail_left.max_length = trail_length_range[0]
		trail_right.max_length = trail_length_range[0]
	else:
		trail_left.max_length = trail_length_range[1]
		trail_right.max_length = trail_length_range[1]
	
	#var thrust_length: Vector2 = Vector2(thrust_length_range[0], 0)
	#if move_dir.x > 0.0:
		#thrust_length = Vector2(thrust_length_range[1], 0)
	#var thrust_position := Global.decay_vec2_towards(thrust_left.get_point_position(1), thrust_length, thrust_time, delta)
	#thrust_left.set_point_position(1, thrust_position)
	#thrust_right.set_point_position(1, thrust_position)


func _physics_process(delta: float) -> void:
	super(delta)
	set_laser(delta)
	
	if laser_tick_timer < laser_tick_time:
		laser_tick_timer += delta
		return
	if shapecast.enabled:
		for i in shapecast.collision_result.size():
			var hit_node := instance_from_id(shapecast.collision_result[i].collider_id)
			#print(hit_node)
			if hit_node is HitboxComponent:
				attack.attack_position = shapecast.collision_result[i].point.project(raycast.target_position.rotated(rotation))
				attack.attack_direction = Vector2.RIGHT.rotated(rotation)
				attack.attack_damage *= damage_boost
				attack.knockback_force *= damage_boost
				hit_node.damage(attack)
				attack.attack_damage /= damage_boost
				attack.knockback_force /= damage_boost
				laser_tick_timer = 0.0
				clip_component.clip = minf(clip_component.clip + hit_reload_amount, clip_component.max_clip)
			elif hit_node is Debris:
				hit_node.apply_central_impulse(Vector2.RIGHT.rotated(rotation) * attack.knockback_force)


func set_laser(delta: float) -> void:
	if shooting:
		var laser_distance := laser_range
		if raycast.is_colliding():
			laser_distance = global_position.distance_to(raycast.get_collision_point()) + laser_buffer_distance
		if laser_distance > shapecast.target_position.x:
			laser_distance = minf(laser_distance, shapecast.target_position.x + (laser_speed * delta))
		
		bounce_settings.spawn_position = global_position + shapecast.target_position.rotated(rotation)
		particulate(BOUNCE_DUST, bounce_settings)
		laser_line.set_point_position(1, Vector2(laser_distance, 0))
		shapecast.target_position.x = laser_distance
	else:
		var laser_distance := maxf(0.0, shapecast.target_position.x - (laser_return_speed * delta))
		laser_line.set_point_position(1, Vector2(laser_distance, 0))
		shapecast.target_position.x = laser_distance


#func primary() -> void:
	#if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: return
	#rotational_boost = laser_rotation_boost
	#shapecast.enabled = true


func primary_hold() -> void:
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles:
		clip_component.hold(0)
		primary_release()
		return
	clip_component.hold(ammo_consumption * get_process_delta_time())
	rotational_boost = laser_rotation_boost
	shapecast.enabled = true
	shapecast.force_shapecast_update()
	shooting = true
	
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: primary_release()


func primary_release() -> void:
	shapecast.enabled = false
	shapecast.force_shapecast_update()
	rotational_boost = 1.0
	shooting = false


func secondary_hold() -> void:
	if dodge_timer < dodge_time: return
	dodge_timer = 0.0
	dodge_arrow.polygon[2].x = 16
	#apply_central_impulse(Vector2.RIGHT.rotated(rotation + dodge_angle) * dodge_force)
	linear_velocity = Vector2.RIGHT.rotated(rotation + dodge_angle) * dodge_force
	dodge_angle += TAU/4
	
	if is_instance_valid(dodge_tween): dodge_tween.kill()
	dodge_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	dodge_tween.tween_property(dodge_arrow, "rotation", dodge_angle, tween_time)
	#dodge_tween.tween_callback(func(): if dodge_angle > TAU: dodge_angle -= TAU) #just to make sure the angle doesnt get infinitely big :)
