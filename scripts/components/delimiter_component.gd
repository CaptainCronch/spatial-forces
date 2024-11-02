extends Node2D
class_name DelimiterComponent

@export var target: Ship
@export var line: Line2D
@export var text_holder: Node2D
@export var label: Label
@export var fidelity := 48
@export var radius := 32.0
@export var fraction := 8


func _ready() -> void:
	make_arc()


func _process(_delta: float) -> void:
	#global_position = target.global_position
	label.global_position = text_holder.global_position - (label.size/2)


func make_arc() -> void:
	var temp_points: PackedVector2Array = []
	for i in range(fidelity):
		if i > fidelity / fraction: continue
		var angle: float = float(i) * TAU / fidelity
		var factor := 1.1 if i == fidelity / (fraction*2) else 1.0
		var x: float = cos(angle) * radius * factor
		var y: float = sin(angle) * radius * factor
		temp_points.append(Vector2(x, y).rotated(-TAU/(fraction*2)))
	line.points = temp_points
