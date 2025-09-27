extends Node2D

#region tile consts
const BASE_TILES_SOURCE_ID := 0
const SCENE_TILES_SOURCE_ID := 1
const NONE := Vector2i.ZERO
const BOUNCY_COORDS := Vector2i(1, 2)
const SMOOTH_COORDS := Vector2i(3, 0)
const ABSORBENT_COORDS := Vector2i(3, 1)
const PLAYER_PASS_COORDS := Vector2i(2, 0)
const PROJECTILE_PASS_COORDS := Vector2i(2, 2)
const BACKGROUND_COORDS := Vector2i(0, 2)
const DIAMOND_DISPENSER_ID := 0
const CROSS_DISPENSER_ID := 1
const SQUARE_DISPENSER_ID := 24
const SPIKES_ID := [22, 20, 21, 23]
const BOOST_PAD_ID := [6, 4, 5, 7]
const GRAVITY_WELL_ID := [10, 8, 9, 11]
const ONE_WAY_ID := [13, 12, 14, 15]
const PINWHEEL_ID := -1
const BIG_CRATE_ID := 3
const BIG_BALL_ID := 2
const SMALL_CRATE_ID := 17
const SMALL_BALL_ID := 16
const SMALL_PLANK_ID := 19
const SMALL_PILL_ID := 18
#endregion

const STEERING := preload("uid://qa02kvluhq2n")
const VALID_COLORS: Array[Vector3i] = [
		Vector3(255, 255, 255), #ffffff
		Vector3(1, 1, 1), #000000
		#Vector3(0, 0, 0, 0), #000000 transparent
		#Vector3(255, 255, 255, 0), #ffffff transparent
		Vector3(204, 255, 255), #ccffff
		Vector3(153, 255, 255), #99ffff
		Vector3(255, 255, 85), #ffff55
		Vector3(255, 255, 204), #ffffcc
		Vector3(85, 85, 85), #555555
		Vector3(255, 0, 255), #ff00ff
		Vector3(255, 85, 255), #ff55ff
		Vector3(255, 204, 255), #ffccff
		Vector3(153, 0, 0), #990000
		Vector3(153, 34, 34), #992222
		Vector3(153, 68, 68), #994444
		Vector3(153, 102, 102), #996666
		Vector3(153, 153, 0), #999900
		Vector3(153, 153, 34), #999922
		Vector3(153, 153, 68), #999944
		Vector3(153, 153, 102), #999966
		Vector3(0, 153, 0), #009900
		Vector3(34, 153, 34), #229922
		Vector3(68, 153, 68), #449944
		Vector3(102, 153, 102), #669966
		Vector3(0, 0, 153), #000099
		Vector3(34, 34, 153), #222299
		Vector3(68, 68, 153), #444499
		Vector3(102, 102, 153), #666699
		Vector3(255, 85, 85), #ff5555
		Vector3(0, 204, 0), #00cc00
		Vector3(0, 204, 34), #00cc22
		Vector3(0, 204, 68), #00cc44
		Vector3(0, 204, 102), #00cc66
		Vector3(0, 204, 136), #00cc88
		Vector3(0, 204, 170), #00ccaa
		Vector3(0, 0, 255), #0000ff
		Vector3(255, 0, 0), #ff0000
		Vector3(0, 255, 0), #00ff00
		Vector3(255, 255, 0), #ffff00
]

enum Mode {GAME, DEMO, NONE, TEST}

@export var current_mode: Mode
@export var player_1 : Global.Ships = Global.Ships.NONE
@export var player_2 : Global.Ships = Global.Ships.NONE
@export var p1_label: PlayerNumber
@export var p2_label: PlayerNumber
@export var number_holder: MarginContainer
@export var camera: MultiTargetCamera
@export var tilemap: TileMapLayer
@export var base_map: String
@export var select_ui: CanvasLayer
@export var fade_panel: Panel
@export var color_overlay: ColorRect
@export var padding := 50 ##Size of frame around level
@export var fade_time := 1.0
@export var black_threshold := 0.4

