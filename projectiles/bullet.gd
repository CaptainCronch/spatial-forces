extends RigidBody2D
class_name Bullet

const SPARKS := preload("uid://bvv4udo8hfkun")

@export var attack: Attack
@export var hurtbox: Area2D
@export var sprite: Node2D
@export var death_timer: Timer
@export var spark_scale := 2.0
@export var death_time := 1.5
@export var speed := 400.0
@export var lifetime_randomness := 0.2

var disabled := false


func _ready() -> void:
	linear_velocity = Vector2.RIGHT.rotated(rotation) * speed
	sprite.global_position = global_position
	death_timer.start(death_time + randf_range(-lifetime_randomness, lifetime_randomness))


func _process(_delta: float) -> void:
	sprite.global_position = global_position


func _physics_process(_delta: float) -> void:
	sprite.rotation = linear_velocity.angle()


func _on_death_timeout() -> void:
	#spark()
	queue_free()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area is HitboxComponent and not disabled:
		attack.attack_position = global_position
		if linear_velocity.length_squared() != 0.0:
			attack.attack_direction = linear_velocity.normalized()
		else:
			attack.attack_direction = Vector2.RIGHT.rotated(rotation)
		area.damage(attack)
		#OS.delay_msec(100)
	#spark()
	if not area.is_in_group("Projectile"): queue_free()


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
