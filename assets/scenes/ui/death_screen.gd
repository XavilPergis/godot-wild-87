extends Control

#@export var main_menu_scene: PackedScene
@onready var scene_transition: SceneTransition = $SceneTransition
@onready var retry_button: Button = %RetryButton

func _ready() -> void:
	retry_button.grab_focus()

func _on_retry_button_pressed() -> void:
	scene_transition.reload_current()

func _on_quit_button_pressed() -> void:
	#get_tree().change_scene_to_packed(main_menu_scene)
	scene_transition.transition_to_file("res://assets/scenes/ui/main_menu.tscn")
