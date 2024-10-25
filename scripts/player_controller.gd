extends RigidBody2D

const SPEED_LIMIT = 200

enum PlayerInputs {UP, RIGHT, DOWN, LEFT, PRIMARY, SECONDARY}
const PLAYER1_INPUTS := ["p1_up", "p1_right", "p1_down", "p1_left", "p1_primary", "p1_secondary"]
const PLAYER2_INPUTS := ["p2_up", "p2_right", "p2_down", "p2_left", "p2_primary", "p2_secondary"]
var inputs := PLAYER1_INPUTS

enum PlayerColors {BLUE, RED, GREEN, CYAN, MAGENTA, YELLOW}
const COLOR_VALUES := [Color(0,0,1),Color(1,0,0),Color(0,1,0),Color(0,1,1),Color(1,0,1),Color(1,1,0)]

@export var sprite : Sprite2D
@export var hitbox : HitboxComponent

@export var player_color : PlayerColors
@export var player_id := 0
@export var rotation_speed := 250
@export var acceleration := 10
@export var back_acceleration := 2
@export var top_speed := 50
@export var bullet_speed := 200
@export var max_clip := 4

var rotation_dir := 0
var move_dir := Vector2()
var clip := max_clip
#var timer = 0

#@onready var bullet_spawn


func _ready():
	get_tree().current_scene.camera.add_target(self)
	call_deferred("initialize")


func initialize():
	sprite.modulate = COLOR_VALUES[player_color]

	if player_id == 1:
		remove_from_group("Player1")
		add_to_group("Player2")
		inputs = PLAYER2_INPUTS
		hitbox.set_collision_layer_value(2, false)
		hitbox.set_collision_layer_value(3, true)
		hitbox.set_collision_mask_value(2, true)
		hitbox.set_collision_mask_value(3, false)
		hitbox.remove_from_group("Player1")
		hitbox.add_to_group("Player2")


func _physics_process(_delta):
	apply_torque(rotation_dir * rotation_speed) # spin
	if linear_velocity.length() < top_speed:
		apply_central_force(move_dir.rotated(rotation) * acceleration) # move


func _process(_delta):
	get_input()


func get_input():
	rotation_dir = 0
	move_dir = Vector2()

	if Input.is_action_pressed(inputs[PlayerInputs.RIGHT]):
		rotation_dir += 1
	if Input.is_action_pressed(inputs[PlayerInputs.LEFT]):
		rotation_dir -= 1

	if Input.is_action_pressed(inputs[PlayerInputs.UP]):
		move_dir += Vector2(acceleration, 0)
	if Input.is_action_pressed(inputs[PlayerInputs.DOWN]):
		move_dir -= Vector2(back_acceleration, 0)

	if Input.is_action_just_pressed(inputs[PlayerInputs.PRIMARY]):
		fire()


func _integrate_forces(state): # if ship_going_faster_than_top_speed: dont()
	if state.linear_velocity.length() > SPEED_LIMIT:
		state.linear_velocity = state.linear_velocity.normalized() * SPEED_LIMIT


func fire():
	pass # to be overridden in inherited classes
