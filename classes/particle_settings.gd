extends Resource
class_name ParticleSettings

@export var velocity_inherit := 0.5
@export var amount := 3
@export var random_range := 0.3
@export var scale_range := 4.0
@export var target: NodePath
@export var local := false
@export var spawn_position := Vector2()
#@export var is_set_angle := false
#@export var set_angle := 0.0
@export var angle_random := 0.0
@export var angle_offset := PI
@export var loops := 1
@export var subparticle: PackedScene
@export var subparticle_settings: ParticleSettings
