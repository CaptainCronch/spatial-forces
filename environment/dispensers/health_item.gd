extends "res://environment/dispensers/speed_item.gd"


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ship:
		body.get_node("HealthComponent").heal(power)
		collected.emit()
		particulate(SPARKS, spark_settings)
		queue_free()
