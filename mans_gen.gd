@tool
extends Node3D

@onready var grid_map: GridMap = $GridMap

const START_ROOM_SIZE : Vector2i = Vector2i(3, 3)
const HALLWAY_COUNT : int = 3

var room_tiles : Array[PackedVector3Array] = []
var room_positions : PackedVector3Array = []
var partitions : Array[PackedVector2Array] = []

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

@export var start : bool = false : set = set_start
func set_start(val_bool)->void:
	if Engine.is_editor_hint():
		await get_tree().process_frame
		generate_mansion()

@export var border_size : Vector2i = Vector2i(10, 12) : set = set_border_size
func set_border_size(val : Vector2i) -> void:
	border_size = val
	if Engine.is_editor_hint():
		visualize_border()

func _ready() -> void:
	generate_mansion()

func generate_mansion():
	print(unique_rooms.size())
	partitions.clear()
	partitions.append(PackedVector2Array(\
	[Vector2(0, 0), Vector2(border_size.x, border_size.y)]))
	visualize_border()
	print("border visualized")
	#generate starting room
	place_start_room()
	print("start room placed")
	#generate hallways
	generate_hallways(partitions.pop_front(), HALLWAY_COUNT)
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
	var start_pos : Vector3i = Vector3i(0, 0, 0)
	var partition_room : PackedVector2Array
	
	if direction == 0:
		partition_room = partitions.pop_front()
		var partition_location = (randi_range(3, int(partition_room[1].x) - 4 - START_ROOM_SIZE.x))
		partitions.append_array(partition_rect(partition_room, Vector2i(0, START_ROOM_SIZE.y)))
		partition_room = partitions.pop_front()
		partitions.append_array(partition_rect(partition_room, Vector2i(partition_location, 0)))
		partition_room = partitions.pop_back()
		partitions.append_array(partition_rect(partition_room, Vector2i(START_ROOM_SIZE.x, 0)))
		partition_room = partitions.pop_at(partitions.size() - 2)
		place_room(partition_room)
		
	elif direction == 1:
		partition_room = partitions.pop_front()
		var partition_location = (randi_range(3, int(partition_room[1].y) - 4 - START_ROOM_SIZE.y))
		partitions.append_array(partition_rect(partition_room, \
		Vector2i(border_size.x - START_ROOM_SIZE.x, 0)))
		partition_room = partitions.pop_back()
		partitions.append_array(partition_rect(partition_room, Vector2i(0, partition_location)))
		partition_room = partitions.pop_back()
		partitions.append_array(partition_rect(partition_room, Vector2i(0, START_ROOM_SIZE.y)))
		partition_room = partitions.pop_at(partitions.size() - 2)
		place_room(partition_room)
		
	elif direction == 2:
		partition_room = partitions.pop_front()
		var partition_location = (randi_range(3, int(partition_room[1].x) - 4 - START_ROOM_SIZE.x))
		partitions.append_array(partition_rect(partition_room, \
		Vector2i(0, border_size.y - START_ROOM_SIZE.y)))
		partition_room = partitions.back()
		partitions.append_array(partition_rect(partition_room, Vector2i(partition_location, 0)))
		partition_room = partitions.pop_back()
		partitions.append_array(partition_rect(partition_room, Vector2i(START_ROOM_SIZE.x, 0)))
		partition_room = partitions.pop_at(partitions.size() - 2)
		place_room(partition_room)
	else:
		partition_room = partitions.pop_front()
		var partition_location = (randi_range(3, int(partition_room[1].y) - 4 - START_ROOM_SIZE.y))
		partitions.append_array(partition_rect(partition_room, \
		Vector2i(START_ROOM_SIZE.x, 0)))
		partition_room = partitions.pop_front()
		partitions.append_array(partition_rect(partition_room, Vector2i(0, partition_location)))
		partition_room = partitions.pop_back()
		partitions.append_array(partition_rect(partition_room, Vector2i(0, START_ROOM_SIZE.y)))
		partition_room = partitions.pop_at(partitions.size() - 2)
		place_room(partition_room)
	
