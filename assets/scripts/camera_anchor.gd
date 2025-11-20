extends Marker3D

@export var height: float = 5.0
@export var horizontal_offset: float = 15.0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("rotate_camera_left"):
		GameState.camera_angle += deg_to_rad(360.0 / 8.0)
	if Input.is_action_just_pressed("rotate_camera_right"):
		GameState.camera_angle -= deg_to_rad(360.0 / 8.0)
	
	position = Vector3.ZERO
	position.y = height
	var horiz = Vector3.FORWARD.rotated(Vector3.UP, GameState.camera_angle)
	position -= horizontal_offset * horiz
