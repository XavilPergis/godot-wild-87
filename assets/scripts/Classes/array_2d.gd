class_name Array2D

var array: Array[Array] = []
var size: Vector2i = Vector2i(0, 0)

func _init(width: int, length: int, initVal) -> void:
	if width > 0 and length > 0:
		for x in width:
			array.append([])
			for y in length:
				array[x].append(initVal);
		size = Vector2i(width, length)
	else:
		push_error("can't have 2d array with values less than or equal to 0")

func get_val(x: int, y: int):
	if x >= 0 and x < size.x and y >= 0 and y < size.y:
		return array[x][y]
	
func set_val(x: int, y: int, value):
	if x >= 0 and x < size.x and y >= 0 and y < size.y:
		array[x][y] = value

func fill(fillPos: Vector2i, fillSize: Vector2i, fillVal):
	if fillSize.x > 0 and fillSize.y > 0 and fillPos.x >= 0 and fillPos.y >=0 \
	and fillPos.x + fillSize.x <= size.x and fillPos.y + fillSize.y <= size.y:
		for x in range(fillPos.x, fillPos.x + fillSize.x):
			for y in range(fillPos.y, fillPos.y + fillSize.y):
				array[x][y] = fillVal
				
func printGrid():
	for y in size.y:
		var row_string = ""
		for x in size.x:
			row_string += str(array[x][y])
		print(row_string)
	
	
