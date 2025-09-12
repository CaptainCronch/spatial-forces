extends Area2D

@export var attack: Attack


func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		attack.attack_position = global_position
		attack.attack_direction = Vector2.RIGHT.rotated(rotation)
		area.damage(attack)