func place_room(room : PackedVector2Array):
	fill_grid(Vector3i(room[0].x, 0, room[0].y), Vector2i(room[1].x, room[1].y), 0)
	
func generate_hallways(hallway_room : PackedVector2Array, recurse: int):
	var hallway_partitions : Array[PackedVector2Array] = []
	var cutloc : int = 0
	var hall_to_be_placed : PackedVector2Array
	
	hallway_partitions.append(hallway_room)
	if recurse > 0 and (hallway_room[1].x * hallway_room[1].y) >= 20\
	and hallway_room[1].x >3 and hallway_room[1].y > 3:	
		var is_vert = false
		if hallway_room[1].x > hallway_room[1].y:
			is_vert = true
		
		if is_vert:
			
			if recurse < HALLWAY_COUNT:
				cutloc = (randi() % int(hallway_room[1].x -2)) + 1
			else:
				cutloc = randi() % int(hallway_room[1].x)
				
			hallway_partitions.append_array(\
			partition_rect(hallway_partitions.pop_front(), Vector2i(cutloc, 0)))
			hallway_partitions.append_array(\
			partition_rect(hallway_partitions.pop_back(), Vector2i(1, 0)))
		else:
			if recurse < HALLWAY_COUNT:
				cutloc = (randi() % int(hallway_room[1].y -2)) + 1
			else:
				cutloc = randi() % int(hallway_room[1].y)
				
			hallway_partitions.append_array(\
			partition_rect(hallway_partitions.pop_front(), Vector2i(0, cutloc)))
			hallway_partitions.append_array(\
			partition_rect(hallway_partitions.pop_back(), Vector2i(0, 1)))
			
		# place hallway into correct area
		if hallway_partitions.size() == 2 and cutloc != 0:
			hall_to_be_placed = hallway_partitions.pop_back()
		else:
			hall_to_be_placed = hallway_partitions.pop_at(hallway_partitions.size() - 2)
		place_hallway(hall_to_be_placed)
		
		#find largest room
		var bsi : int = 0
		var bhs : int = 0
		for i in hallway_partitions.size():
			if hallway_partitions[i][1].x * hallway_partitions[i][1].y > bhs:
				bhs = hallway_partitions[i][1].x * hallway_partitions[i][1].y
				bsi = i	
		generate_hallways(hallway_partitions.pop_at(bsi), recurse-1)
	partitions.append_array(hallway_partitions)
	pass
	
func generate_subrooms():
	var index_array : Array[int] = []
	for i in partitions.size():
		index_array.append(i)
	index_array.sort()
	
	print(unique_rooms.size())
	print(partitions.size())
	while unique_rooms.size() > 0 and partitions.size() > 0:
		var i : int = randi() % unique_rooms.size()
		var p_room_size : Vector2i = unique_rooms.pop_at(i)
		var place_i : int = find_suitable_placement_area(p_room_size)
		var room : PackedVector2Array = partitions.pop_at(place_i)
		place_room(room)
		print("room placed")
		print(room)
	
	# returns index to partition that fits best, or -1 otherwise
