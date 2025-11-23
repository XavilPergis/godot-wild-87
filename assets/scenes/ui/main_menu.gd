extends Control

@export var play_scene: PackedScene
@onready var transition: SceneTransition = $SceneTransitionAnimation
@onready var how_to_play_modal: CenterContainer = $HowToPlayModal

func _on_play_button_pressed() -> void:
	transition.transition_to_packed(play_scene)

func _on_quit_button_pressed() -> void:
	transition.transition_to_quit()

func _on_how_to_play_button_pressed() -> void:
	how_to_play_modal.visible = true
