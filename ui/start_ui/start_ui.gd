extends CanvasLayer

#region exports
@export var inside: Control
@export var outside: Control
@export var focus_outside: Control
@export var map_position: Control
@export var map_above: Control
@export var map_below: Control

@export var p1_focus: FocusSelector
@export var p2_focus: FocusSelector

@export var play_button: Button
@export var options_button: Button
@export var exit_button: Button

@export var options_container: MarginContainer

@export var map_up: Control
@export var map_down: Control
@export var map_box: Control
@export var map_container: MarginContainer
@export var map_sprite: Sprite2D
@export var map_sprite_holder: Node2D
@export var map_name: Label
@export var map_type: Label
@export var map_extra: Label

@export var map_scale := Vector2(1.5, 0.8)
@export var map_rotation_decay := 5.0
@export_range(0, 360, 1, "radians") var desired_map_rotation_speed := TAU / 8 ## Speed in degrees per second (translated to radians).

@export var add_button: Button
@export var filename_edit: LineEdit
@export var url_edit: LineEdit
@export var download_container: VBoxContainer
@export var http_request: HTTPRequest
@export var toast_container: VBoxContainer
@export var toast_title: Label
@export var toast_subtitle: Label
@export var toast_in_pos: Control
@export var toast_out_pos: Control

@export var desired_p1_focus_speed := TAU / 8
@export var desired_p2_focus_speed := -TAU / 8

@export var fade_panel: Panel
@export var tween_time := 0.5
#endregion

var map_rotation_speed := 0.0
var map_rotation_direction := 1
var download_filename := ""
var toast_tween: Tween

var selected_map := 0

var p1_focused_node: Control = null
var p2_focused_node: Control = null

var map_shown := false
var options_shown := false
var frozen := false
var map_tween: Tween


func _ready() -> void:
	Global.current_map = Global.maps[Global.maps.keys()[selected_map]]
	#print(Global.current_map)
	map_container.position = outside.position
	map_box.position = map_position.position
	p1_focus.position = focus_outside.position
	p2_focus.position = focus_outside.position
	toast_container.position.y = toast_out_pos.position.y

	var largest: float = map_sprite.texture.get_height() if map_sprite.texture.get_height() >= map_sprite.texture.get_width() else map_sprite.texture.get_width()
	map_sprite.scale = Vector2(1.0/(largest / 64.0), 1.0/(largest / 64.0))


func _process(delta: float) -> void:
	transform_map(delta)
	get_input()
	move_focus(delta)


func get_input() -> void:
	if Input.is_action_just_pressed("back"):
		if p1_focused_node == add_button or p1_focused_node == add_button:
			frozen = false
			download_container.hide()
			focus_outside.grab_focus()
			filename_edit.text = ""
			url_edit.text = ""
	if Input.is_action_just_pressed("select"):
		if filename_edit.has_focus():
			url_edit.grab_focus()

	if frozen: return
	if any_input_check(0): p1_focus.spin_speed += TAU * 2
	if any_input_check(1): p2_focus.spin_speed -= TAU * 2

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
			p1_focused_node.focus_entered.emit()
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
		if Input.is_action_just_pressed(InputComponent.PLAYER2_INPUTS[InputComponent.PlayerInputs.PRIMARY]):
			p2_focused_node.focus_entered.emit()
	elif p2_focused_node == null and any_input_check(1): p2_focused_node = play_button


func move_focus(_delta: float):
	if p1_focused_node: p1_focus.global_position = Global.decay_vec2_towards(p1_focus.global_position, p1_focused_node.global_position + (p1_focused_node.size/2), p1_focus.spin_decay)
	else: p1_focus.global_position = Global.decay_vec2_towards(p1_focus.global_position, focus_outside.global_position, p1_focus.spin_decay)

	if p2_focused_node: p2_focus.global_position = Global.decay_vec2_towards(p2_focus.global_position, p2_focused_node.global_position + (p2_focused_node.size/2), p2_focus.spin_decay)
	else: p2_focus.global_position = Global.decay_vec2_towards(p2_focus.global_position, focus_outside.global_position, p2_focus.spin_decay)


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


func _on_play_focus_entered() -> void:
	var play_tween := create_tween().set_trans(Tween.TRANS_CUBIC)
	if not map_shown:
		if options_shown: play_tween.tween_property(options_container, "position", outside.position, tween_time)
		play_tween.set_ease(Tween.EASE_OUT).tween_property(map_container, "position", inside.position, tween_time)
		play_button.focus_neighbor_right = play_button.get_path_to(map_down)
		options_button.focus_neighbor_right = options_button.get_path_to(map_down)
		map_shown = true
		options_shown = false
	else:
		play_tween.set_ease(Tween.EASE_IN).tween_property(map_container, "position", outside.position, tween_time)
		map_shown = false
		play_button.focus_neighbor_right = ""
		options_button.focus_neighbor_right = ""
		if p1_focused_node != play_button or p1_focused_node != options_button or p1_focused_node != null: p1_focused_node = play_button
		if p2_focused_node != play_button or p2_focused_node != options_button or p2_focused_node != null: p2_focused_node = play_button


func change_map(dir: int) -> void:
	if is_instance_valid(map_tween): map_tween.kill()
	map_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	map_tween.tween_property(map_sprite, "modulate", Color(1, 1, 1, 0), 0)
	#var first := map_above.global_position if dir == -1 else map_below.global_position
	#map_tween.set_ease(Tween.EASE_IN).tween_property(map_box, "global_position", first, tween_time/2)
	map_tween.tween_callback(
		func():
			#var second := map_below.global_position if dir == -1 else map_above.global_position
			#map_box.global_position = second
			selected_map = wrapi(selected_map + dir, 0, Global.maps.keys().size())
			reload_map_display()
	)
	map_tween.tween_property(map_sprite, "modulate", Color(1, 1, 1, 1), tween_time)
	#map_tween.set_ease(Tween.EASE_OUT).tween_property(map_box, "global_position", map_position.global_position, tween_time/2)
	transform_map(get_process_delta_time())


