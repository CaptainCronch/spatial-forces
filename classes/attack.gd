extends Resource
class_name Attack

@export var attack_damage := 0.0
@export var knockback_force := 0.0
@export var origin_name : String
@export var attack_type : ATTACK_TYPE

var attack_position := Vector2.ZERO
var attack_direction := Vector2.ZERO

enum ATTACK_TYPE {
	SHARP,
	BLUNT,
	EXPLOSIVE,
	ENERGY,
}


func _init(
		dam := attack_damage,
		knock := knockback_force,
		pos := attack_position,
		):
	attack_damage = dam
	knockback_force = knock
	attack_position = pos
