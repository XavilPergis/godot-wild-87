extends Node3D

func _ready() -> void:
	var new_rooms : Array[PackedVector2Array] = \
	partition_rect(PackedVector2Array([Vector2(1, 2), Vector2(5, 3)]), Vector2i(3, 2))
	print(new_rooms)

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
	else:
		new_rects.append(PackedVector2Array(\
		[Vector2(rect[0].x, rect[0].y), Vector2(rect[1].x, cutLoc.y)]))
		
		new_rects.append(PackedVector2Array(\
		[Vector2(rect[0].x, rect[0].y + cutLoc.y), \
		Vector2(rect[1].x, rect[1].y - cutLoc.y)]))
	return new_rects
