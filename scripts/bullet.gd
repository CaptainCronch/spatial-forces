extends RigidBody2D

const SPARKS := preload("res://scenes/particles/sparks.tscn")

@export var attack : Attack
@export var hurtbox : Area2D
@export var spark_scale := 2.0


func _on_death_timeout() -> void:
	#spark()
	queue_free()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area is HitboxComponent:
		attack.attack_position = global_position
		attack.attack_direction = linear_velocity.normalized()
		area.damage(attack)
		#OS.delay_msec(1000)
	#spark()
	queue_free()


func spark() -> void:
	var sparks := SPARKS.instantiate()
	sparks.modulate = modulate
	sparks.emitting = true
	sparks.direction = Vector2.RIGHT.rotated(rotation)
	sparks.scale_amount_max = spark_scale
	sparks.scale_amount_min = spark_scale / 2
	sparks.initial_velocity_min += linear_velocity.length() / 100
	sparks.initial_velocity_max += linear_velocity.length() / 100
	get_tree().current_scene.add_child(sparks)
	sparks.global_position = global_position
