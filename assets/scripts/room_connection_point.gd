extends Node3D
class_name RoomConnectionPoint

var connection: RoomConnectionPoint = null

func connect_and_position(p_connection: RoomConnectionPoint):
	p_connection.connection = self
	connection = p_connection
	
	var rotated_transform = Transform3D(self.global_transform)
	rotated_transform.basis = rotated_transform.basis.rotated(Vector3(0, 1, 0), PI)
	self.get_parent_node_3d().global_transform *= p_connection.global_transform * rotated_transform.inverse()
	pass
