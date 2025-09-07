extends Ship

const PLASMA_BALL = preload("res://scenes/projectiles/plasma_ball.tscn")

@export var clip_comp: ClipComponent


func primary() -> void:
	if clip_comp.clip <= 0 or not clip_comp.can_fire or block_tiles: return
	clip_comp.use(1)

	var bullet_instance: Bullet = PLASMA_BALL.instantiate()
	bullet_instance.position = clip_comp.get_global_position()
	bullet_instance.sprite.global_position = clip_comp.get_global_position()
	bullet_instance.rotation = rotation
	#bullet_instance.apply_central_impulse(Vector2(bullet_speed, 0).rotated(bullet_instance.rotation))
	get_tree().current_scene.call_deferred("add_child", bullet_instance)

	set_projectile_player(bullet_instance)
