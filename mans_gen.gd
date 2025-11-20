@tool
extends Node3D

var grid_map: GridMap = null
@export var mesh_library: MeshLibrary

const START_ROOM_SIZE : Vector2i = Vector2i(3, 3)
const HALLWAY_COUNT : int = 3

var room_tiles : Array[PackedVector3Array] = []
var room_positions : PackedVector3Array = []
var tree : BSPNodeI = null

# preset room sizes
var unique_rooms : Array[Vector2i] =\
[	Vector2i(2, 2), # Stairwell Size
	Vector2i(3, 3), # Garden Size
	Vector2i(3, 2), # Dining area Size
	Vector2i(2, 3), # Kitchen Size
	Vector2i(4, 2), # Gallery Size
	Vector2i(2, 2), # Bedroom Size
	Vector2i(3, 2), # Living Area Size
	Vector2i(2, 3),	# pool size
	Vector2i(2, 1)	# office
]

var repeatable_rooms : Array[Vector2i] =\
[
	Vector2i(3, 1), # generic wide hall 3
	Vector2i(1, 3), # generic long hall 3
	Vector2i(2, 1), # generic wide hall 2
	Vector2i(1, 2), # generic long hall 2
	Vector2i(2, 2), # Big Junction
	Vector2i(1, 1) 	# Small junction
]

@export_tool_button("Generate Mansion", "Callable") var generate_action = editor_generate
func editor_generate():
	await get_tree().process_frame
	generate_mansion()

@export var border_size : Vector2i = Vector2i(10, 12) : set = set_border_size
func set_border_size(val : Vector2i) -> void:
	border_size = val
	if Engine.is_editor_hint():
		visualize_border()

func _ready() -> void:
	generate_mansion()

func make_gridmap():
	grid_map = GridMap.new()
	grid_map.mesh_library = mesh_library
	grid_map.cell_octant_size = 8
	grid_map.cell_center_x = true
	grid_map.cell_center_y = true
	grid_map.cell_center_z = true
	grid_map.cell_size = Vector3(1, 1, 1)
	add_child(grid_map)

class _GenerationState:
	var start_room_leaf: BSPNodeI
	var hallways_node: BSPNodeI
	
var _generation_state: _GenerationState = null

func generate_mansion():
	if not grid_map:
		make_gridmap()
		
	_generation_state = _GenerationState.new()
	
	print(unique_rooms.size())
	tree = BSPNodeI.new(Rect2i(
	Vector2(0, 0), Vector2(border_size.x, border_size.y)))
	visualize_border()
	print("border visualized")
	#generate starting room
	place_start_room()
	print("start room placed")
	#generate hallways
	generate_hallways(_generation_state.hallways_node, HALLWAY_COUNT)
	print("hallways placed")
	
	#partition empty spaces until room fits
	generate_subrooms()

func visualize_border():
	grid_map.clear()
	for x in range(-1, border_size.x * 2):
		for y in range(-1, border_size.y * 2):
			grid_map.set_cell_item(Vector3i(x, 0, -1), 2)
			grid_map.set_cell_item(Vector3i(-1, 0, y), 2)
			grid_map.set_cell_item(Vector3i(x, 0, border_size.y * 2 -1), 2)
			grid_map.set_cell_item(Vector3i(border_size.x * 2 -1, 0, y), 2)
			
