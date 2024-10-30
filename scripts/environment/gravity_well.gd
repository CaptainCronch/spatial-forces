extends Area2D

@onready var particles : CPUParticles2D = $CPUParticles2D


func _ready() -> void:
	particles.lifetime += randf_range(0.0, 0.2)
