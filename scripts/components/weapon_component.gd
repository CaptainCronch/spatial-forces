extends Node2D
class_name WeaponComponent

@export var clip_bar : Meter
@export var max_clip : int
@export var reload_time : float
@export var reload_delay : float
@export var fire_delay : float

var clip := 0
var can_fire := true

@onready var reload_timer : Timer = $ReloadTimer
@onready var reload_delay_timer : Timer = $ReloadDelayTimer
@onready var fire_delay_timer : Timer = $FireDelayTimer


func _ready() -> void:
	clip = max_clip
	reload_timer.wait_time = reload_time
	reload_delay_timer.wait_time = reload_delay
	clip_bar.max_value = max_clip
	clip_bar.value = clip


func use(ammo : int) -> void:
	can_fire = false
	clip -= ammo
	reload_delay_timer.start(reload_delay)
	fire_delay_timer.start(fire_delay)
	reload_timer.stop()
	clip_bar.value = clip


func reload(ammo : int):
	clip += 1
	if clip < max_clip:
		reload_timer.start(reload_time)
	clip_bar.value = clip


func _on_reload_timer_timeout() -> void:
	reload(1)


func _on_delay_timer_timeout() -> void:
	reload(1)


func _on_fire_delay_timer_timeout() -> void:
	can_fire = true