func place_start_room():
	var direction = randi() % 4
	var partition_room : BSPNodeI
	
	if direction == 0:
		partition_room = tree
		var partitions_tmp: Array[BSPNodeI]
		var partition_location = (randi_range(3, int(partition_room.size.x) - 4 - START_ROOM_SIZE.x))
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.HORIZONTAL, START_ROOM_SIZE.y)
		partition_room = partitions_tmp[0]
		_generation_state.hallways_node = partitions_tmp[1]
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.VERTICAL, partition_location)
		partition_room = partitions_tmp[1]
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.VERTICAL, START_ROOM_SIZE.x)
		partition_room = partitions_tmp[0]
		place_room(partition_room)
		_generation_state.start_room_leaf = partition_room
		
	elif direction == 1:
		partition_room = tree
		var partitions_tmp: Array[BSPNodeI]
		var partition_location = (randi_range(3, int(partition_room.size.y) - 4 - START_ROOM_SIZE.y))
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.VERTICAL, border_size.x - START_ROOM_SIZE.x)
		partition_room = partitions_tmp[1]
		_generation_state.hallways_node = partitions_tmp[0]
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.HORIZONTAL, partition_location)
		partition_room = partitions_tmp[1]
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.HORIZONTAL, START_ROOM_SIZE.y)
		partition_room = partitions_tmp[0]
		place_room(partition_room)
		_generation_state.start_room_leaf = partition_room
		
	elif direction == 2:
		partition_room = tree
		var partition_location = (randi_range(3, int(partition_room.size.x) - 4 - START_ROOM_SIZE.x))
		var partitions_tmp: Array[BSPNodeI]
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.HORIZONTAL, border_size.y - START_ROOM_SIZE.y)
		partition_room = partitions_tmp[1]
		_generation_state.hallways_node = partitions_tmp[0]
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.VERTICAL, partition_location)
		partition_room = partitions_tmp[1]
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.VERTICAL, START_ROOM_SIZE.x)
		partition_room = partitions_tmp[0]
		place_room(partition_room)
		_generation_state.start_room_leaf = partition_room
	else:
		partition_room = tree
		var partition_location = (randi_range(3, int(partition_room.size.y) - 4 - START_ROOM_SIZE.y))
		var partitions_tmp: Array[BSPNodeI]
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.VERTICAL, START_ROOM_SIZE.x)
		partition_room = partitions_tmp[0]
		_generation_state.hallways_node = partitions_tmp[1]
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.HORIZONTAL, partition_location)
		partition_room = partitions_tmp[1]
		partitions_tmp = partition_room.partition(BSPNodeI.PartitionDirection.HORIZONTAL, START_ROOM_SIZE.y)
		partition_room = partitions_tmp[0]
		place_room(partition_room)
		_generation_state.start_room_leaf = partition_room

func leaf_is_free(leaf: BSPNodeI) -> bool:
	return not leaf.data
	
func count_free_leafs(root: BSPNodeI = tree) -> int:
	return root.evaluate_tree(func(leaf, accum): 
		if not accum:
			accum = 0
		if not leaf.data:
			print(leaf.bounds)
			accum += 1
		else:
			print(leaf.bounds)
		return accum
		,
		true,
		0)

func place_room(room : BSPNodeI):
	fill_grid(Vector3i(room.position.x, 0, room.position.y), Vector2i(room.size.x, room.size.y), 0)
	room.data = &"BWEH"
	
func generate_hallways(hallway_room : BSPNodeI, recurse: int):
	if not hallway_room:
		return
	
	var hallway_partitions : Array[BSPNodeI] = []
	var cutloc : int = 0
	var hall_to_be_placed : BSPNodeI
	
	hallway_partitions.append(hallway_room)
	if recurse > 0 and hallway_room.bounds.get_area() >= 20\
	and hallway_room.size.x >3 and hallway_room.size.y > 3:	
		
		var slice_size: int
		var slice_direction: BSPNodeI.PartitionDirection
		if hallway_room.size.x > hallway_room.size.y:
			slice_size = hallway_room.size.x
			slice_direction = BSPNodeI.PartitionDirection.VERTICAL
		else:
			slice_size = hallway_room.size.y
			slice_direction = BSPNodeI.PartitionDirection.HORIZONTAL
		
		# vertical hallway
		if recurse < HALLWAY_COUNT:
			cutloc = (randi() % int(slice_size -2)) + 1
		else:
			cutloc = randi() % int(slice_size)
			
		hallway_partitions.append_array(\
		hallway_partitions.pop_front().partition(slice_direction, cutloc, true, true))
		hallway_partitions.append_array(\
		hallway_partitions.pop_back().partition(slice_direction, 1, true, true))
		#partition_rect_x(hallway_partitions.pop_back(), 1))
			
		# place hallway into correct area
		if hallway_partitions.size() == 2 and cutloc != 0:
			hall_to_be_placed = hallway_partitions.pop_back()
		else:
			hall_to_be_placed = hallway_partitions.pop_at(hallway_partitions.size() - 2)
		place_hallway(hall_to_be_placed)
		
		#find largest room
		var largest_index : int = 0
		var largest_area : int = 0
		for i in hallway_partitions.size():
			var area = hallway_partitions[i].bounds.get_area()
			if area > largest_area:
				largest_area = area
				largest_index = i	
		generate_hallways(hallway_partitions.pop_at(largest_index), recurse-1)
	pass
	
func generate_subrooms():
	
	var num_free_leafs = count_free_leafs()
	
	print(unique_rooms.size())
	print(num_free_leafs)
	
	while unique_rooms.size() > 0 and num_free_leafs > 0:
		var i : int = randi() % unique_rooms.size()
		var p_room_size : Vector2i = unique_rooms.pop_at(i)
		var place : BSPNodeI = find_suitable_placement_area(p_room_size)
		if place:
			place_room(place)
			num_free_leafs -= 1
			print("room placed")
			print(place.bounds)
	
