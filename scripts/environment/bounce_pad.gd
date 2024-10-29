extends Area2D

@export var bounce_force := 512.0


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.apply_central_impulse(Vector2.RIGHT.rotated(rotation) * bounce_force)
