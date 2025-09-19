extends Ship

const BULLET := preload("uid://dgiyioekqi3m1")
const HOOK := preload("uid://c2iayqdq07ppw")

@export var clip_component: ClipComponent
@export var barrel_right: Marker2D
@export var barrel_left: Marker2D
@export var hook_bar: Meter
@export var rope: Line2D
@export var bullet_angle_variance := 0.05
@export var min_fire_delay := 0.05
@export var max_fire_delay := 0.1
@export var rampup: Curve
@export var recoil_force := 5.0
@export var min_hook_force := 20.0
@export var max_hook_force := 100.0
@export var max_hook_distance := 256.0
@export var shots_to_hook := 3
@export var rope_decay := 20.0

var shot_counter := 3
var current_hook: Bullet

@onready var current_barrel := barrel_right


func _ready() -> void:
	super()
	hook_bar.max_value = shots_to_hook
	hook_bar.value = shot_counter


func _process(delta) -> void:
	super(delta)
	rope.global_position = global_position
	if is_instance_valid(current_hook):
		rope.set_point_position(1, rope.to_local(current_hook.global_position))
	else:
		rope.set_point_position(1, Global.decay_vec2_towards(rope.get_point_position(1), Vector2.ZERO, rope_decay))


func primary_hold() -> void:
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: return
	var clip_factor := rampup.sample(inverse_lerp(0.0, clip_component.max_clip, clip_component.clip))
	clip_component.use(1, 1.0, 0.0, lerp(min_fire_delay, max_fire_delay, clip_factor))
	
	var bullet_instance: Bullet
	bullet_instance = BULLET.instantiate()
	bullet_instance.position = current_barrel.get_global_position()
	bullet_instance.sprite.global_position = current_barrel.get_global_position()
	bullet_instance.rotation = rotation + randfn(0.0, bullet_angle_variance)
	bullet_instance.hit.connect(hit)
	set_projectile_player(bullet_instance)
	get_tree().current_scene.call_deferred("add_child", bullet_instance)
	
	apply_central_impulse(Vector2.RIGHT.rotated(rotation + PI) * recoil_force)
	
	if current_barrel == barrel_left: current_barrel = barrel_right
	elif current_barrel == barrel_right: current_barrel = barrel_left

func secondary() -> void:
	if shot_counter < shots_to_hook or block_tiles: return
	shot_counter = 0
	hook_bar.value = shot_counter
	var hook_instance: Bullet
	hook_instance = HOOK.instantiate()
	hook_instance.position = clip_component.get_global_position()
	hook_instance.sprite.global_position = clip_component.get_global_position()
	hook_instance.rotation = rotation
	hook_instance.hit.connect(hook_hit)
	set_projectile_player(hook_instance)
	if player_id == PlayerIDs.PLAYER_2:
		hook_instance.set_collision_mask_value(2, true)
		hook_instance.set_collision_mask_value(3, false)
	get_tree().current_scene.call_deferred("add_child", hook_instance)
	current_hook = hook_instance
	
	apply_central_impulse(Vector2.RIGHT.rotated(rotation + PI) * recoil_force * 5.0)


func hit(_pos: Vector2) -> void:
	shot_counter += 1
	hook_bar.value = shot_counter


func hook_hit(pos: Vector2) -> void:
	var hook_force := remap(global_position.distance_to(pos), 0.0, max_hook_distance, min_hook_force, max_hook_force)
	linear_velocity = global_position.direction_to(pos) * hook_force