func reload_map_display() -> void:
	map_sprite.texture = Global.maps[Global.maps.keys()[selected_map]]
	var selected_map_name: String = Global.maps.keys()[selected_map]
	Global.current_map = Global.maps[selected_map_name]
	map_name.text = selected_map_name
	map_type.text = ""
	map_extra.text = ""
	if selected_map_name.count("_") < 1: return
	match selected_map_name.split("_")[0]:
		"tst": map_type.text = "Development test map"
		"sel": map_type.text = "Selection screen map"
		"dm2": map_type.text = "2-player deathmatch"
	if selected_map_name.count("_") < 2: return
	var extra := selected_map_name.split("_")[2].split(".")[0] # remove the .png file ending
	var plural := "" if extra.to_int() == 1 else "s"
	map_extra.text = extra + " round" + plural
	Global.rounds = extra.to_int()
	#match extra:
		#"1":
			#map_extra.text = "1 round"
		#"2":
			#map_extra.text = "2 rounds"
		#"3":
			#map_extra.text = "3 rounds"
		#"4":
			#map_extra.text = "4 rounds"
		#"5":
			#map_extra.text = "5 rounds"


func toast(title: String, subtitle := "") -> void:
	toast_subtitle.show()
	if subtitle == "": toast_subtitle.hide()
	toast_title.text = title
	toast_subtitle.text = subtitle
	toast_container.position.y = toast_out_pos.position.y
	if is_instance_valid(toast_tween): toast_tween.kill()
	toast_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	toast_tween.tween_property(toast_container, "position:y", toast_in_pos.position.y, tween_time)
	toast_tween.tween_interval(tween_time*4)
	toast_tween.tween_property(toast_container, "position:y", toast_out_pos.position.y, tween_time)


func _on_button_up_focus_entered() -> void:
	change_map(-1)


func _on_button_down_focus_entered() -> void:
	change_map(1)


func _on_go_focus_entered() -> void:
	var fade_tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	fade_tween.tween_property(fade_panel, "modulate", Color(1, 1, 1, 1), tween_time)
	fade_tween.tween_callback(get_tree().change_scene_to_file.bind("res://levels/select.tscn"))


func _on_add_focus_entered() -> void:
	filename_edit.grab_focus()
	frozen = true
	download_container.show()
	url_edit.editable = true
	filename_edit.editable = true


func _on_url_edit_text_submitted(new_text: String) -> void:
	if download_filename == "" or new_text == "":
		frozen = false
		filename_edit.text = ""
		url_edit.text = ""
		download_container.hide()
		focus_outside.grab_focus()
		return
	if not download_filename.substr(download_filename.length() - 4) == ".png":
		toast("Make sure the filename ends with \".png\"")
		frozen = false
		download_container.hide()
		filename_edit.text = ""
		url_edit.text = ""
		focus_outside.grab_focus()
		return
	http_request.download_file = "user://maps/" + download_filename
	var result := http_request.request(new_text)
	if not result == 0:
		frozen = false
		download_container.hide()
		filename_edit.text = ""
		url_edit.text = ""
		push_error("HTTP request error: " + str(result))
		match result:
			3: toast("If you see this error something has gone royally wrong", "I hope you're ready for the consequences")
			44: toast("Still processing previous request", "Wait a while")
			31: toast("Invalid URL format", "Make sure the link is formatted as \"https://www.example.com/[original filename].png\"")
			25: toast("Could not connect to server", "This is an internet issue")
	url_edit.editable = false
	filename_edit.editable = false
	focus_outside.grab_focus()


func _on_http_request_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	frozen = false
	download_container.hide()
	filename_edit.text = ""
	url_edit.text = ""
	if not result == 0:
		push_error("Problem on map response: ", result, " / ", response_code)
		match result:
			1: toast("Chunked body size mismatch error", "Possible causes include network errors, server misconfiguration, or issues with chunked encoding")
			2: toast("Could not connect to server", "Request failed while connecting")
			3: toast("Could not resolve hostname", "Your DNS is messed up")
			4: toast("Connection error", "It's a read/write thing")
			5: toast("TLS handshake error", "Maybe the server's TLS certificate is expired")
			6: toast("No response", "Server quiet")
			7: toast("Request body size limit exceeded", "You should not get this error as the request body should be empty")
			8: toast("Response decompression failed", "Could be caused by unsupported or incorrect compression format, corrupted data, or incomplete transfer")
			9: toast("Request failed", "For some reason (9)")
			10: toast("Could not open the download file", "This is an HTTPRequest issue")
			11: toast("Could not write to the download file", "This is an HTTPRequest issue")
			12: toast("Maximum redirects reached", "Tell the server to stop playing ring around the rosie")
			13: toast("Connection timeout", "It should not take so long to download an extremely small png file")
		return
	toast("Downloaded new map", "to " + ProjectSettings.globalize_path("user://maps/") + download_filename)
	Global.load_user_maps()
	reload_map_display()


func _on_filename_edit_text_changed(new_text: String) -> void:
	download_filename = new_text


func _on_exit_focus_entered() -> void:
	get_tree().quit()


func _on_swap_controllers_focus_entered() -> void:
	for action in InputComponent.PLAYER1_INPUTS:
		pass
	for action in InputComponent.PLAYER2_INPUTS:
		pass
