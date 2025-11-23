class_name AskQuitScreen extends Control

@onready var scene_transition: SceneTransition = $SceneTransition
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	quit_button.grab_focus()

func _on_quit_button_pressed():
	scene_transition.transition_to_file("res://assets/scenes/ui/main_menu.tscn")
	
func _on_dont_quit_button_pressed():
	self.queue_free()
