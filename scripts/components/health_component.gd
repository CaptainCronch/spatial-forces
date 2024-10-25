extends Node2D
class_name HealthComponent

signal damage_taken(attack : Attack)
signal healed(amount : float)
signal health_changed(amount : float)
signal death(attack : Attack)

#const number_popup := preload("res://Scenes/number_popup.tscn")

@export var default_color := Color.RED
@export var blocked_color := Color.DARK_ORANGE
@export var max_health : float
@export var target : Node2D
@export var invincibility_time := 0.0
@export var heal_rate := 0.0
#@export var heal_time := 10.0
@export var heal_tick := 0.25

var health := 0.0
var heal_multiplier := 1.0
var dead := false

var heal_bonus : BonusManager
var heal_tween : Tween

@onready var invincibility_timer : Timer = $Invincibility
@onready var heal_timer : Timer = $Heal
@onready var heal_delay_timer : Timer = $HealDelay


func _ready():
	heal_bonus = BonusManager.new()
	health = max_health


func damage(attack : Attack):
	if dead: return
	heal_timer.stop() # stop healing even if damage is 0
	if heal_tween: heal_tween.kill()
	if attack.attack_damage <= 0: return
	if not invincibility_timer.is_stopped(): return
	if attack.attack_damage <= 0.0:
		#spawn_number_popup("BLOCKED!!", blocked_color)
		return

	health -= roundf(attack.attack_damage)
	damage_taken.emit(attack)
	health_changed.emit(-attack.attack_damage)
	#spawn_number_popup(str(roundf(attack.attack_damage)), default_color)

	if health <= 0:
		die(attack)
		return
	if is_zero_approx(invincibility_time): return
	invincibility_timer.start(invincibility_time)


func die(attack):
	if dead: return
	death.emit(attack)
	dead = true
	#target.queue_free()


func heal(amount : float) -> void :
	if dead: return
	if amount <= 0: return
	health = minf(health + amount, max_health)
	healed.emit(amount)
	health_changed.emit(amount)


#func spawn_number_popup(value : String, color := Color.RED):
	#if dead: return
	#var new_popup := number_popup.instantiate()
	#get_tree().current_scene.add_child(new_popup)
	#new_popup.global_position = global_position
	#new_popup.text = value
	#new_popup.modulate = color


func _on_heal_timeout():
	heal(heal_rate * heal_bonus.get_total())
	heal_timer.start(heal_tick)


func _on_heal_delay_timeout():
	_on_heal_timeout()
	if heal_tween:
		heal_tween.kill()
	heal_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)