extends RefCounted
class_name BSPNodeI

var size: Vector2i:
	set(_p_size):
		bounds.size = _p_size
	get():
		return bounds.size

var position: Vector2i:
	set(_p_pos):
		bounds.position = _p_pos
	get():
		return bounds.position

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
	
func is_descendant_of(who: BSPNodeI) -> bool:
	if not parent:
		return false
	else:
		var parent_ref = parent.get_ref()
		if not parent_ref:
			return false
		elif parent_ref == who:
			return true
		else:
			return parent.get_ref().is_descendant_of(who)

func get_children() -> Array[BSPNodeI]:
	return [_left_child, _right_child]
	
func collect() -> Array[BSPNodeI]:
	if is_leaf():
		return [self]
	else:
		var collection: Array[BSPNodeI] = _left_child.collect()
		collection.append_array(_right_child.collect())
		return collection

func collect_in_region(region: Rect2i) -> Array[BSPNodeI]:
	if not region.intersects(self.bounds):
		return []
	elif is_leaf():
		return [self]
	else:
		var collection: Array[BSPNodeI] = _left_child.collect_in_region(region)
		collection.append_array(_right_child.collect_in_region(region))
		return collection

func count_leafs() -> int:
	if not _left_child:
		return 1
	else:
		return _left_child.count_descendants() +\
			_right_child.count_descendants()

func partition(direction: PartitionDirection, dimension: int, relative: bool = true, self_if_fail: bool = false) -> Array[BSPNodeI]:
	assert(not _left_child and not _right_child, "Cannot partition: already has children!!")
	
	var children_bounds = _partition_recti(bounds, direction, dimension, relative)
	if children_bounds.size() < 2:
		if self_if_fail:
			return [self]
		else:
			return []
	else:
		partition_direction = direction
		_left_child = BSPNodeI.new(children_bounds[0], self)
		_right_child = BSPNodeI.new(children_bounds[1], self)
		return [_left_child, _right_child]

static func _partition_recti(rect: Rect2i, direction: PartitionDirection,\
		dimension: int, relative: bool) -> Array[Rect2i]:
	match direction:
		PartitionDirection.VERTICAL:
			if not relative:
				dimension -= rect.position.x
			if dimension <= 0 || dimension >= rect.size.x:
				return [rect]
			else:
				return [
				Rect2i(rect.position, Vector2i(dimension, rect.size.y)),
				Rect2i(
					Vector2i(rect.position.x + dimension, rect.position.y),
					Vector2i(rect.size.x - dimension, rect.size.y)
				)]
		PartitionDirection.HORIZONTAL:
			if not relative:
				dimension -= rect.position.y
			if dimension <= 0 || dimension >= rect.size.y:
				return [rect]
			else:
				return [
				Rect2i(rect.position, Vector2i(rect.size.x, dimension)),
				Rect2i(
					Vector2i(rect.position.x, rect.position.y + dimension),
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
			accum = expression.call(self, accum)
		accum = _left_child.evaluate_tree(expression, leafs_only, accum)
		accum = _right_child.evaluate_tree(expression, leafs_only, accum)
	return accum

func remove_children():
	_left_child.parent = null
	_right_child.parent = null
	_left_child = null
	_right_child = null
