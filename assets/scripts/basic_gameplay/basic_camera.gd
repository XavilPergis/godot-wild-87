extends MovableCamera

@export var anchor: Node3D
@export var look_target: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_target(anchor, look_target, 0)
	reset_smoothing()
