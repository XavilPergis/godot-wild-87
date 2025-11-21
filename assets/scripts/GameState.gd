class_name GameState extends Node

static var instance: GameState

signal game_lost()
signal game_won()

var camera_angle: float = 0.0:
	get(): return camera_angle
	set(new_angle): camera_angle = fmod(new_angle, TAU)

var remaining_decay_interactables: Array[Interactable] = []

func _ready() -> void:
	instance = self
