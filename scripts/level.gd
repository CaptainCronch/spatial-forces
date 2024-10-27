extends Node2D

enum Ships {KELU, ESKI, KLOD, ARIS, APIV, OKLA, UVIX, IGRO, PLAK}
const SHIP_SCENES: Array[PackedScene] = [
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/okla.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
	preload("res://scenes/ships/kelu.tscn"),
]

@export var player_1: Ships
@export var player_1_color: Types.Colors = Types.Colors.BLUE
@export var player_2 : Ships
@export var player_2_color: Types.Colors = Types.Colors.RED
@export var camera: MultiTargetCamera


func _ready() -> void:
	var p1 : Ship = SHIP_SCENES[player_1].instantiate()
	p1.player_color = player_1_color
	p1.position = Vector2(128, 0)
	p1.rotate(PI)
	add_child(p1)
	var p2 : Ship = SHIP_SCENES[player_2].instantiate()
	p2.player_color = player_2_color
	p2.player_id = 1
	p1.position = Vector2(-128, 0)
	add_child(p2)
