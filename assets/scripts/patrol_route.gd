extends Node3D
class_name PatrolRoute

@export var points: Array[PatrolPoint]
@export var navigation_agent: NavigationAgent3D

var patrol_index = -1

signal set_target(target: PatrolPoint)
signal reached_target(target: PatrolPoint)

func _ready() -> void:
	navigation_agent.target_reached.connect(_on_target_reached)
	pass

func _on_target_reached() -> void:
	reached_target.emit(points[patrol_index])

# Returns the currently targeted patrol point
func current_point() -> PatrolPoint:
	if patrol_index < 0:
		target_nearest_point()
	return points[patrol_index]

# Targets the nearest point
func target_nearest_point():
	var nearest_point_index = 0
	var nearest_distance: float = TYPE_MAX
	
	for i in points.size():
		navigation_agent.set_target_position(points[i].global_position)
		var distance = navigation_agent.distance_to_target()
		if distance < nearest_distance:
			nearest_point_index = i
			nearest_distance = distance
	
	patrol_index = nearest_point_index
	navigation_agent.set_target_position(points[patrol_index].global_position)
	set_target.emit(points[patrol_index])
	pass

# Move onto the next point in the list
func target_next_point():
	if patrol_index < 0:
		target_nearest_point()
	else:
		patrol_index = patrol_index + 1
		if patrol_index >= points.size():
			patrol_index = 0
		navigation_agent.set_target_position(points[patrol_index].global_position)
		set_target.emit(points[patrol_index])
	pass
	
# Suspends the patrol route
func suspend():
	patrol_index = -1
	pass

func next_point_position() -> Vector3:
	return navigation_agent.get_next_path_position()

# Returns the direction to the next point
func direction_to_next_point() -> Vector3:
	var local_destination = navigation_agent.get_next_path_position() - global_position
	return local_destination.normalized()
	
