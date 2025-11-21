extends Object
class_name QuadsMeshMaker

enum PlaneDirection {
	X_PLUS = 0,
	X_MINUS = 1,
	Y_PLUS = 2,
	Y_MINUS = 3,
	Z_PLUS = 4,
	Z_MINUS = 5
}

static func make_shape(quads: Array[Rect2], direction: PlaneDirection) -> ConcavePolygonShape3D:
	var triangles = PackedVector3Array()
	
	for quad in quads:
		var verts = _quad_to_vertices(quad, direction)
		
		triangles.append_array([
			verts[0], verts[1], verts[2],
			verts[0], verts[2], verts[3]
		])
		
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(triangles)
	return shape

static func make_mesh(quads: Array[Rect2], direction: PlaneDirection) -> ArrayMesh:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	var normal_vec: Vector3 = _normal_vector(direction)
	
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	var index = 0
	
	for quad in quads:
		var x0 = quad.position.x
		var x1 = quad.end.x
		var y0 = quad.position.y
		var y1 = quad.end.y
		
		verts.append_array(_quad_to_vertices(quad, direction))
		
		uvs.append_array([
			Vector2(x0, -y0),
			Vector2(x1, -y0),
			Vector2(x1, -y1),
			Vector2(x0, -y1)
		])
		
		normals.append_array([
			normal_vec, normal_vec, normal_vec, normal_vec
		])
		
		indices.append_array([
			index, index+1, index+2, 
			index, index+2, index+3
		])
		index += 4
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	return mesh

static func _normal_vector(direction: PlaneDirection) -> Vector3:
	match direction:
		PlaneDirection.X_PLUS:
			return Vector3.RIGHT
		PlaneDirection.X_MINUS:
			return Vector3.LEFT
		PlaneDirection.Y_PLUS:
			return Vector3.UP
		PlaneDirection.Y_MINUS:
			return Vector3.DOWN
		PlaneDirection.Z_PLUS:
			return Vector3.BACK
		PlaneDirection.Z_MINUS:
			return Vector3.FORWARD
		_:
			assert(false, "Invalid plane direction!!")
			return Vector3.ZERO

static func _quad_to_vertices(quad: Rect2, direction: PlaneDirection) -> PackedVector3Array:
	var pos: Vector2 = quad.position
	var end: Vector2 = quad.end
	
	var vertices: PackedVector3Array
	
	match direction & 0xE:
		PlaneDirection.X_PLUS:
			vertices = [
				Vector3(0, pos.y, pos.x),
				Vector3(0, pos.y, end.x),
				Vector3(0, end.y, end.x),
				Vector3(0, end.y, pos.x)
			]
		PlaneDirection.Y_PLUS:
			vertices = [
				Vector3(pos.x, 0, pos.y),
				Vector3(end.x, 0, pos.y),
				Vector3(end.x, 0, end.y),
				Vector3(pos.x, 0, end.y)
			]
		PlaneDirection.Z_PLUS:
			vertices = [
				Vector3(pos.x, pos.y, 0),
				Vector3(pos.x, end.y, 0),
				Vector3(end.x, end.y, 0),
				Vector3(end.x, pos.y, 0)
			]
		_:
			assert(false, "Invalid plane direction!!")
	
	# if direction is _MINUS, flip vertex order
	if direction & 0x1:
		var tmp : Vector3 = vertices[1]
		vertices[1] = vertices[3]
		vertices[3] = tmp
	
	return vertices
