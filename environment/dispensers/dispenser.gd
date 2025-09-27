extends Node2D

const SPEED_ITEM = preload("uid://dd7t8qpwg6vr")
const HEALTH_ITEM = preload("uid://ck1ul7vpt0rx1")
const DAMAGE_ITEM = preload("uid://dskcylldcry4f")

enum SCENES {SPEED, HEALTH, POWER}

@export var dispensed_scene := SCENES.SPEED
@export var particles: CPUParticles2D
@export var timer: Timer
@export var spawn_time := 10.0
@export var particle_spin_speed := TAU

var spawned_item: RigidBody2D

@onready var packed_scenes: Array[PackedScene] = [SPEED_ITEM, HEALTH_ITEM, DAMAGE_ITEM]


func _ready() -> void:
	timer.start(spawn_time - 2.0)


func _process(delta: float) -> void:
	particles.rotate(particle_spin_speed * delta)


func _on_timer_timeout() -> void:
	particles.emitting = true
	await get_tree().create_timer(2.0).timeout
	spawned_item = packed_scenes[dispensed_scene].instantiate()
	spawned_item.global_position = global_position
	#timer.start(spawn_time - 2.0)
	spawned_item.collected.connect(_on_item_collected)
	get_tree().current_scene.add_child(spawned_item)


func _on_item_collected() -> void:
	timer.start(spawn_time - 2.0)