func find_suitable_placement_area(room_size: Vector2i) -> int:
	# for possible scenarios for this function
	# 1 an existing partition that already fits the needed size is available
	# 2 an existing partition exists with the same width and greater length or same length and greater width
	# 3 both options are bigger
	# 4 no possible room
	var index_array : Array[int] = []
	for i in partitions.size():
		index_array.append(i)
	index_array.shuffle()
	var ibf : int = -1 # index to best fit partition in partition list
	var rank : int = 0 # 0 = no possible room, 1 = bigger room, 2 = fits smaller dimension, 3 = fits larger dimension
	for i in partitions.size():
		var p : PackedVector2Array = partitions[index_array[i]]
		if p[1].x == room_size.x and p[1].y == room_size.y:
			return index_array[i]
		if p[1].x == room_size.x and p[1].y > room_size.y:
			if room_size.x > room_size.y and rank < 3:
				rank = 3
				ibf = index_array[i]
			elif rank < 2:
				rank = 2
				ibf = index_array[i]
		if p[1].y == room_size.y and p[1].x > room_size.x:
			if room_size.y > room_size.x and rank < 3:
				rank = 3
				ibf = index_array[i]
			elif rank < 2:
				rank = 2
				ibf = index_array[i]
		if p[1].x > room_size.x and p[1].y > room_size.y and rank < 1:
			rank = 1
			ibf = index_array[i]
	
	# no fit
	if rank == 0:
		return -1
	
	# partition to make matching partition in size
	var partition : PackedVector2Array = partitions.pop_at(ibf)
	var tmp_partitions : Array[PackedVector2Array] = []
	
	# increase rank
	if rank == 1:
		var r = randi() % 2
		if r:
			tmp_partitions.append_array(\
			partition_rect(partition, Vector2i(room_size.x, 0)))
			partition = tmp_partitions.pop_front()
		else:
			tmp_partitions.append_array(\
			partition_rect(partition, Vector2i(partition[1].x - room_size.x, 0)))
			partition = tmp_partitions.pop_back()
		partitions.append_array(tmp_partitions)
		tmp_partitions.clear()
	
	if partition[1].x == room_size.x:
		var r = randi() % 2
		if r:
			tmp_partitions.append_array(\
			partition_rect(partition, Vector2i(0, room_size.y)))
			partition = tmp_partitions.pop_front()
		else:
			tmp_partitions.append_array(\
			partition_rect(partition, Vector2i(0, partition[1].y - room_size.y)))
			partition = tmp_partitions.pop_back()
		partitions.append_array(tmp_partitions)
		partitions.append(partition)
		return partitions.size() - 1
	elif partition[1].y == room_size.y:
		var r = randi() % 2
		if r:
			tmp_partitions.append_array(\
			partition_rect(partition, Vector2i(room_size.x, 0)))
			partition = tmp_partitions.pop_front()
		else:
			tmp_partitions.append_array(\
			partition_rect(partition, Vector2i(partition[1].x - room_size.x, 0)))
			partition = tmp_partitions.pop_back()
		partitions.append_array(tmp_partitions)
		partitions.append(partition)
		return partitions.size() - 1
	return -1
	
func place_hallway(hall: PackedVector2Array):
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

# rect[0] is square position and rect[1] is size
# cutLoc is location to split
func partition_rect(rect: PackedVector2Array, cutLoc: Vector2i) -> Array[PackedVector2Array]:
	var new_rects : Array[PackedVector2Array]
	if cutLoc.x > 0 and cutLoc.x < rect[1].x:
		new_rects.append(PackedVector2Array(\
		[Vector2(rect[0].x, rect[0].y), Vector2(cutLoc.x, rect[1].y)]))
		
		new_rects.append(PackedVector2Array(\
		[Vector2(rect[0].x + cutLoc.x, rect[0].y), \
		Vector2(rect[1].x - cutLoc.x, rect[1].y)]))
		if cutLoc.y > 0 and cutLoc.y < rect[1].y:
			var tmpRect : PackedVector2Array = new_rects.pop_front()
			new_rects.append_array(partition_rect(tmpRect, Vector2i(0, cutLoc.y)))
			tmpRect = new_rects.pop_front()
			new_rects.append_array(partition_rect(tmpRect, Vector2i(0, cutLoc.y)))
	elif cutLoc.y > 0 and cutLoc.y < rect[1].y:
		new_rects.append(PackedVector2Array(\
		[Vector2(rect[0].x, rect[0].y), Vector2(rect[1].x, cutLoc.y)]))
		
		new_rects.append(PackedVector2Array(\
		[Vector2(rect[0].x, rect[0].y + cutLoc.y), \
		Vector2(rect[1].x, rect[1].y - cutLoc.y)]))
	else:
		new_rects.append(rect)
	return new_rects