var current_map: Image

var p1_spawns : Array[Vector2i]
var p2_spawns : Array[Vector2i]
var p3_spawns : Array[Vector2i]
var p4_spawns : Array[Vector2i]


func _ready() -> void:
	color_overlay.material.set_shader_parameter("color_factor", Global.base_color)

	if current_mode == Mode.NONE:
		pass
	elif Global.current_map != null and (current_mode == Mode.GAME or current_mode == Mode.TEST):
		current_map = Global.current_map.get_image()
		build(current_map)
		camera.global_position = current_map.get_size() * 32
	elif base_map:
		current_map = Global.maps[base_map].get_image()
		build(current_map)
		camera.global_position = current_map.get_size() * 32

	if current_mode == Mode.GAME or current_mode == Mode.TEST: game_spawn()
	elif current_mode == Mode.DEMO: demo_spawn()


func game_spawn() -> void:
	fade_panel.modulate = Color(1, 1, 1, 1)
	var fade_tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	fade_tween.tween_property(fade_panel, "modulate", Color(1, 1, 1, 0), fade_time)
	fade_tween.tween_callback(p1_label.show)
	fade_tween.tween_callback(p2_label.show)
	if player_1 == Global.Ships.NONE: player_1 = Global.p1_ship
	if player_2 == Global.Ships.NONE: player_2 = Global.p2_ship
	var p1 : Ship = Global.SHIP_SCENES[player_1].instantiate()
	p1.global_translate(p1_spawns[randi_range(0, p1_spawns.size() - 1)])
	p1.rotate(PI)
	add_child(p1)
	var p2 : Ship = Global.SHIP_SCENES[player_2].instantiate()
	p2.player_id = Ship.PlayerIDs.PLAYER_2
	p2.global_translate(p2_spawns[randi_range(0, p2_spawns.size() - 1)])
	if current_mode == Mode.TEST:
		var new_steering: SteeringComponent = STEERING.instantiate()
		p2.add_child(new_steering)
		new_steering.target = p2
		p2.steering = new_steering
		p2.demo = true
		p2.rotation = randf_range(0, TAU)
	add_child(p2)

	p1_label.ship = p1
	p2_label.ship = p2
	number_holder.show()

	var number_tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	#number_tween.tween_callback(number_holder.remove_theme_constant_override.bind("margin_left"))
	number_tween.tween_interval(5.0)
	number_tween.tween_method(change_margin.bind(number_holder, "margin_left"), 16, -128 * 10, 1.0)
	number_tween.parallel().tween_callback(p1_label.leave)
	number_tween.parallel().tween_callback(p2_label.leave)
	number_tween.tween_callback(p1_label.hide)
	number_tween.tween_callback(p2_label.hide)


func change_margin(amount: int, container: MarginContainer, which: String) -> void:
	container.add_theme_constant_override(which, amount)


func demo_spawn() -> void:
	var spawns := p1_spawns.duplicate()
	spawns.append_array(p2_spawns)
	spawns.append_array(p3_spawns)
	spawns.append_array(p4_spawns)

	for ship in Global.SHIP_SCENES:
		var new_ship: Ship = ship.instantiate()
		new_ship.input.free()
		var new_steering: SteeringComponent = STEERING.instantiate()
		new_ship.add_child(new_steering)
		new_steering.target = new_ship
		new_ship.steering = new_steering
		new_ship.demo = true
		add_child(new_ship)
		if spawns.size() <= 0:
			printerr("There are less spawnpoints than ships...")
			new_ship.global_translate(spawns[0])
		else:
			var rand := randi_range(0, spawns.size() - 1)
			new_ship.global_translate(spawns[rand])
			#spawns.remove_at(rand)
		new_ship.rotation = randf_range(0, TAU)

		select_ui.ships.append(new_ship)


func end_round():
	Global.pass_round()


