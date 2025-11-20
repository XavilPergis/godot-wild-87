class_name GameState

static var camera_angle: float = 0.0:
	get(): return camera_angle
	set(new_angle): camera_angle = fmod(new_angle, TAU)
