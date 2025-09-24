extends Node

const LEVEL := preload("uid://b2i211avmpf4e")
const SELECT := preload("uid://clovy12w6brxj")

enum Ships {KELU, ESKI, KLOD, ARIS, APIV, OKLA, UVIX, IGRO, PLAK, NONE}
const SHIP_SCENES: Array[PackedScene] = [
	preload("uid://vu6eebm6ech"), #kelu
	preload("uid://0238oq2l73lm"), #eski
	preload("uid://cadc7ajjrypd3"), #klod
	preload("uid://cqqfpihgkt1wr"), #aris
	preload("uid://blaxqtocj6y1y"), #apiv
	preload("uid://cydy5qjuigfp3"), #okla
	preload("uid://vu6eebm6ech"), #kelu ~
	preload("uid://bewmw7u4yhoju"), #igro
	preload("uid://neahjxl7621p"), #plak
]
const SHIP_INFO: Array[Dictionary] = [
	{
		"title": "Kelu",
		"subtitle": "Aggressive Acceleration",
		"max": 128,
		"acc": 128,
		"nrg": 80,
		"clp": 4,
		"passive": "More acceleration when near enemy",
		"primary": "Triple stars",
		"secondary": "More max speed",
		"sprite": preload("uid://bw870adibwubn")
	},
	{
		"title": "Eski",
		"subtitle": "Bullet Heaven",
		"max": 80,
		"acc": 64,
		"nrg": 110,
		"clp": 0,
		"passive": "Low bullets bonus",
		"primary": "Spitter",
		"secondary": "Hook",
		"sprite": preload("uid://cv6cge1r1471o")
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
		"sprite": preload("uid://cd8j4f10lxhvb")
	},
	{
		"title": "Aris",
		"subtitle": "Joust Lance",
		"max": 128,
		"acc": 128,
		"nrg": 80,
		"clp": 2,
		"passive": "Boost off of walls",
		"primary": "Thrust forward",
		"secondary": "Reflect projectiles",
		"sprite": preload("uid://kw7yo31ujqgl")
	},
	{
		"title": "Apiv",
		"subtitle": "Charge Shift",
		"max": 170,
		"acc": 100,
		"nrg": 90,
		"clp": 0,
		"passive": "Boost while charging",
		"primary": "Charge plasma ball",
		"secondary": "Shift momentum counterclockwise",
		"sprite": preload("uid://daytpdegbvc55")
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
		"sprite": preload("uid://b4aj43mwsjri8")
	},
	{
		"title": "Kelu",
		"subtitle": "Aggressive Acceleration",
		"max": 128,
		"acc": 128,
		"nrg": 80,
		"clp": 4,
		"passive": "More acceleration when near enemy",
		"primary": "Triple stars",
		"secondary": "More max speed",
		"sprite": preload("uid://bw870adibwubn")
	},
	{
		"title": "Igro",
		"subtitle": "Precise Explosives",
		"max": 140,
		"acc": 48,
		"nrg": 90,
		"clp": 1,
		"passive": "More damage on double hit",
		"primary": "Impact ordinance",
		"secondary": "Brake",
		"sprite": preload("uid://crx7tc8lm6202")
	},
	{
		"title": "Plak",
		"subtitle": "Beam Strike",
		"max": 94,
		"acc": 76,
		"nrg": 100,
		"clp": 0,
		"passive": "Recharge on hit",
		"primary": "Laser tunnel",
		"secondary": "Evade",
		"sprite": preload("uid://bomre3wkxr5tb")
	},
]

const USER_MAPS_PATH := "user://maps"
const INTERNAL_MAPS := {
	"tst_corners.png": preload("uid://bift0vsgonrot"),
	"sel_original.png": preload("uid://q7e1savtg7ga"),
}
const OG_MAPS := {
	"dm2_cycle_2.png": preload("uid://oydpl4apkhsb"),
	"dm2_cramped_3.png": preload("uid://c4ve4lnrxwqe6"),
}

var user_maps := {}
var maps := {}

var base_color := Color(1.0, 0.85, 0.66)
var p1_ship := Ships.KELU
var p2_ship := Ships.KELU
var current_map: Texture2D
var rounds := 1


func _enter_tree() -> void:
	if rounds == 0:
		current_map = null
		get_tree().change_scene_to_file("res://levels/start.tscn")
	maps = OG_MAPS.duplicate()
	maps.merge(INTERNAL_MAPS)
	load_user_maps()
	#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var rand := randi_range(1, 4)
	if rand == 1: Engine.max_fps = 240
	elif rand == 2: Engine.max_fps = 120
	elif rand == 3: Engine.max_fps = 60
	elif rand == 4: Engine.max_fps = 30
	#Input.use_accumulated_input = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#get_window().mode = Window.MODE_FULLSCREEN


func _process(_delta) -> void:
	#if Input.is_action_just_pressed("debug_key"):
		#if Engine.max_fps == 60:
			#Engine.max_fps = 0
		#elif Engine.max_fps == 0:
			#Engine.max_fps = 60

	if Input.is_action_just_pressed("back"):
		get_tree().quit() # temporary for testing

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
				user_maps[file_name] = ImageTexture.create_from_image(Image.load_from_file(USER_MAPS_PATH+"/"+file_name))
			file_name = dir.get_next()
	else:
		push_error("Could not access the user map path for some reason...")

	maps.merge(user_maps, true)


func pass_round():
	rounds -= 1
	if rounds <= 0:
		current_map = null
		rounds = 1
		get_tree().change_scene_to_file("res://levels/start.tscn")
	else:
		get_tree().reload_current_scene()


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
