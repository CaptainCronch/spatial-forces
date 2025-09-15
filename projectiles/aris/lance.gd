extends HurtAreaComponent

@export var polygon: Polygon2D
@export var reflection_strength := 400.0

var reflect_mode := false


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and reflect_mode:
		body.linear_velocity = Vector2.RIGHT.rotated(global_rotation) * reflection_strength
