class_name SceneTransition extends Control

const ANIM_FADE_IN: StringName = &"fade_in"
const ANIM_FADE_OUT: StringName = &"fade_out"

@export var fade_time_seconds: float = 0.25

@onready var animation: AnimationPlayer = %FadeAnimation

func _do_animation(cb: Callable) -> void:
	animation.speed_scale = 1.0 / fade_time_seconds
	animation.play(ANIM_FADE_OUT)
	await animation.animation_finished
	var tree = get_tree()
	get_parent().remove_child(self)
	cb.call(tree)
	await tree.scene_changed
	tree.current_scene.add_child(self)
	animation.play(ANIM_FADE_IN)
	await animation.animation_finished
	queue_free()

func reload_current() -> void:
	_do_animation(func(tree): tree.reload_current_scene())

func transition_to_packed(scene: PackedScene) -> void:
	_do_animation(func(tree): tree.change_scene_to_packed(scene))

func transition_to_file(path: String) -> void:
	_do_animation(func(tree): tree.change_scene_to_file(path))
