extends Node

class_name BSP_CA_Generator

var BSPNode = load("res://Scripts/BSP/BSPNode.gd")
var CellularAutomaton = load("res://Scripts/CA/CellularAutomaton.gd")
var CARoom = load("res://Scripts/CA/Room.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")
var Utils = load("res://Scripts/Utils/Utils.gd")

var BSP_Generator = load("res://Scripts/Generators/BSP.gd")

var rng = null

var FLOOR = null
var WALLS = null

var m = {
	Constants.CA_Tiles.ALIVE: [Constants.TileCodes.ROOM_FLOOR],
	Constants.CA_Tiles.OUTLINE: [Constants.TileCodes.ROOM_FLOOR],
	Constants.CA_Tiles.DEAD: [Constants.TileCodes.EMPTY],
}

func _fill_level(node):
	if node:
		_fill_level(node.left)
		_fill_level(node.right)

		if node.room:
			var r = node.room

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

			for i in range(r.get_width()):
				for j in range(r.get_height()):
					FLOOR[r.y1() + j][r.x1() + i] = m[r.ca.matrix[j][i]][0]

		for x in range(node.x1(), node.x2()):
			FLOOR[node.y1()][x] = Constants.TileCodes.NODE_WALL
			FLOOR[node.y2()][x] = Constants.TileCodes.NODE_WALL

		for y in range(node.y1(), node.y2()+1):
			FLOOR[y][node.x1()] = Constants.TileCodes.NODE_WALL
			FLOOR[y][node.x2()] = Constants.TileCodes.NODE_WALL

		if node.hall:
			for p in Utils.line([node.hall[0], node.hall[1]], [node.hall[2], node.hall[3]]):
				var x = int(p[0])
				var y = int(p[1])

				if FLOOR[y][x] != Constants.CA_Tiles.ALIVE:
					FLOOR[y][x] = m[Constants.CA_Tiles.ALIVE][0]


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
		var ca = CellularAutomaton.new(0.475, 4, 6, 3, rng)
		ca.do_process(leaf.get_width()-2, leaf.get_height()-2)
		leaf.set_room(CARoom.new(
			ca, leaf.x1() + 1, leaf.y1() + 1, leaf.get_width()-2, leaf.get_height()-2
		))


func _get_closest_points(room1, room2):
	var border_r1 = []
	var border_r2 = []

	for i in range(room1.get_width()):
		for j in range(room1.get_height()):
			if room1.ca.matrix[j][i] == Constants.CA_Tiles.ALIVE:
				if Utils.count_objects_in_nb(Utils.get_von_neumann_nb(room1.ca.matrix, i, j), [Constants.CA_Tiles.ALIVE]) > 0:
					border_r1.append([room1.x1()+i, room1.y1()+j])

	for i in range(room2.get_width()):
		for j in range(room2.get_height()):
			if room2.ca.matrix[j][i] == Constants.CA_Tiles.ALIVE:
				if Utils.count_objects_in_nb(Utils.get_von_neumann_nb(room2.ca.matrix, i, j), [Constants.CA_Tiles.ALIVE]) > 0:
					border_r2.append([room2.x1()+i, room2.y1()+j])

	var x1 = null
	var y1 = null
	var x2 = null
	var y2 = null

	var min_length = INF

	for p1 in border_r1:
		for p2 in border_r2:
			var l = Utils.distance(p1, p2)

			if l < min_length:
				min_length = l
				x1 = p1[0]
				y1 = p1[1]
				x2 = p2[0]
				y2 = p2[1]

	return [x1, y1, x2+1, y2+1]


func _generate_halls(node):
	if node.left and not node.left.room:
		_generate_halls(node.left)

	if node.right and not node.right.room:
		_generate_halls(node.right)

	if node.left and node.right:
		if node.left.room and node.right.room:
			node.hall = _get_closest_points(node.left.room, node.right.room)
		elif node.left.hall and node.right.room:
			var left_rooms = node.left.get_rooms()
			node.hall = _get_closest_points(left_rooms[randi() % left_rooms.size()], node.right.room)
		elif node.left.room and node.right.hall:
			var right_rooms = node.right.get_rooms()
			node.hall = _get_closest_points(node.left.room, right_rooms[randi() % right_rooms.size()])
		elif node.left.hall and node.right.hall:
			var left_rooms = node.left.get_rooms()
			var right_rooms = node.right.get_rooms()

			node.hall = _get_closest_points(left_rooms[randi() % left_rooms.size()], right_rooms[randi() % right_rooms.size()])


func run(w, h):
	var bsp_gen = BSP_Generator.new(rng)
	var children = bsp_gen.generate_tree(0, w-1, 0, h-1)
	var root = BSPNode.new(children["left"], children["right"], 0, 0, w, h)

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
