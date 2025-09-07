class_name FocusSelector
extends Node2D

@export var player : PLAYER_NUMBER = 0
@export var desired_spin_speed := 0.785
@export var spin_decay := 15.0
@export var subline_factor := 0.25

@export var line : Line2D
@export var subline : Line2D

@export var p1_label : Label
@export var p2_label : Label
@export var p3_label : Label
@export var p4_label : Label

var spin_speed := 0.0

enum PLAYER_NUMBER {
	P1,
	P2,
	P3,
	P4,
}


func _ready() -> void:
	var labels := [p1_label, p2_label, p3_label, p4_label]
	labels[player].show()
	#var color := Global.base_color
	#(material as ShaderMaterial).set_shader_parameter("color_factor", color)


func _process(delta: float) -> void:
	spin_speed = Global.decay_towards(spin_speed, desired_spin_speed, spin_decay)

	line.rotate(spin_speed * delta)
	subline.rotate(-spin_speed * subline_factor * delta)
