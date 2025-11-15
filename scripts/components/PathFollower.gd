extends Node
class_name PathFollowerComponent

enum LoopMode {
	PingPong,
	Restart,
}

signal reached_target(target: PathElement)

@export var active: bool = true
@export var path: Path
## The distance from the target path node at which this script considers that node reached.
@export var path_element_tolerance: float = 1.0
@export var speed: float = 0.5
@export var loop_mode: LoopMode = LoopMode.Restart

var target_node_index: int = -1
var index_dir: int = 1


func _physics_process(delta: float) -> void:
	if not active or not path or not len(path.elements): return
	var parent = get_parent()
	
	# TODO: how do we select the initial node?
	if target_node_index < 0:
		target_node_index = 0
		
	if target_node_index >= 0 and target_node_index < len(path.elements):
		var target = path.elements[target_node_index]
		var to_target = target.position - parent.position

		# we reached our target path node, switch to the next one!
		if to_target.length() <= path_element_tolerance:
			reached_target.emit(target)
			match loop_mode:
				LoopMode.PingPong:
					if index_dir == 1 and target_node_index + 1 == len(path.elements):
						index_dir = -1
					elif index_dir == -1 and target_node_index == 0:
						index_dir = 1
					target_node_index += index_dir
				LoopMode.Restart:
					target_node_index += 1
					if target_node_index == len(path.elements):
						target_node_index = 0

		elif not to_target.is_zero_approx():
			var dir_to_target = to_target.normalized()
			# should movement really be controlled here...?
			parent.position += dir_to_target * speed * delta