func build(img: Image) -> void:
	if img.get_height() > 64 and img.get_width() > 64:
		#printerr("Map is too large! (> 64px in height or width)")
		#return
		img.resize(64, 64, Image.Interpolation.INTERPOLATE_NEAREST)
	elif img.get_height() > 64:
		img.resize(img.get_width(), 64, Image.Interpolation.INTERPOLATE_NEAREST)
	elif img.get_width() > 64:
		img.resize(64, img.get_height(), Image.Interpolation.INTERPOLATE_NEAREST)
	
	if Input.is_action_pressed("flip_horz"):
		img.flip_x()
	if Input.is_action_pressed("flip_vert"):
		img.flip_y()
	if Input.is_action_pressed("rotate_270"):
		img.rotate_180()
		img.rotate_90(COUNTERCLOCKWISE)
	elif Input.is_action_pressed("rotate_180"):
		img.rotate_180()
	elif Input.is_action_pressed("rotate_90"):
		img.rotate_90(COUNTERCLOCKWISE)
	
	var unplaced_pixels: Array[Vector2i]
	for x in img.get_width(): # check colors and place correct tile
		for y in img.get_height():
			var result = match_colors(img, Vector2i(x, y))
			if not result == Vector2i(-1, -1): unplaced_pixels.append(result)
	
	var corner_spawn := false
	if unplaced_pixels.size() > 0: #basically quantizing the image to fit the map palette
		for coords in unplaced_pixels:
			var pixel := img.get_pixelv(coords)
			var unplaced_vec := Vector3(pixel.r, pixel.g, pixel.b)
			if unplaced_vec.length() < black_threshold:
				img.set_pixelv(coords, Color8(0, 0, 0))
				match_colors(img, coords)
				continue
			var differences: Array[float] = []
			for color in VALID_COLORS:
				differences.append(cos(unplaced_vec.angle_to(color)))
			var biggest := [-1.0, 0]
			#var difference_index := 0
			for i in differences.size():
				if differences[i] > biggest[0]:
					biggest[0] = differences[i]
					biggest[1] = i
					#difference_index = i
			#for i in differences.size():
				#differences[i] = snappedf(differences[i], 0.1)
			#print(str(differences))
			#print("pixel at "+str(coords)+" of color "+str(pixel)+" had "+str(differences[difference_index])+" of difference with color "+str(VALID_COLORS[smallest[1]]))
			var vec_to_color := Color8(VALID_COLORS[biggest[1]].x,VALID_COLORS[biggest[1]].y,VALID_COLORS[biggest[1]].z)
			img.set_pixelv(coords, vec_to_color)
			match_colors(img, coords)
		#corner_spawn = true

	var rect := Rect2i(Vector2i(0, 0), Vector2i(img.get_width(), img.get_height()))
	for x in img.get_width() + padding * 2: # fill out empty space around map
		for y in img.get_height() + padding * 2:
			if not rect.has_point(Vector2i(x - padding, y - padding)):
				tilemap.set_cell(Vector2i(x - padding, y - padding), BASE_TILES_SOURCE_ID, BOUNCY_COORDS)
	
	if p1_spawns.size() == 0: p1_spawns.append(Vector2i(randi_range(0, img.get_width()*32), randi_range(0, img.get_height()*32)))
	if p2_spawns.size() == 0: p2_spawns.append(Vector2i(randi_range(0, img.get_width()*32), randi_range(0, img.get_height()*32)))
	if p3_spawns.size() == 0: p3_spawns.append(Vector2i(randi_range(0, img.get_width()*32), randi_range(0, img.get_height()*32)))
	if p4_spawns.size() == 0: p4_spawns.append(Vector2i(randi_range(0, img.get_width()*32), randi_range(0, img.get_height()*32)))
	
	if corner_spawn:
		p1_spawns = [Vector2i(32, 32)]
		p2_spawns = [Vector2i((img.get_width()*32)-32, (img.get_height()*32)-32)]
		p3_spawns = [Vector2i(32, (img.get_height()*32)-32)]
		p4_spawns = [Vector2i((img.get_width()*32)-32, 32)]

