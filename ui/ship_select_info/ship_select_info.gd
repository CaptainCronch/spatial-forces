extends HBoxContainer

@export var ready_holder: Control

@export var title: Label
@export var ship_holder: Node2D
@export var ship: Sprite2D
@export var player_number: Label
@export var underline: Line2D
@export var subtitle: Label

@export var max: Label
@export var max_bar: TextureRect

@export var acc: Label
@export var acc_bar: TextureRect

@export var nrg: Label
@export var nrg_bar: TextureRect

@export var clp: Label
@export var clp_bar: TextureRect

@export var passive: Label
@export var primary: Label
@export var secondary: Label

@export var ship_scale := Vector2(1.5, 0.8)
@export var tween_duration := 0.5
@export var ready_duration := 0.2
@export var player_string := "P1"

@onready var labels: Array[Label] = [subtitle, passive, primary, secondary]
@onready var numbers: Array[Label] = [max, acc, nrg, clp]
@onready var bars: Array[TextureRect] = [max_bar, acc_bar, nrg_bar, clp_bar]

var ship_rotation_direction := 1
var desired_ship_rotation_speed := PI / 2
var ship_rotation_speed := desired_ship_rotation_speed
var text_tween: Tween
var title_tween: Tween
var number_tween: Tween
var bar_tween: Tween
var ready_tween: Tween
var last_ship_index = null

var max_value := 0.0
var acc_value := 0.0
var nrg_value := 0.0
var clp_value := 0.0

var stat_min_max: Array[Array] = [[null, null], [null, null], [null, null], [null, null]]


func _ready() -> void: # find minimum and maximum stats of all ships to get a scale going
	for info in Global.SHIP_INFO:
		if stat_min_max[0][0] == null or info.max < stat_min_max[0][0]:
			stat_min_max[0][0] = info.max
		if stat_min_max[0][1] == null or info.max > stat_min_max[0][1]:
			stat_min_max[0][1] = info.max

		if stat_min_max[1][0] == null or info.acc < stat_min_max[1][0]:
			stat_min_max[1][0] = info.acc
		if stat_min_max[1][1] == null or info.acc > stat_min_max[1][1]:
			stat_min_max[1][1] = info.acc

		if stat_min_max[2][0] == null or info.nrg < stat_min_max[2][0]:
			stat_min_max[2][0] = info.nrg
		if stat_min_max[2][1] == null or info.nrg > stat_min_max[2][1]:
			stat_min_max[2][1] = info.nrg

		if stat_min_max[3][0] == null or info.clp < stat_min_max[3][0]:
			stat_min_max[3][0] = info.clp
		if stat_min_max[3][1] == null or info.clp > stat_min_max[3][1]:
			stat_min_max[3][1] = info.clp

	player_number.text = player_string


func _process(delta: float) -> void:
	ship_rotation_speed = Global.decay_towards(ship_rotation_speed, desired_ship_rotation_speed * ship_rotation_direction, 5.0)
	ship.rotation += ship_rotation_speed * delta
	ship_holder.scale = ship_scale
	ship.global_position = ship_holder.get_global_transform_with_canvas().get_origin() + Vector2(-4, 2)
	max.text = str(roundi(max_value))
	acc.text = str(roundi(acc_value))
	nrg.text = str(roundi(nrg_value))
	clp.text = str(roundi(clp_value))


func update(ship_index: int, direction: int) -> void:
	if ship_index == last_ship_index: return

	var info := Global.SHIP_INFO[ship_index]
	title.text = info.title
	ship.texture = info.sprite
	subtitle.text = info.subtitle
	passive.text = info.passive
	primary.text = info.primary
	secondary.text = info.secondary

	if is_instance_valid(title_tween): title_tween.kill()
	title_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var title_rand := randf_range(-0.1, 0.1)
	title.modulate = Color(1, 1, 1, 0)
	title_tween.tween_property(title, "modulate", Color(1, 1, 1, 1), tween_duration + title_rand)

	if is_instance_valid(text_tween): text_tween.kill()
	text_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	for label in labels:
		label.visible_ratio = 0.0
		var rand := randf_range(-0.3, 0.3)
		text_tween.tween_property(label, "visible_ratio", 1.0, tween_duration + rand)

	if is_instance_valid(bar_tween): bar_tween.kill()
	bar_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).set_parallel()
	tween_bar(max_bar, 0, info.max)
	tween_bar(acc_bar, 1, info.acc)
	tween_bar(nrg_bar, 2, info.nrg)
	tween_bar(clp_bar, 3, info.clp)

	if is_instance_valid(number_tween): number_tween.kill()
	number_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween_number("max", info.max)
	tween_number("acc", info.acc)
	tween_number("nrg", info.nrg)
	tween_number("clp", info.clp)

	ship_rotation_direction = direction
	ship_rotation_speed += TAU * 2 * direction

	last_ship_index = ship_index


func ready_up(is_ready: bool):
	if is_instance_valid(ready_tween): ready_tween.kill()
	ready_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	if is_ready:
		ready_tween.tween_property(ready_holder, "custom_minimum_size:x", 64, ready_duration)
		ready_tween.tween_property(ready_holder, "modulate", Color(1, 1, 1, 1), ready_duration)
	else:
		ready_tween.tween_property(ready_holder, "custom_minimum_size:x", 0, ready_duration)
		ready_tween.tween_property(ready_holder, "modulate", Color(1, 1, 1, 0), ready_duration)




func tween_number(property_name: String, end_value: int) -> void:
	var rand := randf_range(-0.3, 0.3)
	number_tween.tween_property(self, property_name + "_value", end_value, tween_duration + rand)


func tween_bar(object: TextureRect, index: int, end_value: int) -> void:
	var rand := randf_range(-0.2, 0.2)
	var remapped := remap(end_value, stat_min_max[index][0], stat_min_max[index][1], 1, 64)
	bar_tween.tween_property(object, "scale:x", remapped, tween_duration + rand)
