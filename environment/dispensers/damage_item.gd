extends "res://environment/dispensers/speed_item.gd"

@export var duration := 5.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ship:
		body.powerup(power, duration)
		collected.emit()
		particulate(SPARKS, spark_settings)
		queue_free()
