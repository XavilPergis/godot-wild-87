extends RefCounted
class_name BSPNodeI

var bounds: Rect2i
var parent: WeakRef = null
var data = null
var partition_direction: PartitionDirection

var _left_child: BSPNodeI = null
var _right_child: BSPNodeI = null

enum PartitionDirection {
	VERTICAL,
	HORIZONTAL
}

func _init(p_bounds: Rect2i, p_parent: BSPNodeI = null):
	bounds = p_bounds
	if p_parent:
		parent = weakref(p_parent)

func is_leaf() -> bool:
	return not _left_child and not _right_child

func get_children() -> Array[BSPNodeI]:
	return [_left_child, _right_child]
	
func partition(direction: PartitionDirection, dimension: int, relative: bool = true) -> Array[BSPNodeI]:
	assert(not _left_child and not _right_child, "Cannot partition: already has children!!")
	
	partition_direction = direction
	var children_bounds = _partition_recti(bounds, direction, dimension, relative)
	_left_child = BSPNodeI.new(children_bounds[0], self)
	_right_child = BSPNodeI.new(children_bounds[1], self)
	
	return [_left_child, _right_child]

static func _partition_recti(rect: Rect2i, direction: PartitionDirection,\
		dimension: int, relative: bool) -> Array[Rect2i]:
	match direction:
		PartitionDirection.VERTICAL:
			if not relative:
				dimension -= rect.position.x
			return [
			Rect2i(rect.position, Vector2i(dimension, rect.size.y)),
			Rect2i(
				Vector2i(rect.position.x + dimension, rect.position.y),
				Vector2i(rect.size.x - dimension, rect.size.y)
			)]
		PartitionDirection.HORIZONTAL:
			if not relative:
				dimension -= rect.position.y
			return [
			Rect2i(rect.position, Vector2i(rect.size.x, dimension)),
			Rect2i(
				Vector2i(rect.position.y, rect.position.y + dimension),
				Vector2i(rect.size.x, rect.size.y - dimension)
			)]
		_:
			assert(false, "Invalid partition direction!!")
			return []

func evaluate_in_region(region: Rect2i, expression: Callable, leafs_only = true, accum = null):
	if not region.intersects(bounds):
		return null
	else:
		return _evaluate_in_region_recurse(region, expression, leafs_only, accum)

func _evaluate_in_region_recurse(region: Rect2i, expression: Callable, leafs_only = true, accum = null):
	if region.encloses(bounds):
		return evaluate_tree(expression, leafs_only, accum)
	elif not _left_child:
		# leaf
		return expression.call(self, accum)
	else:
		if not leafs_only:
			accum = expression.call(self, accum)
		if region.intersects(_left_child.bounds):
			accum = _left_child._evaluate_in_region_recurse(region, expression, leafs_only, accum)
		if region.intersects(_right_child.bounds):
			accum = _right_child._evaluate_in_region_recurse(region, expression, leafs_only, accum)
		return accum

func evaluate_tree(expression: Callable, leafs_only = true, accum = null):
	if not _left_child:
		# leaf
		return expression.call(self, accum)
	else:
		if not leafs_only:
			accum = expression.call(self, leafs_only, accum)
		accum = _left_child.evaluate_tree(expression, leafs_only, accum)
		accum = _right_child.evaluate_tree(expression, leafs_only, accum)
	return accum

func remove_children():
	_left_child.parent = null
	_right_child.parent = null
	_left_child = null
	_right_child = null
