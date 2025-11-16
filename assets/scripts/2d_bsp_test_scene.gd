extends Node2D

var tree: BSPTree

func _ready() -> void:
	tree = BSPTree.new(Rect2(0, 0, 20, 20))
	randomize()
	#for child in tree.root.divide(VERTICAL, 5.0):
	#	child.set_meta("COLOR", Color(randf(), randf(), randf()))
	fill_bsp_tree(tree.root, 10)
	pass
	
func fill_bsp_tree(root: BSPTree.BSPNode, num_leafs: int):
	if num_leafs <= 1:
		root.set_meta("COLOR", Color(randf(), randf(), randf()))
		return
	
	var left_leafs = 1;
	var right_leafs = 1;
	
	if num_leafs > 2:
		left_leafs = randi_range(1, num_leafs - 1)
		right_leafs = num_leafs - left_leafs
	
	match randi_range(0, 1):
		0:
			# vertical split
			var split_dimension = root.bounds.position.x + root.bounds.size.x * (randf() * 0.8 + 0.1)
			print("V Split:")
			print(left_leafs)
			print(right_leafs)
			print(split_dimension)
			var children = root.divide(VERTICAL, split_dimension)
			fill_bsp_tree(children[0], left_leafs)
			fill_bsp_tree(children[1], right_leafs)
		1:
			# horizontal split
			var split_dimension = root.bounds.position.y + root.bounds.size.y * (randf() * 0.8 + 0.1)
			print("H Split:")
			print(left_leafs)
			print(right_leafs)
			print(split_dimension)
			var children = root.divide(HORIZONTAL, split_dimension)
			fill_bsp_tree(children[0], left_leafs)
			fill_bsp_tree(children[1], right_leafs)
			pass
	
func draw_bsp_node(p_node: BSPTree.BSPNode):
	if p_node.is_leaf():
		draw_rect(p_node.bounds, p_node.get_meta("COLOR"), true)
	else:
		for child in p_node.get_children():
			draw_bsp_node(child)
	pass
	
func _draw() -> void:
	draw_bsp_node(tree.root)
	pass
