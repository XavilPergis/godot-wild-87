extends Control

@onready var scene_transition: SceneTransition = $SceneTransition
@onready var retry_button: Button = %RetryButton

func _ready() -> void:
	retry_button.grab_focus()

func _on_retry_button_pressed() -> void:
	scene_transition.reload_current()

func _on_quit_button_pressed() -> void:
	scene_transition.transition_to_file("res://assets/scenes/ui/main_menu.tscn")
