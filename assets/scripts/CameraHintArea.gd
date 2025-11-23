class_name CameraHintArea extends Area3D

@export var camera_angle: float

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		print("Changing camera angle!!")
		GameState.instance.set_camera_angle_with_coyote(camera_angle*PI/180)
	pass # Replace with function body.
