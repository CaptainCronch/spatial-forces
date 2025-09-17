extends Ship

@export var lance: HurtAreaComponent
@export var clip_component: ClipComponent
@export var parry_bar: Meter
@export var raycast: RayCast2D
@export var trail: Trail
@export var trail_min_width := 5.0
@export var trail_max_width := 10.0
@export var trail_length := 20
@export var lance_size: PackedVector2Array = [Vector2(0, -4), Vector2(0, 4), Vector2(25, 0)]
@export var lance_shape := Vector2(lance_size[2].x, (lance_size[1].y * 2) - 2) #Vector2(25, 6)
@export var thrust_size: PackedVector2Array = [Vector2(0, -5), Vector2(0, 5), Vector2(50, 0)]
@export var thrust_shape := Vector2(thrust_size[2].x, (thrust_size[1].y * 2) - 2) #Vector2(50, 8)
@export var min_size: PackedVector2Array = [Vector2(0, -3), Vector2(0, 3), Vector2(5, 0)]
@export var min_shape := Vector2(lance_size[2].x, (lance_size[1].y * 2) - 2) #Vector2(25, 6)
@export var max_size: PackedVector2Array = [Vector2(0, -6), Vector2(0, 6), Vector2(75, 0)]
@export var max_shape := Vector2(thrust_size[2].x, (thrust_size[1].y * 2) - 2) #Vector2(50, 8)
@export var parry_size: PackedVector2Array = [Vector2(15, -20), Vector2(15, 20), Vector2(0, 0)]
@export var parry_shape := Vector2(parry_size[0].x, (parry_size[1].y * 2) - 2) #Vector2(15, 38)
@export var thrust_time := 0.6
@export var parry_time := 0.6
@export var tween_time := 0.2
@export var thrust_force := 100.0
@export var lance_damage := 5.0
@export var thrust_damage := 10.0
@export var damage_knockback_ratio := -2.0
@export var max_wall_boost := 3.0

var thrust_tween: Tween
var can_parry := true


func _ready() -> void:
	super()
	lance.polygon.polygon = lance_size
	lance.collider.shape.size = lance_shape
	lance.collider.position.x = lance_shape.x / 2
	lance.attack.attack_damage = lance_damage
	lance.attack.knockback_force = lance_damage * damage_knockback_ratio
	lance.hit.connect(hit)
	
	if demo:
		lance.enabled = false
		lance.hide()


func _physics_process(delta: float) -> void:
	super(delta)
	lance.monitoring = !block_tiles
	
	if raycast.is_colliding():
		acceleration_boost = 1.0 + (inverse_lerp(-raycast.target_position.x, 0.0,
			raycast.global_position.distance_to(raycast.get_collision_point())) * max_wall_boost)
	else:
		acceleration_boost = 1.0
	top_speed_boost = acceleration_boost / 2
	
	trail.width = lerp(trail_min_width, trail_max_width,
		inverse_lerp(1.0, max_wall_boost, acceleration_boost))
	if not move_dir == Vector2(): trail.max_length = trail_length
	else: trail.max_length = 0
	
	if not lance.reflect_mode:
		var new_size: PackedVector2Array = [Vector2(), Vector2(), Vector2()]
		for i in range(min_size.size()):
			new_size[i] = min_size[i].lerp(max_size[i], 
					inverse_lerp(0, SPEED_LIMIT, linear_velocity.length()))
			new_size[i] = Global.decay_vec2_towards(lance.polygon.polygon[i], new_size[i], 50.0, delta)
		lance.polygon.polygon = new_size
		lance.collider.shape.size = Vector2(new_size[2].x, (new_size[1].y * 2) - 2)

func primary() -> void:
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: return
	clip_component.use(1)
	lance.enabled = true
	lance.reflect_mode = false
	
	if is_instance_valid(thrust_tween): thrust_tween.kill()
	thrust_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel()
	#thrust_tween.tween_property(lance.polygon, "polygon", thrust_size, tween_time)
	#thrust_tween.tween_property(lance.collider.shape, "size", thrust_shape, tween_time)
	#thrust_tween.tween_callback(func():
		#lance.collider.position.x = thrust_shape.x / 2
		#lance.attack.attack_damage = thrust_damage
		#lance.attack.knockback_force = thrust_damage * damage_knockback_ratio)
	#thrust_tween.set_ease(Tween.EASE_IN).chain().tween_interval(thrust_time)
	#thrust_tween.chain().tween_property(lance.polygon, "polygon", lance_size, tween_time)
	#thrust_tween.tween_property(lance.collider.shape, "size", lance_shape, tween_time)
	thrust_tween.tween_callback(func():
		lance.collider.position.x = lance_shape.x / 2
		lance.attack.attack_damage = lance_damage
		lance.attack.knockback_force = lance_damage * damage_knockback_ratio)
	
	apply_central_impulse(Vector2.RIGHT.rotated(rotation) * thrust_force)


func secondary() -> void:
	if not can_parry: return
	lance.attack.attack_damage = lance_damage
	lance.attack.knockback_force = lance_damage * damage_knockback_ratio
	
	can_parry = false
	parry_bar.value = 0.0
	if is_instance_valid(thrust_tween): thrust_tween.kill()
	thrust_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel()
	thrust_tween.tween_property(lance.polygon, "polygon", parry_size, tween_time)
	thrust_tween.tween_property(lance.collider.shape, "size", parry_shape, tween_time)
	thrust_tween.tween_callback(func():
		lance.collider.position.x = parry_shape.x / 2
		lance.enabled = false
		lance.reflect_mode = true)
	thrust_tween.set_ease(Tween.EASE_IN).chain().tween_interval(parry_time)
	thrust_tween.chain().tween_property(lance.polygon, "polygon", lance_size, tween_time)
	thrust_tween.tween_property(lance.collider.shape, "size", lance_shape, tween_time)
	thrust_tween.tween_callback(func():
		lance.collider.position.x = lance_shape.x / 2
		lance.enabled = true
		lance.reflect_mode = false)


func hit(_area: Area2D) -> void:
	if not can_parry:
		can_parry = true
		parry_bar.value = parry_bar.max_value
