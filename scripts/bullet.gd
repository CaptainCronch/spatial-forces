extends RigidBody2D

const SPARKS := preload("res://scenes/particles/sparks.tscn")

@export var attack: Attack
@export var hurtbox: Area2D
@export var sprite: Sprite2D
@export var death_timer: Timer
@export var spark_scale := 2.0
@export var death_time := 1.5
@export var speed := 400.0


func _ready() -> void:
	linear_velocity = Vector2.RIGHT.rotated(rotation) * speed
	sprite.modulate = modulate
	sprite.global_position = global_position
	death_timer.start(death_time + randf_range(-death_time/5, death_time/5))


func _process(_delta: float) -> void:
	sprite.global_position = global_position


func _physics_process(_delta: float) -> void:
	sprite.rotation = linear_velocity.angle()


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
