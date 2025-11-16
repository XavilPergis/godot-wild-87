extends Node3D
class_name DungeonRoom

func get_connection_points() -> Array[RoomConnectionPoint]:
	var ret: Array[RoomConnectionPoint] = []
	for child in self.get_children():
		if child is RoomConnectionPoint:
			ret.append(child)
	return ret
