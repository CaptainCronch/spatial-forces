extends Area2D
class_name HurtAreaComponent

signal hit(hitbox : HitboxComponent)

@export var collider : CollisionShape2D
@export var attack : Attack
@export var flash_speed := 0.1

var enabled = true
var flash_timer := 0.0


func _ready():
	if not collision_layer and not collision_mask:
		printerr("HitAreaComponent of ", get_parent().name, " has no collision bits enabled!")


func _physics_process(delta):
	if flash_speed > 0.0: # if has flash speed and time out then check collisions and restart timer
		flash_timer += delta
		if flash_timer >= flash_speed:
			flash_timer = 0.0
		else: return
	if not monitoring or not enabled: return
	for area in get_overlapping_areas():
		if area is HitboxComponent:
			if area.is_in_group("Player"):
				attack.attack_position = global_position
				attack.attack_direction = Vector2.RIGHT.rotated(global_rotation)
				hit.emit(area)
				area.damage(attack)
				break


func _on_area_entered(area: Area2D) -> void:
	if not enabled: return
	if area is HitboxComponent:
		if area.is_in_group("Player"):
			attack.attack_position = global_position
			attack.attack_direction = Vector2.RIGHT.rotated(global_rotation)
			hit.emit(area)
			area.damage(attack)
			flash_timer = 0.0
