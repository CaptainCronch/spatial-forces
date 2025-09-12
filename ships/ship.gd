extends RigidBody2D
class_name Ship

const SPEED_LIMIT := 300.0

enum PlayerIDs {PLAYER_1, PLAYER_2}
var player_id: PlayerIDs

@export var hitbox : HitboxComponent
@export var input: InputComponent
@export var steering: SteeringComponent

@export var rotation_speed := 360.0
@export var acceleration := 128.0
@export var back_acceleration := 16.0
@export var top_speed := 128.0

var top_speed_boost := 1.0
var acceleration_boost := 1.0
var rotational_boost := 1.0
var rotation_dir := 0
var move_dir := Vector2()
var block_tiles: Array[RID] = []
var demo := false
#var timer = 0

#@onready var bullet_spawn


func _ready():
	call_deferred("initialize")
	hitbox.body_shape_entered.connect(_on_hitbox_body_shape_entered)
	hitbox.body_shape_exited.connect(_on_hitbox_body_shape_exited)


func initialize():
	if not demo: get_tree().current_scene.camera.add_target(self)

	if player_id == PlayerIDs.PLAYER_2:
		remove_from_group("Player1")
		add_to_group("Player2")
		if is_instance_valid(input): input.inputs = input.PLAYER2_INPUTS
		hitbox.set_collision_layer_value(2, false)
		hitbox.set_collision_layer_value(3, true)
		hitbox.set_collision_mask_value(2, true)
		hitbox.set_collision_mask_value(3, false)
		hitbox.remove_from_group("Player1")
		hitbox.add_to_group("Player2")


func _physics_process(_delta):
	apply_torque(rotation_dir * rotation_speed * rotational_boost) # spin
	apply_central_force(move_dir.rotated(rotation)) # move

	var back_factor := minf(pow(2, # exponential curve so we get pushed back more the closer we are to the top speed
		(linear_velocity.length() - (top_speed * top_speed_boost))),
		acceleration * acceleration_boost # make sure we dont get slingshotted back by limiting the back force
		) * absf(signf(move_dir.length())) # only apply a force if we're actually trying to move

	apply_central_force(linear_velocity.normalized() * -1 * back_factor) # drag


func _process(_delta):
	pass
	#$Label.text = str(roundf(linear_velocity.length())) # debug


func _integrate_forces(state): # if ship_going_faster_than_speed_limit: dont()
	if state.linear_velocity.length() > SPEED_LIMIT:
		state.linear_velocity = state.linear_velocity.normalized() * SPEED_LIMIT


func primary(): pass
func primary_release(): pass
func primary_hold(): pass

func secondary(): pass
func secondary_release(): pass
func secondary_hold(): pass


func die():
	if demo: return
	if is_instance_valid(input): input.disabled = true
	if is_instance_valid(steering): steering.disabled = true

	await get_tree().create_timer(2.0).timeout
	get_tree().current_scene.camera.remove_target(self)
	get_tree().current_scene.camera.zoom_scale = 2.0
	await get_tree().create_timer(2.0).timeout
	get_tree().current_scene.camera.zoom_scale = 1.0
	await get_tree().create_timer(2.0).timeout
	get_tree().current_scene.end_round()
	#queue_free()


func set_projectile_player(projectile: Node2D) -> void:
	if player_id == PlayerIDs.PLAYER_2:
		projectile.set_collision_layer_value(2, false)
		projectile.set_collision_layer_value(3, true)
		projectile.hurtbox.set_collision_layer_value(2, false)
		projectile.hurtbox.set_collision_layer_value(3, true)
		projectile.hurtbox.set_collision_mask_value(2, true)
		projectile.hurtbox.set_collision_mask_value(3, false)


func _on_hitbox_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		var coords : Vector2i = body.get_coords_for_body_rid(body_rid)
		if body.get_cell_tile_data(coords).get_custom_data("Type") == "player_pass":
			block_tiles.append(body_rid)


func _on_hitbox_body_shape_exited(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		var coords : Vector2i = body.get_coords_for_body_rid(body_rid)
		if body.get_cell_tile_data(coords).get_custom_data("Type") == "player_pass":
			block_tiles.erase(body_rid)
