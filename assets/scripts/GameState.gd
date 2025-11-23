class_name GameState extends Node

static var instance: GameState

signal game_lost()
signal game_won()

@export var lose_screen_scene: PackedScene

var camera_angle: float = 0.0:
	get(): return camera_angle
	set(new_angle): camera_angle = fmod(new_angle, TAU)

var remaining_decay_interactables: Array[Interactable] = []

func _ready() -> void:
	instance = self
	game_lost.connect(_on_game_lost)

func _on_game_lost() -> void:
	var scene = lose_screen_scene.instantiate()
	get_tree().current_scene.add_child(scene)
