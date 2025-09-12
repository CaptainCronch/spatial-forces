extends Node
class_name Modifier

@export var id : StringName

var enabled := false

@onready var mod_comp : ModifierComponent = get_parent()


func _ready():
	mod_comp.modifiers_changed.connect(update_bonuses)


func enable():
	enabled = true


func disable():
	enabled = false


func update_bonuses() -> void :
	pass
