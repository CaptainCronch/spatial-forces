extends CanvasLayer

@export var outside: Control
@export var top_left: Control
@export var top_right: Control
@export var bottom_left: Control
@export var bottom_right: Control
@export var ship_select_p1: VBoxContainer
@export var ship_select_p2: VBoxContainer


func _ready() -> void:
	ship_select_p1.global_position = outside.global_position
	ship_select_p2.global_position = outside.global_position
	ship_select_p1.global_position = top_left.global_position
