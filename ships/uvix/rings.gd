extends CPUParticles2D

@export var death_time := 10.0

var target: Ship


func _ready() -> void:
	await get_tree().create_timer(death_time).timeout
	queue_free()
