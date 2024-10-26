extends TextureProgressBar
class_name Meter

@export var vis_delay := 1.0

var is_ready := false

@onready var timer : Timer = $Timer


func _ready() -> void:
	hide()
	is_ready = true


func _on_timer_timeout() -> void:
	hide()


func _on_value_changed(_value: float) -> void:
	show()
	if is_ready: timer.start(vis_delay)
