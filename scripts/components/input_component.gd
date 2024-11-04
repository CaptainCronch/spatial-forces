extends Node2D
class_name InputComponent

enum PlayerInputs {UP, RIGHT, DOWN, LEFT, PRIMARY, SECONDARY}
const PLAYER1_INPUTS := ["p1_up", "p1_right", "p1_down", "p1_left", "p1_primary", "p1_secondary"]
const PLAYER2_INPUTS := ["p2_up", "p2_right", "p2_down", "p2_left", "p2_primary", "p2_secondary"]
var inputs := PLAYER1_INPUTS

var disabled := false

@export var target: Ship


func _process(_delta: float) -> void:
	target.rotation_dir = 0
	target.move_dir = Vector2()

	if disabled: return

	if Input.is_action_pressed(inputs[PlayerInputs.RIGHT]):
		target.rotation_dir += 1
	if Input.is_action_pressed(inputs[PlayerInputs.LEFT]):
		target.rotation_dir -= 1

	if Input.is_action_pressed(inputs[PlayerInputs.UP]):
		target.move_dir += Vector2(target.acceleration * target.acceleration_boost, 0)
	if Input.is_action_pressed(inputs[PlayerInputs.DOWN]):
		target.move_dir += Vector2(-target.back_acceleration * target.acceleration_boost, 0)

	if Input.is_action_just_pressed(inputs[PlayerInputs.PRIMARY]):
		target.primary()
	if Input.is_action_just_released(inputs[PlayerInputs.PRIMARY]):
		target.primary_release()
	if Input.is_action_pressed(inputs[PlayerInputs.PRIMARY]):
		target.primary_hold()

	if Input.is_action_just_pressed(inputs[PlayerInputs.SECONDARY]):
		target.secondary()
	if Input.is_action_just_released(inputs[PlayerInputs.SECONDARY]):
		target.secondary_release()
	if Input.is_action_pressed(inputs[PlayerInputs.SECONDARY]):
		target.secondary_hold()
