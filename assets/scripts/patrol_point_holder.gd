extends Node3D
class_name PatrolPointHolder

@export var points: Array[PatrolPoint]

func _ready() -> void:
	for node in get_children():
		if node is PatrolPoint:
			points.push_back(node)
