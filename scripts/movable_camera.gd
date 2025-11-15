extends Camera3D
class_name MovableCamera

# TODO: Change the camera's target, smoothly moving from the current target to the new target.
# The first argument is a Node3D that the camera will follow the exact position of.
# The second argument is a Node3D that the camera will look at.
# If the second argument is null, the camera will instead follow the rotation of the first argument.
# The final argument is the number of seconds that the transition will take place over.
func change_target(_position_node: Node3D, _lookat_node: Node3D, _seconds: float):
	pass
