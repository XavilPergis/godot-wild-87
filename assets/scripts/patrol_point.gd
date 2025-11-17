class_name PatrolPoint extends Marker3D

## The distance from the patrol point at which a patrol route will consider the
## target node reached.
@export var tolerance_distance: float = 1
## If set to true, agents will enter their scan states upon reaching this node.
## Otherwise, they will continue to the next patrol point without stopping.
## You might want to use this option if agents are pathing in a way you did not
## intend for them to.
@export var should_scan: bool = true
