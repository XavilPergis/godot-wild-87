extends Object
class_name QuadsMeshMaker

static func make_shape(quads: Array[Rect2]) -> ConcavePolygonShape3D:
	var triangles = PackedVector3Array()
	
	for quad in quads:
		var x0 = quad.position.x
		var x1 = quad.end.x
		var y0 = quad.position.y
		var y1 = quad.end.y
		
		var verts = _quad_to_vertices(quad)
		
		triangles.append_array([
			verts[0], verts[1], verts[2],
			verts[0], verts[2], verts[3]
		])
		
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(triangles)
	return shape

static func make_mesh(quads: Array[Rect2]) -> ArrayMesh:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
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
		
		verts.append_array(_quad_to_vertices(quad))
		
		uvs.append_array([
			Vector2(x0, -y0),
			Vector2(x1, -y0),
			Vector2(x1, -y1),
			Vector2(x0, -y1)
		])
		
		normals.append_array([
			Vector3.UP,
			Vector3.UP,
			Vector3.UP,
			Vector3.UP
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

static func _quad_to_vertices(quad: Rect2) -> PackedVector3Array:
	var x0 = quad.position.x
	var x1 = quad.end.x
	var y0 = quad.position.y
	var y1 = quad.end.y
	
	return [
		Vector3(x0, 0, y0),
		Vector3(x1, 0, y0),
		Vector3(x1, 0, y1),
		Vector3(x0, 0, y1)
	]
