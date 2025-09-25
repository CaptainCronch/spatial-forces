extends Bullet

@export var stack_multiplier := 2.0


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area is HitboxComponent and not disabled:
		attack.attack_position = global_position
		if linear_velocity.length_squared() != 0.0:
			attack.attack_direction = linear_velocity.normalized()
		else:
			attack.attack_direction = Vector2.RIGHT.rotated(rotation)
		
		var stacks := 0
		for child in area.get_parent().get_children():
			if child.is_in_group("Rings"):
				stacks += 1
				child.queue_free()
		attack.attack_damage *= maxf(1.0, stacks * stack_multiplier)
		attack.knockback_force *= maxf(1.0, stacks * stack_multiplier)
		area.damage(attack)
		hit.emit(global_position)
		#OS.delay_msec(100)
	#spark()
	if not area.is_in_group("Projectile"): queue_free()
