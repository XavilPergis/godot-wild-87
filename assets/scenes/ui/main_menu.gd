extends Control

@export var play_scene: PackedScene
@onready var transition: SceneTransition = $SceneTransitionAnimation

func _on_play_button_pressed() -> void:
	transition.transition_to_packed(play_scene)
