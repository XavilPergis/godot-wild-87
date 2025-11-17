class_name PatrolPointHolder extends Node3D

var points: Array[PatrolPoint]

func _ready() -> void:
	for node in get_children():
		if node is PatrolPoint:
			points.push_back(node)
