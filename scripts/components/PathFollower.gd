extends Node
class_name PathFollowerComponent

enum LoopMode { PingPong, Restart }
enum InitialMode { First, Last, Random }

signal selected_target(target: PathElement)
signal reached_target(target: PathElement)

const ID: StringName = &"PathFollower"

@export var active: bool = false
@export var path: Path
## The distance from the target path node at which this script considers that node reached.
@export var path_element_tolerance: float = 1.0
@export var speed: float = 0.5
@export var loop_mode: LoopMode = LoopMode.Restart
@export var initial_mode: InitialMode = InitialMode.Random

var target_node_index: int = -1
var index_dir: int = 1

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PARENTED: get_parent().set_meta(ID, self)
		NOTIFICATION_UNPARENTED: get_parent().set_meta(ID, null)

func _select_initial_node() -> void:
	# no path nodes to select from
	if not len(path.elements): return
	match initial_mode:
		InitialMode.First:
			target_node_index = 0
		InitialMode.Last:
			target_node_index = len(path.elements) - 1
		InitialMode.Random:
			target_node_index = randi_range(0, len(path.elements) - 1)
	selected_target.emit(path.elements[target_node_index])

func _select_next_node() -> void:
	match loop_mode:
		LoopMode.PingPong:
			if index_dir == 1 and target_node_index + 1 == len(path.elements):
				index_dir = -1
			elif index_dir == -1 and target_node_index == 0:
				index_dir = 1
			target_node_index += index_dir
			selected_target.emit(path.elements[target_node_index])
		LoopMode.Restart:
			target_node_index += 1
			if target_node_index == len(path.elements):
				target_node_index = 0
			selected_target.emit(path.elements[target_node_index])

func _physics_process(delta: float) -> void:
	if not active or not path or not len(path.elements): return
	var parent = get_parent()

	# TODO: how do we select the initial node?
	if target_node_index < 0:
		_select_initial_node()

	if target_node_index >= 0 and target_node_index < len(path.elements):
		var target = path.elements[target_node_index]
		var to_target = target.position - parent.position

		# we reached our target path node, switch to the next one!
		if to_target.length() <= path_element_tolerance:
			reached_target.emit(target)
			_select_next_node()

		elif not to_target.is_zero_approx():
			var dir_to_target = to_target.normalized()
			# should movement really be controlled here...?
			parent.position += dir_to_target * speed * delta
	else:
		target_node_index = -1
