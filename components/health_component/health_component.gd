extends Node2D
class_name HealthComponent

signal damage_taken(attack: Attack)
signal healed(amount: float)
signal health_changed(amount: float)
signal death(attack: Attack)

#const number_popup := preload("res://Scenes/number_popup.tscn")

@export var health_bar : Meter
@export var default_color := Color.RED
@export var blocked_color := Color.DARK_ORANGE
@export var max_health: float
@export var target: Node2D
@export var heal_rate := 0.0
#@export var heal_time := 10.0
@export var heal_tick := 0.25

var health := 0.0
var heal_multiplier := 1.0
var dead := false

var heal_bonus: BonusManager
var heal_tween: Tween

@onready var heal_timer: Timer = $Heal
@onready var heal_delay_timer: Timer = $HealDelay


func _ready() -> void:
	if not heal_timer or not heal_delay_timer:
		printerr("HealthComponent of ", get_parent().name, " is missing child timer nodes! (Did you add the component via the \"Add Child Node\" option instead of the \"Instantiate Child Scene\" option?)")
	heal_bonus = BonusManager.new()
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health


func damage(attack: Attack) -> void:
	if target is RigidBody2D:
		target.apply_central_impulse(attack.attack_direction * attack.knockback_force)

	if dead: return
	heal_timer.stop() # stop healing even if damage is 0
	if heal_tween: heal_tween.kill()
	if attack.attack_damage <= 0: return
	if attack.attack_damage <= 0.0:
		#spawn_number_popup("BLOCKED!!", blocked_color)
		return

	health -= roundf(attack.attack_damage)
	damage_taken.emit(attack)
	health_changed.emit(-attack.attack_damage)
	health_bar.value = health
	#spawn_number_popup(str(roundf(attack.attack_damage)), default_color)
	#print(target.name + " WAS DAMAGED FOR " + str(attack.attack_damage) + " DAMAGE!")
	if health <= 0:
		die(attack)


func die(attack: Attack) -> void:
	if dead: return
	death.emit(attack)
	dead = true
	if target is Ship: target.last_damage = attack
	target.die()


func heal(amount: float) -> void:
	if dead: return
	if amount <= 0: return
	health = minf(health + amount, max_health)
	healed.emit(amount)
	health_changed.emit(amount)
	health_bar.value = health


#func spawn_number_popup(value : String, color := Color.RED):
	#if dead: return
	#var new_popup := number_popup.instantiate()
	#get_tree().current_scene.add_child(new_popup)
	#new_popup.global_position = global_position
	#new_popup.text = value
	#new_popup.modulate = color


func _on_heal_timeout() -> void:
	heal(heal_rate * heal_bonus.get_total())
	heal_timer.start(heal_tick)


func _on_heal_delay_timeout() -> void:
	_on_heal_timeout()
	if heal_tween:
		heal_tween.kill()
	heal_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
