@tool
extends Node3D
class_name RoomWall

@export_range(0.01, 999999) var width: float = 1:
	set(p_width):
		if p_width != width:
			if p_width < 0.01:
				p_width = 0.01
			width = p_width
			if Engine.is_editor_hint():
				build()

@export_range(0.01, 999999) var height: float = 1:
	set(p_height):
		if p_height != height:
			if p_height < 0.01:
				p_height = 0.01
			height = p_height
			if Engine.is_editor_hint():
				build()
				
@export var direction : QuadsMeshMaker.PlaneDirection:
	set(p_direction):
		if p_direction != direction:
			direction = p_direction
			if Engine.is_editor_hint():
				build()

@export var material: Material:
	set(p_material):
		material = p_material
		if Engine.is_editor_hint():
			if _mesh_instance:
				_mesh_instance.mesh.surface_set_material(0, material)

# we assume this is sorted
# very quick and dirty way of getting doorways into these walls
var connection_slots: PackedInt32Array = []
var doorway_height: float = 2.2
var quads: Array[Rect2]

var _mesh_instance: MeshInstance3D = null
var _static_body: StaticBody3D = null
var _shape_owner: int = 0

func _ready():
	build()

func build():
	build_quads()
	build_physics()
	build_visual()

func build_quads():
	quads.clear()
	
	var i: int = 0
	var effective_doorway_height = min(doorway_height, height)
	
	for conn in connection_slots:
		if conn > i:
			quads.append(Rect2(
				i, 0, conn - i, effective_doorway_height
			))
		i = conn + 1
	
	if i < width:
		quads.append(Rect2(
			i, 0, width - i, effective_doorway_height
		))
	
	if doorway_height < height:
		quads.append(Rect2(
			0, doorway_height,
			width, height-doorway_height
		))

func build_physics():
	if not _static_body:
		_static_body = StaticBody3D.new()
		_shape_owner = _static_body.create_shape_owner(self)
		add_child(_static_body)
	else:
		_static_body.shape_owner_clear_shapes(_shape_owner)
	
	var shape = QuadsMeshMaker.make_shape(quads, direction)
	_static_body.shape_owner_add_shape(_shape_owner, shape)

func build_visual():
	if not _mesh_instance:
		_mesh_instance = MeshInstance3D.new()
		add_child(_mesh_instance)

	var mesh = QuadsMeshMaker.make_mesh(quads, direction)
	mesh.surface_set_material(0, material)
	
	_mesh_instance.mesh = mesh
