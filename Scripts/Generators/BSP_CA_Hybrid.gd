extends Node

class_name BSP_CA_Generator

var TNode = load("res://Scripts/BSP/TNode.gd")
var CellularAutomaton = load("res://Scripts/CA/CellularAutomaton.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")

var BSP_Generator = load("res://Scripts/Generators/BSP.gd")

var rng = null
var FLOOR = null
var WALLS = null

var m = {
	Constants.CA_Tiles.ALIVE: Constants.TileCodes.ROOM_FLOOR,
	Constants.CA_Tiles.DEAD: Constants.TileCodes.EMPTY,
}

func _fill_level(node):
	if node:
		_fill_level(node.left)
		_fill_level(node.right)

		# for x in range(node.x1(), node.x2()):
		# 	FLOOR[node.y1()][x] = FLOOR[node.y2()][x] = Constants.TileCodes.NODE_WALL

		# for y in range(node.y1(), node.y2()+1):
		# 	FLOOR[y][node.x1()] = FLOOR[y][node.x2()] = Constants.TileCodes.NODE_WALL

		if node.room:
			var r = node.room.matrix

			# for x in range(r.x1(), r.x2()+1):
			# 	WALLS[r.y1()][x] = Constants.TileCodes.NORTH_WALL
			# 	WALLS[r.y2()][x] = Constants.TileCodes.SOUTH_WALL

			# for y in range(r.y1(), r.y2()+1):
			# 	WALLS[y][r.x1()] = Constants.TileCodes.WEST_WALL
			# 	WALLS[y][r.x2()] = Constants.TileCodes.EAST_WALL

			# WALLS[r.y1()][r.x1()] = Constants.TileCodes.NW_CORNER
			# WALLS[r.y1()][r.x2()] = Constants.TileCodes.NE_CORNER
			# WALLS[r.y2()][r.x1()] = Constants.TileCodes.SW_CORNER
			# WALLS[r.y2()][r.x2()] = Constants.TileCodes.SE_CORNER

			for i in range(node.get_width()):
				for j in range(node.get_height()):
					FLOOR[node.y1() + j][node.x1() + i] = m[r[j][i]]

		if node.hall:
			var h = node.hall

			for x in range(h.x1(), h.x1() + h.get_width()):
				for y in range(h.y1(), h.y1() + h.get_height()):
					FLOOR[y][x] = Constants.TileCodes.ROOM_FLOOR
					
			var hall_direction = h.get_direction()

			if hall_direction == Constants.Direction.HORIZONTAL:
				for x in range(h.x1(), h.x1() + h.get_width()):
					WALLS[h.y1()][x] = Constants.TileCodes.NORTH_WALL
					WALLS[h.y2()][x] = Constants.TileCodes.SOUTH_WALL

				for y in range(h.y1(), h.y1() + h.get_height()):
					WALLS[y][h.x1()-1] = Constants.TileCodes.EMPTY
					WALLS[y][h.x2()] = Constants.TileCodes.EMPTY
			elif hall_direction == Constants.Direction.VERTICAL:
				for y in range(h.y1(), h.y1() + h.get_height()):
					WALLS[y][h.x1()] = Constants.TileCodes.WEST_WALL
					WALLS[y][h.x2()] = Constants.TileCodes.EAST_WALL

				for x in range(h.x1(), h.x1() + h.get_width()):
					WALLS[h.y1()-1][x] = Constants.TileCodes.EMPTY
					WALLS[h.y2()][x] = Constants.TileCodes.EMPTY


func _init_level(w, h):
	FLOOR = []
	WALLS = []

	for i in range(w):
		FLOOR.append([])
		WALLS.append([])

		for _j in range(h):
			FLOOR[i].append(Constants.TileCodes.EMPTY)
			WALLS[i].append(Constants.TileCodes.EMPTY)


func _generate_rooms(root):
	for leaf in root.get_leaves():
		var ca = CellularAutomaton.new(0.55, 6, 6, 2, rng)
		ca.do_process(leaf.get_width(), leaf.get_height())
		leaf.set_room(ca)


func _get_closest_points(node1, node2):
	var border_r1 = []
	var border_r2 = []

#	for i in range(node1.room.matrix[0].size()):
#		for j in range(node1.room.matrix.size()):
#			if node1.room.matrix[j][i] == Constants.CA_Tiles.DEAD:
#				c = count_objects_in_nb(get_von_neumann_neighbourhood(node1.room.matrix, i, j), SPACE)
#
#				if c > 0:
#					border_r1.append([node1.x1() + i, node1.y1() + j])
#
#	for i in range(node2.room.matrix[0].size()):
#		for j in range(node2.room.matrix.size()):
#			if node2.room.matrix[j][i] == Constants.CA_Tiles.DEAD:
#				c = count_objects_in_nb(get_von_neumann_neighbourhood(node2.room.matrix, i, j), SPACE)
#
#				if c > 0:
#					border_r2.append([node2.x1() + i, node2.y1() + j])

	var x1 = null
	var y1 = null
	var x2 = null
	var y2 = null

	var min_length = INF

#	for p1 in border_r1:
#		for p2 in border_r2:
#			var l = distance(p1, p2)
#
#			if l < min_length:
#				min_length = l
#				x1 = p1[0]
#				y1 = p1[1]
#				x2 = p2[0]
#				y2 = p2[1]

	return [x1, y1, x2+1, y2+1]


func _generate_halls(node):
	if node.left and not node.left.room:
		_generate_halls(node.left)

	if node.right and not node.right.room:
		_generate_halls(node.right)

	if node.left and node.right:
		if node.left.room and node.right.room:
			node.hall = _get_closest_points(node.left, node.right)
		elif node.left.hall and node.right.room:
			var left_leaves = node.left.get_leaves()

			node.hall = _get_closest_points(left_leaves[randi() % left_leaves.size()], node.right)
		elif node.left.room and node.right.hall:
			var right_leaves = node.right.get_leaves()

			node.hall = _get_closest_points(node.left, right_leaves[randi() % right_leaves.size()])
		elif node.left.hall and node.right.hall:
			var left_leaves = node.left.get_leaves()
			var right_leaves = node.right.get_leaves()

			node.hall = _get_closest_points(left_leaves[randi() % left_leaves.size()], right_leaves[randi() % right_leaves.size()])


func run(w, h):
	var bsp_gen = BSP_Generator.new(rng)
	var children = bsp_gen.generate_tree(0, w-1, 0, h-1)
	var root = TNode.new(children["left"], children["right"], 0, 0, w, h)

	_generate_rooms(root)
	_generate_halls(root)

	_init_level(w, h)
	_fill_level(root)


func get_map():
	return {
		"floor": FLOOR,
		"walls": WALLS
	}


func _init(_rng=null):
	if _rng:
		rng = _rng
	else:
		rng = RandomNumberGenerator.new()