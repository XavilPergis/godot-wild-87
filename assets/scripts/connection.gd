extends Node
class_name ConnectType

enum Direction {
	NORTH,
	EAST,
	SOUTH,
	WEST
}
@export var position: Vector2i
@export var direction: Direction
var is_connecting = false
