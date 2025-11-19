extends Node
class_name PatrolRoute

@export var holder: PatrolPointHolder

var navigation_agent: NavigationAgent3D:
	get(): return navigation_agent
	set(value):
		if navigation_agent:
			navigation_agent.target_reached.disconnect(_on_target_reached)
		value.target_reached.connect(_on_target_reached)
		navigation_agent = value
var points: Array[PatrolPoint]
var patrol_index = -1

signal set_target(target: PatrolPoint)
signal reached_target(target: PatrolPoint)

func _ready() -> void:
	points = Array(holder.points)
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
	var nearest_distance: float = INF
	
	for i in points.size():
		var point = points[i]
		if not point.can_start_at:
			continue
		navigation_agent.set_target_position(point.global_position)
		var distance = navigation_agent.distance_to_target()
		if distance < nearest_distance:
			nearest_point_index = i
			nearest_distance = distance
	
	patrol_index = nearest_point_index
	navigation_agent.set_target_position(points[patrol_index].global_position)
	set_target.emit(points[patrol_index])
	print("targeting #", patrol_index, " at ", points[patrol_index].global_position)
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
		print("targeting #", patrol_index, " at ", points[patrol_index].global_position)
	pass
	
# Suspends the patrol route
func suspend():
	patrol_index = -1
	pass

func next_point_position() -> Vector3:
	return navigation_agent.get_next_path_position()

# Returns the direction to the next point
func direction_to_next_point(origin: Vector3) -> Vector3:
	var local_destination = navigation_agent.get_next_path_position() - origin
	return local_destination.normalized()
	
