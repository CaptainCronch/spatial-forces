extends CanvasLayer

@export var outside1 := Vector2(-256, 16) # get (canvas position of nodes - select box size) for these
@export var outside2 := Vector2(-256, 186)
@export var inside1 := Vector2(16, 16)
#@export var top_right := Vector2(624 - 230, 16)
@export var inside2 := Vector2(16, 344 - 158)
#@export var bottom_right := Vector2(624 - 230, 344 - 158)
@export var ship_select_p1: VBoxContainer
@export var ship_select_p2: VBoxContainer
@export var camera: MultiTargetCamera
@export var tween_time := 0.2

var ships: Array[Ship] = []
var p1_selected_ship = null
var p2_selected_ship = null
#var positions := [top_left, top_right, bottom_right, bottom_left]
#var selects := [null, null, null, null]
var tween1: Tween
var tween2: Tween


func _ready() -> void:
	tween1 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	ship_select_p1.global_position = outside1
	ship_select_p2.global_position = outside2
	ship_select_p2.player_number.text = "P2"
	await get_parent().ready
	change_target()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.RIGHT]):
		p1_selected_ship = switch_ship(p1_selected_ship, 1)
		change_target()
	if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.LEFT]):
		p1_selected_ship = switch_ship(p1_selected_ship, -1)
		change_target()
	if Input.is_action_just_pressed(InputComponent.PLAYER1_INPUTS[InputComponent.PlayerInputs.SECONDARY]):
		invalidate(0)
		change_target()

	if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.RIGHT]):
		p2_selected_ship = switch_ship(p2_selected_ship, 1)
		change_target()
	if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.LEFT]):
		p2_selected_ship = switch_ship(p2_selected_ship, -1)
		change_target()
	if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.SECONDARY]):
		invalidate(1)
		change_target()

	check_overlap()


func check_overlap() -> void:
	if p1_selected_ship:
		ships[p1_selected_ship]


func change_target() -> void:
	if p1_selected_ship == null and p2_selected_ship == null:
		for ship in ships:
			camera.add_target(ship)
		update_boxes()
		#print(p1_selected_ship, " / ", p2_selected_ship, " -> ", camera.targets.size())
		return

	#for target in camera.targets.size() - 1: # run through every target and remove as many as you can
		#if not p2_selected_ship == null and not target == ships[p2_selected_ship]:
			#camera.remove_target(target) # dont remove the other player's selected ship (if they have one)
		#elif not p1_selected_ship == null and not target == ships[p1_selected_ship]:
		#camera.targets.remove_at(target) # same but other player
	camera.targets.clear()
	#print("after deleting = ", camera.targets.size())
# second thought. delete everything and then bring back the 2 that we need.
	if not p1_selected_ship == null:
		camera.add_target(ships[p1_selected_ship])
	if not p2_selected_ship == null:
		camera.add_target(ships[p2_selected_ship])
	update_boxes()

	#print("after adding = ", camera.targets.size())
	#print(p1_selected_ship, " / ", p2_selected_ship, " -> ", camera.targets.size())


func update_boxes() -> void:
	if p1_selected_ship == null:
		if is_instance_valid(tween1): tween1.kill()
		tween1 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween1.tween_property(ship_select_p1, "position", outside1, tween_time)
		#selects[selects.find(ship_select_p1)] = null
	else:
		if is_instance_valid(tween1): tween1.kill()
		tween1 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween1.tween_property(ship_select_p1, "position", inside1, tween_time)
		#selects[0] = ship_select_p1
		ship_select_p1.update(p1_selected_ship)

	if p2_selected_ship == null:
		if is_instance_valid(tween2): tween2.kill()
		tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(ship_select_p2, "position", outside2, tween_time)
		#selects[selects.find(ship_select_p2)] = null
	else:
		if is_instance_valid(tween2): tween2.kill()
		tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(ship_select_p2, "position", inside2, tween_time)
		#selects[0] = ship_select_p2
		ship_select_p2.update(p2_selected_ship)

	if p1_selected_ship == null and p2_selected_ship == null:
		camera.desired_offset = Vector2()
		camera.zoom_scale = 1.0
		camera.position_smoothing_speed = 5.0
	else:
		camera.position_smoothing_speed = 10.0
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
	elif player == 1:
		p2_selected_ship = null
