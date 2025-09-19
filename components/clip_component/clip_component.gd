extends Node2D
class_name ClipComponent

@export var clip_bar : Meter
@export var max_clip : int
@export var reload_time : float
@export var reload_delay : float
@export var fire_delay : float

var clip := 0.0
var can_fire := true

@onready var reload_timer : Timer = $ReloadTimer
@onready var reload_delay_timer : Timer = $ReloadDelayTimer
@onready var fire_delay_timer : Timer = $FireDelayTimer


func _ready() -> void:
	clip = max_clip
	reload_timer.wait_time = reload_time
	reload_delay_timer.wait_time = reload_delay
	fire_delay_timer.wait_time = fire_delay
	clip_bar.max_value = max_clip
	clip_bar.value = clip


func use(ammo : int, delay_multiplier := 1.0, delay_addend := 0.0, fire_delay_addend := 0.0) -> void:
	can_fire = false
	clip -= ammo
	reload_delay_timer.start(maxf(0.0, (reload_delay * delay_multiplier) + delay_addend))
	fire_delay_timer.start(maxf(0.0, fire_delay + fire_delay_addend)) # maybe only start reload delay after fire delay?
	reload_timer.stop()
	clip_bar.value = clip


func hold(ammo : float, delay_multiplier := 1.0) -> void:
	clip -= ammo
	reload_delay_timer.start(maxf(0.0, reload_delay * delay_multiplier))
	reload_timer.stop()
	clip_bar.value = clip


func reload(ammo : int):
	clip += ammo
	if clip < max_clip:
		reload_timer.start(maxf(0.0, reload_time))
	clip_bar.value = clip


func _on_reload_timer_timeout() -> void:
	reload(1)


func _on_delay_timer_timeout() -> void:
	reload(1)


func _on_fire_delay_timer_timeout() -> void:
	can_fire = true
