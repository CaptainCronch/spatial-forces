extends Node

const LEVEL := preload("res://scenes/level.tscn")
const SELECT := preload("res://scenes/select.tscn")

enum Ships {KELU, ESKI, KLOD, ARIS, APIV, OKLA, UVIX, IGRO, PLAK, NONE}
const SHIP_SCENES: Array[PackedScene] = [
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/klod.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/okla.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
]
const SHIP_INFO: Array[Dictionary] = [
	{
		"title": "Kelu",
		"subtitle": "Aggressive Acceleration",
		"max": 128,
		"acc": 128,
		"nrg": 100,
		"clp": 4,
		"passive": "More acceleration when near enemy",
		"primary": "Triple stars",
		"secondary": "More max speed",
		"sprite": preload("res://assets/ships/kelu.png")
	},
	{
		"title": "Kelu",
		"subtitle": "Aggressive Acceleration",
		"max": 128,
		"acc": 128,
		"nrg": 100,
		"clp": 4,
		"passive": "More acceleration when near enemy",
		"primary": "Triple stars",
		"secondary": "More max speed",
		"sprite": preload("res://assets/ships/kelu.png")
	},
	{
		"title": "Klod",
		"subtitle": "Deflect and Reflect",
		"max": 96,
		"acc": 186,
		"nrg": 120,
		"clp": 3,
		"passive": "Weaponized weight",
		"primary": "Impulse punch",
		"secondary": "Stasis reflect",
		"sprite": preload("res://assets/ships/klod.png")
	},
	{
		"title": "Kelu",
		"subtitle": "Aggressive Acceleration",
		"max": 128,
		"acc": 128,
		"nrg": 100,
		"clp": 4,
		"passive": "More acceleration when near enemy",
		"primary": "Triple stars",
		"secondary": "More max speed",
		"sprite": preload("res://assets/ships/kelu.png")
	},
	{
		"title": "Kelu",
		"subtitle": "Aggressive Acceleration",
		"max": 128,
		"acc": 128,
		"nrg": 100,
		"clp": 4,
		"passive": "More acceleration when near enemy",
		"primary": "Triple stars",
		"secondary": "More max speed",
		"sprite": preload("res://assets/ships/kelu.png")
	},
	{
		"title": "Okla",
		"subtitle": "Rotational Skillshots",
		"max": 256,
		"acc": 32,
		"nrg": 80,
		"clp": 3,
		"passive": "Stronger when spinning",
		"primary": "Burstgun",
		"secondary": "Cannon",
		"sprite": preload("res://assets/ships/okla.png")
	},
	{
		"title": "Kelu",
		"subtitle": "Aggressive Acceleration",
		"max": 128,
		"acc": 128,
		"nrg": 100,
		"clp": 4,
		"passive": "More acceleration when near enemy",
		"primary": "Triple stars",
		"secondary": "More max speed",
		"sprite": preload("res://assets/ships/kelu.png")
	},
	{
		"title": "Kelu",
		"subtitle": "Aggressive Acceleration",
		"max": 128,
		"acc": 128,
		"nrg": 100,
		"clp": 4,
		"passive": "More acceleration when near enemy",
		"primary": "Triple stars",
		"secondary": "More max speed",
		"sprite": preload("res://assets/ships/kelu.png")
	},
	{
		"title": "Kelu",
		"subtitle": "Aggressive Acceleration",
		"max": 128,
		"acc": 128,
		"nrg": 100,
		"clp": 4,
		"passive": "More acceleration when near enemy",
		"primary": "Triple stars",
		"secondary": "More max speed",
		"sprite": preload("res://assets/ships/kelu.png")
	},
]

const USER_MAPS_PATH := "user://maps"
const INTERNAL_MAPS := {
	"tst_corners.png": preload("res://assets/maps/tst_corners.png"),
	"sel_original.png": preload("res://assets/maps/sel_original.png"),
}
const OG_MAPS := {
	"dm2_cycle_3.png": preload("res://assets/maps/dm2_cycle_3.png"),
}

var user_maps := {}
var maps := {}

var base_color := Color(1.0, 0.85, 0.66)
var p1_ship := Ships.KELU
var p2_ship := Ships.KELU
var current_map: Texture2D


func _enter_tree() -> void:
	maps = OG_MAPS.duplicate()
	maps.merge(INTERNAL_MAPS)
	load_user_maps()
	#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	#Engine.max_fps = 60
	#Input.use_accumulated_input = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#get_window().mode = Window.MODE_FULLSCREEN


func _process(_delta) -> void:
	#if Input.is_action_just_pressed("debug_key"):
		#if Engine.max_fps == 60:
			#Engine.max_fps = 0
		#elif Engine.max_fps == 0:
			#Engine.max_fps = 60

	#if Input.is_action_just_pressed("back"):
		#get_tree().quit() # temporary for testing

	if Input.is_action_just_pressed("fullscreen"):
		if get_window().mode != Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED


func load_user_maps() -> void:
	user_maps.clear()
	var dir := DirAccess.open("user://")

	if not dir.dir_exists(USER_MAPS_PATH):
		dir.make_dir(USER_MAPS_PATH)
	dir.change_dir(USER_MAPS_PATH)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				user_maps[file_name] = Image.load_from_file(file_name)
			file_name = dir.get_next()
	else:
		push_error("Could not access the user map path for some reason...")

	maps.merge(user_maps, true)


#func mouse_switch(pos := Vector2(0, 0)) -> void :
	#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#get_window().warp_mouse(pos)
	#elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func decay_towards(value : float, target : float,
			decay_power : float, delta : float = get_process_delta_time(),
			round_threshold : float = 0.0) -> float:

	var new_value := (value - target) * pow(2, -delta * decay_power) + target

	if absf(new_value - target) < round_threshold:
		return target
	else:
		return new_value


func decay_vec2_towards(value : Vector2, target : Vector2,
			decay_power : float, delta : float = get_process_delta_time(),
			round_threshold : float = 0.0) -> Vector2:

	var new_value := (value - target) * pow(2, -delta * decay_power) + target

	if (new_value - target).abs().length() < round_threshold:
		return target
	else:
		return new_value


func decay_angle_towards(value : float, target : float,
			decay_power : float, delta : float = get_process_delta_time(),
			round_threshold : float = 0.0) -> float:

	var new_value := angle_difference(target, value) * pow(2, -delta * decay_power) + target

	if absf(angle_difference(target, new_value)) < round_threshold:
		return target
	else:
		return new_value
