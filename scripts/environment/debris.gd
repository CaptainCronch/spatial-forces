extends RigidBody2D

@export var spawn_speed := 50.0
@export var spawn_rotation := PI


func _ready() -> void:
	linear_velocity += Vector2(randfn(0, spawn_speed), randfn(0, spawn_speed))
	angular_velocity += randfn(0, spawn_rotation)
