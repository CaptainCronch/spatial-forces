extends CanvasLayer

@export var outside1 := Vector2(-256, 16) # get (canvas position of nodes - select box size) for these
@export var outside2 := Vector2(-256, 186)
@export var inside1 := Vector2(16, 16)
#@export var top_right := Vector2(624 - 230, 16)
@export var inside2 := Vector2(16, 344 - 158)
#@export var bottom_right := Vector2(624 - 230, 344 - 158)
@export var ship_select_p1: Control
@export var ship_select_p2: Control
@export var ship_1_line: Line2D
@export var ship_2_line: Line2D
@export var countdown_panel: PanelContainer
@export var fade_panel: Panel
@export var countdown_scroll: ScrollContainer
@export var countdown_text_size := 140
@export var countdown_tween_time := 0.5
@export var camera: MultiTargetCamera
@export var tween_time := 0.2

var ships: Array[Ship] = []
var p1_selected_ship = null
var p2_selected_ship = null
var p1_ready := false
var p2_ready := false
var tween1: Tween
var tween2: Tween
var countdown_tween: Tween



func _ready() -> void:
	ship_select_p1.global_position = outside1
	ship_select_p2.global_position = outside2
	countdown_scroll.scroll_vertical = countdown_text_size * 3
	await get_parent().ready
	change_target()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.RIGHT]) and not p1_ready:
		p1_selected_ship = switch_ship(p1_selected_ship, 1)
		change_target()
		update_boxes(1)
	if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.LEFT]) and not p1_ready:
		p1_selected_ship = switch_ship(p1_selected_ship, -1)
		change_target()
		update_boxes(-1)
	if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.PRIMARY]) and not p1_selected_ship == null:
		p1_ready = !p1_ready
		ready_up()
	if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.SECONDARY]):
		invalidate(0)
		change_target()
		update_boxes(0)

	if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.RIGHT]) and not p2_ready:
		p2_selected_ship = switch_ship(p2_selected_ship, 1)
		change_target()
		update_boxes(1)
	if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.LEFT]) and not p2_ready:
		p2_selected_ship = switch_ship(p2_selected_ship, -1)
		change_target()
		update_boxes(-1)
	if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.PRIMARY]) and not p2_selected_ship == null:
		p2_ready = !p2_ready
		ready_up()
	if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.SECONDARY]):
		invalidate(1)
		change_target()
		update_boxes(0)

	if not p1_selected_ship == null:
		draw_box(ships[p1_selected_ship], ship_1_line, ship_select_p1.underline)
	else:
		ship_1_line.hide()
	if not p2_selected_ship == null:
		draw_box(ships[p2_selected_ship], ship_2_line, ship_select_p2.underline)
	else:
		ship_2_line.hide()


func draw_box(ship: Node2D, line: Line2D, underline: Line2D) -> void:
	line.show()
	var global_transform := ship.get_global_transform_with_canvas()
	var ship_rect := Rect2(global_transform.origin.x - 16 * camera.zoom.x, global_transform.origin.y - 16 * camera.zoom.y, 32 * camera.zoom.x, 32 * camera.zoom.y)
	line.points[0] = ship_rect.position
	line.points[1] = Vector2(ship_rect.position.x + ship_rect.size.x, ship_rect.position.y)
	line.points[2] = Vector2(ship_rect.position.x + ship_rect.size.x, ship_rect.position.y + ship_rect.size.y)
	line.points[3] = Vector2(ship_rect.position.x, ship_rect.position.y + ship_rect.size.y)
	line.points[4] = ship_rect.position
	line.points[5] = underline.get_global_transform_with_canvas().origin


func change_target() -> void:
	if p1_selected_ship == null and p2_selected_ship == null:
		for ship in ships:
			camera.add_target(ship)
		return

	camera.targets.clear()
	if not p1_selected_ship == null:
		camera.add_target(ships[p1_selected_ship])
	if not p2_selected_ship == null:
		camera.add_target(ships[p2_selected_ship])


func update_boxes(direction: int) -> void:
	if p1_selected_ship == null:
		if is_instance_valid(tween1): tween1.kill()
		tween1 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween1.tween_property(ship_select_p1, "position", outside1, tween_time)
	else:
		if is_instance_valid(tween1): tween1.kill()
		tween1 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween1.tween_property(ship_select_p1, "position", inside1, tween_time)
		ship_select_p1.update(p1_selected_ship, direction)

	if p2_selected_ship == null:
		if is_instance_valid(tween2): tween2.kill()
		tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(ship_select_p2, "position", outside2, tween_time)
	else:
		if is_instance_valid(tween2): tween2.kill()
		tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(ship_select_p2, "position", inside2, tween_time)
		ship_select_p2.update(p2_selected_ship, direction)

	if p1_selected_ship == null and p2_selected_ship == null:
		camera.desired_offset = Vector2()
		camera.zoom_scale = 1.0
		camera.position_smoothing_speed = 5.0
	else:
		camera.position_smoothing_speed = 50.0
		# XOR (zoom in further if only one is null, not both or neither (or if both are on the same ship))
		if (p1_selected_ship == null and not p2_selected_ship == null) or (not p1_selected_ship == null and p2_selected_ship == null) or (p1_selected_ship == p2_selected_ship and p1_selected_ship != null):
			camera.zoom_scale = 2.0
			camera.desired_offset = Vector2(-64, 0)
		else:
			camera.zoom_scale = 0.9
			camera.desired_offset = Vector2(-128, 0)


func switch_ship(index, amount: int) -> int:
	var value = index
	if value == null:
		value = 0 if amount == 1 else ships.size() - 1
	else:
		value = wrapi(value + amount, 0, ships.size())
	return value as int


func invalidate(player: int) -> void:
	if player == 0:
		p1_selected_ship = null
		p1_ready = false
	elif player == 1:
		p2_selected_ship = null
		p2_ready = false
	ready_up()


func ready_up() -> void:
	ship_select_p1.ready_up(p1_ready)
	ship_select_p2.ready_up(p2_ready)
	if p1_ready and p2_ready:
		countdown_scroll.show()
		if is_instance_valid(countdown_tween): countdown_tween.kill()
		countdown_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		countdown_tween.tween_property(countdown_panel, "modulate", Color(1, 1, 1, 1), tween_time)
		countdown_tween.set_trans(Tween.TRANS_BOUNCE).parallel().tween_interval(1.0)
		countdown_tween.tween_property(countdown_scroll, "scroll_vertical", countdown_text_size * 2, countdown_tween_time)
		countdown_tween.parallel().tween_interval(1.0)
		countdown_tween.tween_property(countdown_scroll, "scroll_vertical", countdown_text_size, countdown_tween_time)
		countdown_tween.parallel().tween_interval(1.0)
		countdown_tween.tween_property(countdown_scroll, "scroll_vertical", 0, countdown_tween_time)
		countdown_tween.set_trans(Tween.TRANS_CUBIC).tween_property(fade_panel, "modulate", Color(1, 1, 1, 1), tween_time)
		countdown_tween.tween_callback(func():
			Global.p1_ship = p1_selected_ship
			Global.p2_ship = p2_selected_ship)
		countdown_tween.tween_callback(func(): get_tree().change_scene_to_packed(Global.LEVEL))

	else:
		countdown_scroll.hide()
		if is_instance_valid(countdown_tween): countdown_tween.kill()
		countdown_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		countdown_tween.tween_property(countdown_panel, "modulate", Color(1, 1, 1, 0), tween_time)
		countdown_scroll.scroll_vertical = countdown_text_size * 3
