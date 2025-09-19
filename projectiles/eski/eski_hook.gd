extends Bullet


func _on_hurtbox_area_entered(area: Area2D) -> void:
	super(area)
	if disabled: return
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and body is Ship and not disabled:
		attack.attack_position = global_position
		if linear_velocity.length_squared() != 0.0:
			attack.attack_direction = linear_velocity.normalized()
		else:
			attack.attack_direction = Vector2.RIGHT.rotated(rotation)
		body.hitbox.damage(attack)
	hit.emit(global_position)
	if disabled: return
	disabled = true
	queue_free()
