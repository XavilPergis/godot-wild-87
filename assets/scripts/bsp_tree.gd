extends Object
class_name BSPTree

var width: float
var height: float

var root: BSPNode

func _init(p_bounds: Rect2):
	root = BSPNode.new(p_bounds, null)

class BSPNode:
	func _init(p_bounds: Rect2, p_parent: BSPNode):
		parent = p_parent
		bounds = p_bounds
		pass
	
	var parent: BSPNode = null
	var split_orientation: Orientation
	var split_dimension: float
	var child1: BSPNode = null
	var child2: BSPNode = null
	var empty: bool = true
	var bounds: Rect2
	
	func is_leaf() -> bool:
		return not child1
		
	func get_children() -> Array[BSPNode]:
		return [child1, child2]
	
	func divide(p_orientation: Orientation, p_dimension: float) -> Array[BSPNode]:
		assert(is_leaf())
		
		split_orientation = p_orientation
		split_dimension = p_dimension
		var bounds1 = Rect2(bounds)
		var bounds2 = Rect2(bounds)
		
		match split_orientation:
			VERTICAL:
				assert(split_dimension > bounds.position.x and split_dimension < bounds.end.x)
				bounds1 = bounds.grow_side(SIDE_RIGHT, split_dimension - bounds.end.x)
				bounds2 = bounds.grow_side(SIDE_LEFT, bounds.position.x - split_dimension)
				pass
			HORIZONTAL:
				assert(split_dimension > bounds.position.y and split_dimension < bounds.end.y)
				bounds1 = bounds.grow_side(SIDE_BOTTOM, split_dimension - bounds.end.y)
				bounds2 = bounds.grow_side(SIDE_TOP, bounds.position.y - split_dimension)
				pass
		
		child1 = BSPNode.new(bounds1, self)
		child2 = BSPNode.new(bounds2, self)
		return [child1, child2]
		
	
