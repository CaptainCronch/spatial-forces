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
const DIAMOND_DISPENSER_ID := -1
const CROSS_DISPENSER_ID := -1
const SQUARE_DISPENSER_ID := -1
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

const STEERING = preload("res://scenes/components/steering_component.tscn")

enum Mode {GAME, DEMO, NONE}

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
@export var padding := 50
@export var fade_time := 1.0

var current_map: Image

var p1_spawns : Array[Vector2i]
var p2_spawns : Array[Vector2i]
var p3_spawns : Array[Vector2i]
var p4_spawns : Array[Vector2i]


func _ready() -> void:
	color_overlay.material.set_shader_parameter("color_factor", Global.base_color)

	if current_mode == Mode.NONE:
		pass
	elif Global.current_map != null and current_mode == Mode.GAME:
		current_map = Global.current_map.get_image()
		build(current_map)
		camera.global_position = current_map.get_size() * 16
	elif base_map:
		current_map = Global.maps[base_map].get_image()
		build(current_map)
		camera.global_position = current_map.get_size() * 16

	if current_mode == Mode.GAME: game_spawn()
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
	if img.get_height() > 64 or img.get_width() > 64:
		printerr("Map is too large! (> 64px in height or width)")
		return

	for x in img.get_width(): # check colors and place correct tile
		for y in img.get_height():
			match img.get_pixelv(Vector2i(x, y)):
				Color8(255, 255, 255): #ffffff
					tilemap.set_cell(Vector2i(x, y), BASE_TILES_SOURCE_ID, BOUNCY_COORDS)
				Color8(0, 0, 0): #000000
					pass
				Color8(0, 0, 0, 0): #000000 transparent
					pass
				Color8(1, 1, 1, 0): #ffffff transparent
					pass
				Color8(204, 255, 255): #ccffff
					tilemap.set_cell(Vector2i(x, y), BASE_TILES_SOURCE_ID, ABSORBENT_COORDS)
				Color8(153, 255, 255): #99ffff
					tilemap.set_cell(Vector2i(x, y), BASE_TILES_SOURCE_ID, SMOOTH_COORDS)
				Color8(255, 255, 85): #ffff55
					tilemap.set_cell(Vector2i(x, y), BASE_TILES_SOURCE_ID, PLAYER_PASS_COORDS)
				Color8(255, 255, 204): #ffffcc
					tilemap.set_cell(Vector2i(x, y), BASE_TILES_SOURCE_ID, PROJECTILE_PASS_COORDS)
				Color8(85, 85, 85): #555555
					tilemap.set_cell(Vector2i(x, y), BASE_TILES_SOURCE_ID, BACKGROUND_COORDS)
				Color8(255, 0, 255): #ff00ff
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, DIAMOND_DISPENSER_ID)
				Color8(255, 85, 255): #ff55ff
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, CROSS_DISPENSER_ID)
				Color8(255, 204, 255): #ffccff
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, SQUARE_DISPENSER_ID)
				Color8(153, 0, 0): #990000
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, SPIKES_ID[0])
				Color8(153, 34, 34): #992222
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, SPIKES_ID[1])
				Color8(153, 68, 68): #994444
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, SPIKES_ID[2])
				Color8(153, 102, 102): #996666
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, SPIKES_ID[3])
				Color8(153, 153, 0): #999900
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, ONE_WAY_ID[0])
				Color8(153, 153, 34): #999922
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, ONE_WAY_ID[1])
				Color8(153, 153, 68): #999944
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, ONE_WAY_ID[2])
				Color8(153, 153, 102): #999966
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, ONE_WAY_ID[3])
				Color8(0, 153, 0): #009900
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, BOOST_PAD_ID[0])
				Color8(34, 153, 34): #229922
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, BOOST_PAD_ID[1])
				Color8(68, 153, 68): #449944
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, BOOST_PAD_ID[2])
				Color8(102, 153, 102): #669966
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, BOOST_PAD_ID[3])
				Color8(0, 0, 153): #000099
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, GRAVITY_WELL_ID[0])
				Color8(34, 34, 153): #222299
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, GRAVITY_WELL_ID[1])
				Color8(68, 68, 153): #444499
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, GRAVITY_WELL_ID[2])
				Color8(102, 102, 153): #666699
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, GRAVITY_WELL_ID[3])
				Color8(255, 85, 85): #ff5555
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, PINWHEEL_ID)
				Color8(0, 204, 0): #00cc00
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, BIG_CRATE_ID)
				Color8(0, 204, 34): #00cc22
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, BIG_BALL_ID)
				Color8(0, 204, 68): #00cc44
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, SMALL_CRATE_ID)
				Color8(0, 204, 102): #00cc66
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, SMALL_BALL_ID)
				Color8(0, 204, 136): #00cc88
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, SMALL_PLANK_ID)
				Color8(0, 204, 170): #00ccaa
					tilemap.set_cell(Vector2i(x, y), SCENE_TILES_SOURCE_ID, NONE, SMALL_PILL_ID)
				Color8(0, 0, 255): #0000ff
					p1_spawns.append(Vector2i(x, y) * 32)
				Color8(255, 0, 0): #ff0000
					p2_spawns.append(Vector2i(x, y) * 32)
				Color8(0, 255, 0): #00ff00
					p3_spawns.append(Vector2i(x, y) * 32)
				Color8(255, 255, 0): #ffff00
					p4_spawns.append(Vector2i(x, y) * 32)

	var rect := Rect2i(Vector2i(0, 0), Vector2i(img.get_width(), img.get_height()))
	for x in img.get_width() + padding * 2: # fill out empty space around map
		for y in img.get_height() + padding * 2:
			if not rect.has_point(Vector2i(x - padding, y - padding)):
				tilemap.set_cell(Vector2i(x - padding, y - padding), BASE_TILES_SOURCE_ID, BOUNCY_COORDS)
