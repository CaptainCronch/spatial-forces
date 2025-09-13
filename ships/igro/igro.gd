extends Ship

const BULLET := preload("res://projectiles/igro/igro_bullet.tscn")

@export var clip_component: ClipComponent


func primary():
	#TODO: make it so that you reload when the last projectile exploded + a delay.
	#TODO: make it so that the longer you hold (up to the projectile's default lifetime) the lower the projectile lifetime gets
	#TODO: make it so that charging a shot moves the ammo bar from full to empty
	pass


func primary_release():
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: return
	clip_component.use(1)

	var bullet_instance : RigidBody2D
	bullet_instance = BULLET.instantiate()
	bullet_instance.position = clip_component.get_global_position()
	bullet_instance.sprite.global_position = clip_component.get_global_position()
	bullet_instance.rotation = rotation
	bullet_instance.player_id = player_id
	#bullet_instance.apply_central_impulse(Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().current_scene.call_deferred("add_child", bullet_instance)

	set_projectile_player(bullet_instance)