# returns leaf that fits best, or null otherwise
func find_suitable_placement_area(room_size: Vector2i) -> BSPNodeI:
	# for possible scenarios for this function
	# 1 an existing partition that already fits the needed size is available
	# 2 an existing partition exists with the same width and greater length or same length and greater width
	# 3 both options are bigger
	# 4 no possible room
	var partitions = tree.collect()
	partitions.shuffle()
	var best: BSPNodeI = null # index to best fit partition in partition list
	var rank : int = 0 # 0 = no possible room, 1 = bigger room, 2 = fits smaller dimension, 3 = fits larger dimension
	for p in partitions:
		if p.data:
			continue
		if p.bounds.size == room_size:
			return p
		if p.bounds.size.x == room_size.x and p.bounds.size.y > room_size.y:
			if room_size.x > room_size.y and rank < 3:
				rank = 3
				best = p
			elif rank < 2:
				rank = 2
				best = p
		if p.bounds.size.y == room_size.y and p.bounds.size.x > room_size.x:
			if room_size.y > room_size.x and rank < 3:
				rank = 3
				best = p
			elif rank < 2:
				rank = 2
				best = p
		if p.bounds.size.x > room_size.x and p.bounds.size.y > room_size.y and rank < 1:
			rank = 1
			best = p
	
	# no fit
	if rank == 0:
		return null
	
	# partition to make matching partition in size
	var partition : BSPNodeI = best
	
	# increase rank
	if rank == 1:
		var r = randi() % 2
		if r:
			var tmp_partitions = partition.partition(
				BSPNodeI.PartitionDirection.VERTICAL, room_size.x )
			partition = tmp_partitions[0]
		else:
			var tmp_partitions = partition.partition(
				BSPNodeI.PartitionDirection.VERTICAL, partition.size.x - room_size.x )
			partition = tmp_partitions[1]
	
	if partition.size.x == room_size.x:
		var r = randi() % 2
		if r:
			var tmp_partitions = partition.partition(
				BSPNodeI.PartitionDirection.HORIZONTAL, room_size.y )
			partition = tmp_partitions[0]
		else:
			var tmp_partitions = partition.partition(
				BSPNodeI.PartitionDirection.HORIZONTAL, partition.size.y - room_size.y )
			partition = tmp_partitions[1]
		return partition
	elif partition.size.y == room_size.y:
		var r = randi() % 2
		if r:
			var tmp_partitions = partition.partition(
				BSPNodeI.PartitionDirection.VERTICAL, room_size.x )
			partition = tmp_partitions[0]
		else:
			var tmp_partitions = partition.partition(
				BSPNodeI.PartitionDirection.VERTICAL, partition.size.x - room_size.x )
			partition = tmp_partitions[1]
		return partition
	else:
		return null
	
func place_hallway(hall: BSPNodeI):
	place_room(hall)
	connect_hallways()
	
func connect_hallways():
	pass
	
func fill_grid(pos: Vector3i, size: Vector2i, fill: int):
	for c in size.x * 2 -1:
		for r in size.y * 2 -1:
			var fillpos: Vector3i = pos * 2 + Vector3i(c, 0, r)
			grid_map.set_cell_item(fillpos, fill)
	pass

func partition_rect_x(rect: Rect2i, cut_x: int) -> Array[Rect2i]:
	if cut_x > 0 and cut_x < rect.size.x:
		return [
			Rect2i(rect.position, Vector2i(cut_x, rect.size.y)),
			Rect2i(Vector2i(rect.position.x + cut_x, rect.position.y),
				Vector2i(rect.size.x - cut_x, rect.size.y))
		]
	else:
		return [rect]

func partition_rect_y(rect: Rect2i, cut_y: int) -> Array[Rect2i]:
	if cut_y > 0 and cut_y < rect.size.y:
		return [
			Rect2i(rect.position, Vector2i(rect.size.x, cut_y)),
			Rect2i(Vector2i(rect.position.x, rect.position.y + cut_y),
				Vector2i(rect.size.x, rect.size.y - cut_y))
		]
	else:
		return [rect]

# cutLoc is location to split
func partition_rect(rect: Rect2i, cutLoc: Vector2i) -> Array[Rect2i]:
	var new_rects_x : Array[Rect2i] = partition_rect_x(rect, cutLoc.x)
	var new_rects: Array[Rect2i]
	for rect_x in new_rects_x:
		new_rects.append_array(partition_rect_y(rect_x, cutLoc.y))
	return new_rects
