extends Node2D

const KELU := preload("res://scenes/ships/kelu.tscn")

@export var camera : MultiTargetCamera


func _ready() -> void:
	var p1 : Node2D = KELU.instantiate()
	add_child(p1)
	var p2 : Node2D = KELU.instantiate()
	p2.player_id = 1
	p2.player_color = p2.PlayerColors.RED
	add_child(p2)
