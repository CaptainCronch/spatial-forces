extends Ship

const BULLET := preload("uid://dgop8vuj76xwn")
const SLUG := preload("uid://dat4gc7q4lckn")

@export var slugger_bar: Meter
@export var engine: CPUParticles2D
@export var clip_component: ClipComponent

@export var bullet_amount := 7
@export var bullet_angle_variance := deg_to_rad(15.0)
@export var centrifuge_factor := 1
@export var fire_knockback := 24.0
@export var slug_charge_time := 0.5
#@export var bullet_position_variance := 5.0

var emit_scale := 1.0
var slugging := false
var slug_charging := false
var slug_charge_timer := 0.0
var rot_factor := 0.0


func _ready() -> void:
	super()
	#slugger_bar.max_value = slug_charge_time
	#slugger_bar.value = slug_charge_timer
	if demo:
		emit_scale = 0.2
		engine.lifetime = 0.4
		engine.amount = 20


func _process(delta: float) -> void:
	super(delta)
	slugger(delta)
	set_engine()


func _physics_process(delta) -> void:
	super(delta)
	rot_factor = 1/((inverse_lerp(0, 10, absf(angular_velocity)) + 0.5) * 3) # spin faster to shoot tighter cones


func secondary():
	if slug_charge_timer >= slug_charge_time:
		if not slugging:
			slugging = true
			slugger_bar.show()
		else:
			slugging = false
			slugger_bar.hide()


func slugger(delta: float) -> void:
	if slug_charging and slug_charge_timer < slug_charge_time:
		slug_charge_timer += delta
		slugger_bar.value = slug_charge_timer


func set_engine() -> void:
	engine.speed_scale = 0
	#if move_dir.x > 0:
	engine.speed_scale += emit_scale
	engine.speed_scale *= 5/rot_factor


func primary() -> void:
	if clip_component.clip <= 0 or not clip_component.can_fire or block_tiles: return
	if slugging:
		slug()
		return
	clip_component.use(1)

	
	var bullet_instance: Bullet
	for i in bullet_amount:
		bullet_instance = BULLET.instantiate()
		bullet_instance.position = clip_component.get_global_position()
		bullet_instance.sprite.global_position = clip_component.get_global_position()
		var rand := randfn(0, bullet_angle_variance * rot_factor)
		bullet_instance.rotation = rotation + rand
		bullet_instance.origin = self
		#bullet_instance.apply_central_impulse(Vector2(bullet_speed, 0).rotated(bullet_instance.rotation))
		get_tree().current_scene.call_deferred("add_child", bullet_instance)

		set_projectile_player(bullet_instance)

	apply_central_impulse(Vector2.LEFT.rotated(rotation) * fire_knockback * (1/rot_factor))


func slug() -> void:
	clip_component.use(1, 2.0)
	var bullet_instance: Bullet
	bullet_instance = SLUG.instantiate()
	#var pos_var := absf(randfn(0, bullet_position_variance * mult))
	bullet_instance.position = clip_component.get_global_position()
	bullet_instance.sprite.global_position = clip_component.get_global_position()
	bullet_instance.rotation = rotation
	bullet_instance.origin = self
	#bullet_instance.apply_central_impulse(Vector2(bullet_speed, 0).rotated(bullet_instance.rotation))
	get_tree().current_scene.call_deferred("add_child", bullet_instance)

	set_projectile_player(bullet_instance)

	slugging = false
	slug_charge_timer = 0.0
	slugger_bar.hide()
	apply_central_impulse(Vector2.LEFT.rotated(rotation) * fire_knockback)


func _on_slug_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and area.is_in_group("Player1" if player_id == PlayerIDs.PLAYER_2 else "Player2"):
		slug_charging = true


func _on_slug_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player") and area.is_in_group("Player1" if player_id == PlayerIDs.PLAYER_2 else "Player2"):
		slug_charging = false
