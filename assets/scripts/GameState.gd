class_name GameState extends Node

static var instance: GameState

signal game_lost()
signal game_won()

@export var lose_screen_scene: PackedScene
@export var win_screen_scene: PackedScene
@export var camera_coyote_time: float = 0.5

var _coyote_timer: Timer

var camera_angle: float = 0.0:
	get(): return camera_angle
	set(new_angle):
		camera_angle = fmod(new_angle, TAU)
		coyote_angle = camera_angle
		
func set_camera_angle_with_coyote(new_angle: float):
	var temp = camera_angle
	camera_angle = new_angle
	coyote_angle = temp
	_coyote_timer.start(camera_coyote_time)

var coyote_angle: float

var decay_interactables: Array[Interactable] = []
var remaining_decay_interactables: Array[Interactable] = []
@export var player: Node3D

func _on_coyote_timeup():
	coyote_angle = camera_angle
	pass

func _ready() -> void:
	instance = self
	game_lost.connect(_on_game_lost)
	game_won.connect(_on_game_won)
	
	_coyote_timer = Timer.new()
	add_child(_coyote_timer)
	_coyote_timer.timeout.connect(_on_coyote_timeup)
	_coyote_timer.one_shot = true

func _on_game_lost() -> void:
	var scene = lose_screen_scene.instantiate()
	get_tree().current_scene.add_child(scene)

func _on_game_won() -> void:
	var scene = win_screen_scene.instantiate()
	get_tree().current_scene.add_child(scene)
