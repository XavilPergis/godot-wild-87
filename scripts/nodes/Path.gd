extends Node3D
class_name Path

var elements: Array[PathElement] = []

func _ready() -> void:
	for child in get_children():
		elements.push_back(child)
