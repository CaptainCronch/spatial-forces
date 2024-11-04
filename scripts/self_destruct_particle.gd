extends CPUParticles2D

@export var target: Node2D


func _process(_delta: float) -> void:
	if target: global_position = target.global_position


func _on_finished() -> void:
	queue_free()
