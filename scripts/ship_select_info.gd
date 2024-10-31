extends VBoxContainer

@export var title: Label
@export var ship_holder: Control
@export var ship: Sprite2D
@export var player_number: Label
@export var subtitle: Label

@export var max: Label
@export var max_bar: TextureRect

@export var acc: Label
@export var acc_bar: TextureRect

@export var rot: Label
@export var rot_bar: TextureRect

@export var clp: Label
@export var clp_bar: TextureRect

@export var passive: Label
@export var primary: Label
@export var secondary: Label

@export var ship_rotation_speed := PI / 2
@export var ship_scale := Vector2(1.5, 0.8)

@onready var labels: Array[Label] = [title, subtitle, passive, primary, secondary]


func _process(delta: float) -> void:
	ship.rotation += ship_rotation_speed * delta
	ship_holder.scale = ship_scale
	ship.global_position = ship_holder.get_global_transform_with_canvas().get_origin() + Vector2(-8, 2)


func update(ship_index: int) -> void:
	var info := Global.SHIP_INFO[ship_index]
	title.text = info.title
	ship.texture = info.sprite
	subtitle.text = info.subtitle
	max.text = str(info.max)
	acc.text = str(info.acc)
	rot.text = str(info.rot)
	clp.text = str(info.clp)
	passive.text = info.passive
	primary.text = info.primary
	secondary.text = info.secondary
