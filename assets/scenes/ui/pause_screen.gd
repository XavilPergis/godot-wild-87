class_name AskQuitScreen extends Control

@onready var scene_transition: SceneTransition = $SceneTransition
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	get_tree().paused = true
	quit_button.grab_focus()
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		var tree := get_tree()
		if tree:
			tree.paused = false

func _on_quit_button_pressed():
	get_tree().paused = false
	scene_transition.transition_to_file("res://assets/scenes/ui/main_menu.tscn")
	
func _on_dont_quit_button_pressed():
	self.queue_free()

func _on_fullscreen_button_pressed() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	pass # Replace with function body.
