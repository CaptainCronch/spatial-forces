extends Area2D
class_name HitboxComponent

@export var health_comp : HealthComponent
@export var target : Node2D


func _ready():
	if not collision_layer and not collision_mask:
		printerr("HitboxComponent of ", get_parent().name, " has no collision bits enabled!")


func damage(attack : Attack):
	if health_comp: health_comp.damage(attack)
	if target is RigidBody2D:
		target.apply_central_impulse(
			attack.attack_direction * attack.knockback_force
		)
