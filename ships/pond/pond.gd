extends Ship

const BULLET := preload("uid://c8cf6rfveqg4g")

@export var clip_component: ClipComponent
@export var brake_bar: TextureProgressBar
@export var charge_time := 1.0
@export var brake_damp := 2.0

var charge_timer := charge_time
var charging := false


func primary() -> void:
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: return
	charging = true


func primary_hold() -> void:
	if not charging: return
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: return
	
	charge_timer -= get_process_delta_time()
	clip_component.clip_bar.value = charge_timer #this is ok because the component only updates the bar when the ammo changes and we only change the ammo when we shoot the projectile
	if charge_timer <= 0.0:
		charge_timer = 0.01
		primary_release()
	pass


func primary_release() -> void:
	if not charging: return
	charging = false
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: return
	clip_component.use(1, 1, -(1 - charge_timer))
	
	var bullet_instance : Bullet
	bullet_instance = BULLET.instantiate()
	bullet_instance.position = clip_component.get_global_position()
	bullet_instance.sprite.global_position = clip_component.get_global_position()
	bullet_instance.rotation = rotation
	bullet_instance.player_id = player_id
	bullet_instance.death_time = maxf(charge_timer, 0.0)
	bullet_instance.origin = clip_component
	bullet_instance.ship = self
	charge_timer = charge_time
	#bullet_instance.apply_central_impulse(Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().current_scene.call_deferred("add_child", bullet_instance)

	set_projectile_player(bullet_instance)


func secondary() -> void:
	linear_damp = brake_damp
	brake_bar.show()


func secondary_release() -> void:
	linear_damp = 0.0
	brake_bar.hide()
