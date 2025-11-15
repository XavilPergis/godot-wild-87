extends Node
class_name PatrolRoute

@export var points: Array[PatrolPoint]

var patrolIndex = 0

# Returns the currently targeted patrol point
func current_point() -> PatrolPoint:
	return points[patrolIndex]

# Move onto the next point in the list, and return that point
func target_next_point() -> PatrolPoint:
	patrolIndex = patrolIndex + 1
	if patrolIndex >= points.size():
		patrolIndex = 0
	return points[patrolIndex]
