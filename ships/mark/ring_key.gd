extends Bullet

const RINGS = preload("uid://dljn2fgomcayr")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area is HitboxComponent and not disabled:
		attack.attack_position = global_position
		if linear_velocity.length_squared() != 0.0:
			attack.attack_direction = linear_velocity.normalized()
		else:
			attack.attack_direction = Vector2.RIGHT.rotated(rotation)
		area.damage(attack)
		hit.emit(global_position)
		area.get_parent().add_child(RINGS.instantiate())
		#OS.delay_msec(100)
	#spark()
	if not area.is_in_group("Projectile"): queue_free()
