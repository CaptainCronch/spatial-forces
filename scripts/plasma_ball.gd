extends Bullet
class_name PlasmaBall

@export var resolution := 32
@export var min_size := 2.0
@export var max_size := 10.0
@export var collider_margin := 0.25 ##The difference between the environment collider and the hurtbox collider to the bullet's visuals.
@export var hold_multiplier := 2.0 ##Bonus while charging bullet.
@export var speed_size_factor := 100.0 ##This multiplied by the bullet's relative size is added to the speed.
@export var damage_size_factor := 19.0 ##This multiplied by the bullet's relative size is added to the damage.
@export var knockback_size_factor := 70.0 ##This multiplied by the bullet's relative size is added to the knockback.
@export var base_damage := 1.0
@export var base_knockback := 10.0

@export var polygon: Polygon2D
@export var collider: CollisionShape2D
@export var hurtbox_collider: CollisionShape2D

var shot := false
var size := min_size


func _ready() -> void:
	increase_size(0.0)
	#because we have started holding the bullet
	#linear_velocity = Vector2.RIGHT.rotated(rotation) * speed
	#sprite.global_position = global_position
	#death_timer.start(death_time + randf_range(-death_time/5, death_time/5))


func generate_circle_polygon(radius: float, num_sides: int) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var points: PackedVector2Array

	for _i in num_sides:
		points.append(vector)
		vector = vector.rotated(angle_delta)

	return points


func increase_size(amount: float) -> void:
	size = minf(size + amount, max_size)
	polygon.polygon = generate_circle_polygon(size, resolution)
	(collider.shape as CircleShape2D).radius = size * (1 - collider_margin)
	(hurtbox_collider.shape as CircleShape2D).radius = size * (1 + collider_margin)
	var size_multiplier := inverse_lerp(min_size, max_size, size)
	attack.attack_damage = base_damage + (size_multiplier * damage_size_factor)
	attack.knockback_force = base_knockback + (size_multiplier * knockback_size_factor)


func shoot() -> void:
	shot = true
	death_timer.start(death_time + randf_range(-death_time/5, death_time/5))
	var size_multiplier := inverse_lerp(min_size, max_size, size)
	linear_velocity = Vector2.RIGHT.rotated(rotation) * (speed + (size_multiplier * speed_size_factor))


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not shot:
		attack.attack_damage *= hold_multiplier
		attack.knockback_force *= hold_multiplier
	super(area)
