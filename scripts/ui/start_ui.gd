extends CanvasLayer

@export var inside: Control
@export var outside: Control
@export var focus_outside: Control

@export var p1_focus: Node2D
@export var p1_line: Line2D
@export var p1_subline: Line2D
@export var p2_focus: Node2D
@export var p2_line: Line2D
@export var p2_subline: Line2D

@export var play_button: Button
@export var map_up: Control
@export var map_down: Control
@export var map_container: MarginContainer
@export var map_sprite: Sprite2D
@export var map_sprite_holder: Node2D

@export var map_scale := Vector2(1.5, 0.8)
@export var map_rotation_decay := 5.0
@export_range(0, 360, 1, "radians") var desired_map_rotation_speed := TAU / 8 ## Speed in degrees per second (translated to radians).

@export var desired_p1_focus_speed := TAU / 8
@export var desired_p2_focus_speed := -TAU / 8

var p1_focus_rotation_speed := 0.0
var p2_focus_rotation_speed := 0.0

var map_rotation_speed := 0.0
var map_rotation_direction := 1

var p1_focused_node: Control = null
var p2_focused_node: Control = null


func _ready() -> void:
	map_container.position = outside.position
	p1_focus.position = focus_outside.position
	p2_focus.position = focus_outside.position

	var largest: float = map_sprite.texture.get_height() if map_sprite.texture.get_height() >= map_sprite.texture.get_width() else map_sprite.texture.get_width()
	map_sprite.scale = Vector2(1.0/(largest / 64.0), 1.0/(largest / 64.0))


func _process(delta: float) -> void:
	transform_map(delta)
	get_input()
	move_focus(delta)


func get_input() -> void:
	if any_input_check(0): p1_focus_rotation_speed += TAU / 4
	if any_input_check(1): p2_focus_rotation_speed -= TAU / 4

	if not p1_focused_node == null:
		if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.RIGHT]):
			if p1_focused_node.focus_neighbor_right: p1_focused_node = p1_focused_node.get_node(p1_focused_node.focus_neighbor_right)
		if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.LEFT]):
			if p1_focused_node.focus_neighbor_left: p1_focused_node = p1_focused_node.get_node(p1_focused_node.focus_neighbor_left)
		if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.UP]):
			if p1_focused_node.focus_neighbor_top: p1_focused_node = p1_focused_node.get_node(p1_focused_node.focus_neighbor_top)
		if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.DOWN]):
			if p1_focused_node.focus_neighbor_bottom: p1_focused_node = p1_focused_node.get_node(p1_focused_node.focus_neighbor_bottom)
		if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.PRIMARY]):
			if p1_focused_node is Button:
				p1_focused_node.button_pressed
	elif p1_focused_node == null and any_input_check(0): p1_focused_node = play_button

	if not p2_focused_node == null:
		if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.RIGHT]):
			if p2_focused_node.focus_neighbor_right: p2_focused_node = p2_focused_node.get_node(p2_focused_node.focus_neighbor_right)
		if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.LEFT]):
			if p2_focused_node.focus_neighbor_left: p2_focused_node = p2_focused_node.get_node(p2_focused_node.focus_neighbor_left)
		if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.UP]):
			if p2_focused_node.focus_neighbor_top: p2_focused_node = p2_focused_node.get_node(p2_focused_node.focus_neighbor_top)
		if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.DOWN]):
			if p2_focused_node.focus_neighbor_bottom: p2_focused_node = p2_focused_node.get_node(p2_focused_node.focus_neighbor_bottom)
	elif p2_focused_node == null and any_input_check(1): p2_focused_node = play_button


func move_focus(delta: float):
	if p1_focused_node: p1_focus.global_position = Global.decay_vec2_towards(p1_focus.global_position, p1_focused_node.global_position + (p1_focused_node.size/2), map_rotation_decay)
	else: p1_focus.global_position = Global.decay_vec2_towards(p1_focus.global_position, focus_outside.global_position, map_rotation_decay)

	if p2_focused_node: p2_focus.global_position = Global.decay_vec2_towards(p2_focus.global_position, p2_focused_node.global_position + (p2_focused_node.size/2), map_rotation_decay)
	else: p2_focus.global_position = Global.decay_vec2_towards(p2_focus.global_position, focus_outside.global_position, map_rotation_decay)

	p1_focus_rotation_speed = Global.decay_towards(p1_focus_rotation_speed, desired_p1_focus_speed, 1)
	p2_focus_rotation_speed = Global.decay_towards(p2_focus_rotation_speed, desired_p2_focus_speed, 1)

	p1_line.rotate(p1_focus_rotation_speed * delta)
	p1_subline.rotate(-p1_focus_rotation_speed/4 * delta)
	p2_line.rotate(p2_focus_rotation_speed * delta)
	p2_subline.rotate(-p2_focus_rotation_speed/4 * delta)


func any_input_check(id: int) -> bool:
	var player_array: PackedStringArray
	if id == 0:
		player_array = InputComponent.PLAYER1_INPUTS.duplicate()
	elif id == 1:
		player_array = InputComponent.PLAYER2_INPUTS.duplicate()

	if Input.is_action_just_pressed(player_array[InputComponent.PlayerInputs.RIGHT]) or \
		Input.is_action_just_pressed(player_array[InputComponent.PlayerInputs.LEFT]) or \
		Input.is_action_just_pressed(player_array[InputComponent.PlayerInputs.UP]) or \
		Input.is_action_just_pressed(player_array[InputComponent.PlayerInputs.DOWN]) or \
		Input.is_action_just_pressed(player_array[InputComponent.PlayerInputs.PRIMARY]) or \
		Input.is_action_just_pressed(player_array[InputComponent.PlayerInputs.SECONDARY]):
		return true
	else:
		return false


func transform_map(delta: float) -> void:
	map_rotation_speed = Global.decay_towards(map_rotation_speed, desired_map_rotation_speed * map_rotation_direction, map_rotation_decay)
	map_sprite.rotation += map_rotation_speed * delta
	map_sprite_holder.scale = map_scale
	var largest := map_sprite.texture.get_height() if map_sprite.texture.get_height() >= map_sprite.texture.get_width() else map_sprite.texture.get_width()
	map_sprite.scale = Vector2(1.0/(largest / 64.0), 1.0/(largest / 64.0))


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	pass # Replace with function body.
