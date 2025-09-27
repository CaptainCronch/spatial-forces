extends Bullet

const EXPLOSION := preload("uid://dsmm6h66s0rvn")

var player_id: Ship.PlayerIDs
var previous_hits: Array[Ship] = []


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area is HitboxComponent:
		attack.attack_position = global_position
		if linear_velocity.length_squared() != 0.0:
			attack.attack_direction = linear_velocity.normalized()
		else:
			attack.attack_direction = Vector2.RIGHT.rotated(rotation)
		previous_hits.append(area.target)
		area.damage(attack)


func _on_death_timeout() -> void:
	var explosion_instance : Area2D
	explosion_instance = EXPLOSION.instantiate()
	explosion_instance.global_position = get_global_position()
	explosion_instance.rotation = rotation
	explosion_instance.previous_hits = previous_hits
	explosion_instance.ship = ship
	get_tree().current_scene.call_deferred("add_child", explosion_instance)

	if player_id == Ship.PlayerIDs.PLAYER_2:
		explosion_instance.set_collision_layer_value(2, false)
		explosion_instance.set_collision_layer_value(3, true)
		explosion_instance.set_collision_mask_value(2, true)
		explosion_instance.set_collision_mask_value(3, false)
		explosion_instance.remove_from_group("Player1")
		explosion_instance.add_to_group("Player2")
	queue_free()