func match_colors(img: Image, coords: Vector2i) -> Vector2i:
	match img.get_pixelv(coords):
		Color8(255, 255, 255): #ffffff
			tilemap.set_cell(coords, BASE_TILES_SOURCE_ID, BOUNCY_COORDS)
		Color8(0, 0, 0): #000000
			pass
		Color8(0, 0, 0, 0): #000000 transparent
			pass
		Color8(255, 255, 255, 0): #ffffff transparent
			pass
		Color8(204, 255, 255): #ccffff
			tilemap.set_cell(coords, BASE_TILES_SOURCE_ID, ABSORBENT_COORDS)
		Color8(153, 255, 255): #99ffff
			tilemap.set_cell(coords, BASE_TILES_SOURCE_ID, SMOOTH_COORDS)
		Color8(255, 255, 85): #ffff55
			tilemap.set_cell(coords, BASE_TILES_SOURCE_ID, PLAYER_PASS_COORDS)
		Color8(255, 255, 204): #ffffcc
			tilemap.set_cell(coords, BASE_TILES_SOURCE_ID, PROJECTILE_PASS_COORDS)
		Color8(85, 85, 85): #555555
			tilemap.set_cell(coords, BASE_TILES_SOURCE_ID, BACKGROUND_COORDS)
		Color8(255, 0, 255): #ff00ff
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, DIAMOND_DISPENSER_ID)
		Color8(255, 85, 255): #ff55ff
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, CROSS_DISPENSER_ID)
		Color8(255, 204, 255): #ffccff
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, SQUARE_DISPENSER_ID)
		Color8(153, 0, 0): #990000
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, SPIKES_ID[0])
		Color8(153, 34, 34): #992222
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, SPIKES_ID[1])
		Color8(153, 68, 68): #994444
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, SPIKES_ID[2])
		Color8(153, 102, 102): #996666
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, SPIKES_ID[3])
		Color8(153, 153, 0): #999900
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, ONE_WAY_ID[0])
		Color8(153, 153, 34): #999922
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, ONE_WAY_ID[1])
		Color8(153, 153, 68): #999944
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, ONE_WAY_ID[2])
		Color8(153, 153, 102): #999966
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, ONE_WAY_ID[3])
		Color8(0, 153, 0): #009900
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, BOOST_PAD_ID[0])
		Color8(34, 153, 34): #229922
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, BOOST_PAD_ID[1])
		Color8(68, 153, 68): #449944
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, BOOST_PAD_ID[2])
		Color8(102, 153, 102): #669966
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, BOOST_PAD_ID[3])
		Color8(0, 0, 153): #000099
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, GRAVITY_WELL_ID[0])
		Color8(34, 34, 153): #222299
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, GRAVITY_WELL_ID[1])
		Color8(68, 68, 153): #444499
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, GRAVITY_WELL_ID[2])
		Color8(102, 102, 153): #666699
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, GRAVITY_WELL_ID[3])
		Color8(255, 85, 85): #ff5555
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, PINWHEEL_ID)
		Color8(0, 204, 0): #00cc00
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, BIG_CRATE_ID)
		Color8(0, 204, 34): #00cc22
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, BIG_BALL_ID)
		Color8(0, 204, 68): #00cc44
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, SMALL_CRATE_ID)
		Color8(0, 204, 102): #00cc66
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, SMALL_BALL_ID)
		Color8(0, 204, 136): #00cc88
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, SMALL_PLANK_ID)
		Color8(0, 204, 170): #00ccaa
			tilemap.set_cell(coords, SCENE_TILES_SOURCE_ID, NONE, SMALL_PILL_ID)
		Color8(0, 0, 255): #0000ff
			p1_spawns.append(coords * 32)
		Color8(255, 0, 0): #ff0000
			p2_spawns.append(coords * 32)
		Color8(0, 255, 0): #00ff00
			p3_spawns.append(coords * 32)
		Color8(255, 255, 0): #ffff00
			p4_spawns.append(coords * 32)
		_:
			return coords
	return Vector2i(-1, -1)
