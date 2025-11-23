extends Control

@export var play_scene: PackedScene
@onready var transition: SceneTransition = $SceneTransitionAnimation
@onready var how_to_play_modal: CenterContainer = $HowToPlayModal
@onready var credits_modal: CenterContainer = $CreditsModal

func _find_rich_text(node: Node) -> Array[RichTextLabel]:
	var result: Array[RichTextLabel] = []
	if node is RichTextLabel:
		result.push_back(node as RichTextLabel)
	for child in node.get_children():
		result.append_array(_find_rich_text(child))
	return result

func _ready() -> void:
	for node in _find_rich_text(self):
		node.meta_clicked.connect(_on_rich_text_clicked)

func _on_rich_text_clicked(meta) -> void:
	OS.shell_open(str(meta))

func _on_play_button_pressed() -> void:
	transition.transition_to_packed(play_scene)

func _on_quit_button_pressed() -> void:
	transition.transition_to_quit()

func _on_how_to_play_button_pressed() -> void:
	how_to_play_modal.visible = true

func _on_credits_button_pressed() -> void:
	credits_modal.visible = true

func _on_fullscreen_button_pressed() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	pass # Replace with function body.
