extends Camera3D
class_name MovableCamera

enum Mode { Oneshot, Follow }

var target_position: Node3D
var target_look: Node3D

var source_position: Vector3
var source_basis: Basis
var transition_seconds: float
var transition_seconds_remaining: float

@export var smoothing_curve: Curve = preload("res://assets/curves/camera_transition_easing.tres")
## The reference up direction for calculating camera roll when tracking a target.
@export var up_dir: Vector3 = Vector3.UP
@export var mode: Mode = Mode.Follow
@export var lock_z_rotation: bool = true
@export var should_use_smoothing: bool = true
@export var position_smoothing_speed: float = 5.0
@export var rotation_smoothing_speed: float = 10.0

# TODO: Change the camera's target, smoothly moving from the current target to the new target.
# The first argument is a Node3D that the camera will follow the exact position of.
# The second argument is a Node3D that the camera will look at.
# If the second argument is null, the camera will instead follow the rotation of the first argument.
# The final argument is the number of seconds that the transition will take place over.
func set_target(position_node: Node3D, lookat_node: Node3D, seconds: float):
	print("pos: ", position_node.name)
	if lookat_node: print("look: ", lookat_node.name)
	target_position = position_node
	target_look = lookat_node
	transition_seconds = seconds
	transition_seconds_remaining = seconds
	source_position = global_position
	source_basis = global_basis
	
func _interpolate_rotation(from: Basis, to: Basis, t: float) -> Basis:
	from = from.orthonormalized()
	to = to.orthonormalized()
	var euler = from.slerp(to, t).get_euler()
	if lock_z_rotation:
		euler.z = 0
	return Basis.from_euler(euler)

func _interpolate() -> Transform3D:
	var interp = Transform3D()
	var t = 1
	if transition_seconds > 0:
		var transition_completion = 1 - (transition_seconds_remaining / transition_seconds)
		t = smoothing_curve.sample_baked(transition_completion)
	if target_look:
		var to_look_target = target_look.global_position - target_position.global_position
		var target_look_at = Basis.looking_at(to_look_target, up_dir)
		interp.basis = _interpolate_rotation(source_basis, target_look_at, t)
	else:
		interp.basis = _interpolate_rotation(source_basis, target_position.global_basis, t)
	interp.origin = lerp(source_position, target_position.global_position, t)
	return interp

## Set the camera's orientation directly to the target that the smoothing is
## trying to reach.
func reset_smoothing() -> void:
	global_transform = _interpolate()

func _process(delta: float) -> void:
	if not smoothing_curve or not target_position: return
	transition_seconds_remaining = move_toward(transition_seconds_remaining, 0, delta)

	var interp = _interpolate()
	
	if should_use_smoothing:
		global_position = lerp(global_position, interp.origin, 1 - pow(2, -position_smoothing_speed * delta))
		global_basis = _interpolate_rotation(global_basis, interp.basis, 1 - pow(2, -rotation_smoothing_speed * delta))
	else:
		global_transform = interp

	if mode == Mode.Oneshot and transition_seconds_remaining <= 0:
		target_position = null
		target_look = null
