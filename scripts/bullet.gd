extends RigidBody2D

@export var attack : Attack
@export var hurtbox : Area2D


func _on_death_timeout() -> void:
	queue_free()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area is HitboxComponent:
		attack.attack_position = global_position
		attack.attack_direction = linear_velocity.normalized()
		area.damage(attack)
		#OS.delay_msec(1000)
	queue_free()
