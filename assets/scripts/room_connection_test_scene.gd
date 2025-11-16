extends Node3D

@export var _rooms: Array[PackedScene]

var _rooms_unpacked: Array[Node3D]

func _ready() -> void:
	for i in _rooms.size():
		_rooms_unpacked.append(_rooms[i].instantiate())
		
	var instance = _rooms_unpacked[0].duplicate()
	add_child(instance)
	
	randomize()
	expand_dungeon_recursive(instance, 3)
	pass

# returns the number of rooms created
func expand_dungeon_recursive(start_room: Node3D, rooms_left: int) -> int:
	var conn_points = get_connection_points(start_room)
	var rooms_added = 0

	for conn_point in conn_points:
		if rooms_added >= rooms_left:
					break
		
		if not conn_point.connection:
			var new_room = _rooms_unpacked[randi_range(0, _rooms_unpacked.size() - 1)].duplicate()
			add_child(new_room)
			
			var new_conn_points: = get_connection_points(new_room)
			var new_conn_point = new_conn_points[randi_range(0, new_conn_points.size() - 1)]
			
			new_conn_point.connect_and_position(conn_point)
			
			rooms_added = rooms_added + 1
			
			if rooms_left > rooms_added:
				rooms_added = rooms_added + expand_dungeon_recursive(new_room, rooms_left - rooms_added)
		
	return rooms_added

func get_connection_points(room: Node3D) -> Array[RoomConnectionPoint]:
	var ret: Array[RoomConnectionPoint] = []
	for child in room.get_children():
		if child is RoomConnectionPoint:
			ret.append(child)
	return ret
