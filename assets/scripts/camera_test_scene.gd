extends Node3D

@onready var movable_camera: MovableCamera = $MovableCamera

@export var camera_positions: Array[Node3D]
@export var camera_targets: Array[Node3D]

var index = 0

func _ready() -> void:
	assert(camera_positions.size() == camera_targets.size())
	movable_camera.set_target(camera_positions[0], camera_targets[0], 0.0)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		assert(camera_positions.size() == camera_targets.size())
		index = index + 1
		if index >= camera_positions.size():
			index = 0
		randomize()
		movable_camera.set_target(camera_positions[index], camera_targets[index], randf() + 0.25)
		pass
