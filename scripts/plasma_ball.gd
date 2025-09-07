extends Bullet

@export var start_size := 8
@export var resolution := 32
@export var max_multiplier := 4.0

@export var polygon: Polygon2D

var multiplier := 1.0


func _ready() -> void:
	polygon.polygon = generate_circle_polygon(start_size * multiplier, resolution)
	#linear_velocity = Vector2.RIGHT.rotated(rotation) * speed
	sprite.global_position = global_position
	death_timer.start(death_time + randf_range(-death_time/5, death_time/5))


func generate_circle_polygon(radius: float, num_sides: int) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array

	for _i in num_sides:
		polygon.append(vector)
		vector = vector.rotated(angle_delta)

	return polygon
