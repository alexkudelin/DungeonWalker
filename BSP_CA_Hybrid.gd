extends Node

class_name BSP_CA_Generator

var TNode = load("res://TNode.gd")
var BSP_Generator = load("res://BSP.gd")

var rng = null
var FLOOR = null
var WALLS = null


func _fill_level(node):
	if node:
		_fill_level(node.left)
		_fill_level(node.right)

		# for x in range(node.x1(), node.x2()):
		# 	FLOOR[node.y1()][x] = FLOOR[node.y2()][x] = Constants.TileCodes.NODE_WALL

		# for y in range(node.y1(), node.y2()+1):
		# 	FLOOR[y][node.x1()] = FLOOR[y][node.x2()] = Constants.TileCodes.NODE_WALL

		if node.room:
			var r = node.room

			for x in range(r.x1(), r.x2()+1):
				WALLS[r.y1()][x] = Constants.TileCodes.NORTH_WALL
				WALLS[r.y2()][x] = Constants.TileCodes.SOUTH_WALL

			for y in range(r.y1(), r.y2()+1):
				WALLS[y][r.x1()] = Constants.TileCodes.WEST_WALL
				WALLS[y][r.x2()] = Constants.TileCodes.EAST_WALL

			WALLS[r.y1()][r.x1()] = Constants.TileCodes.NW_CORNER
			WALLS[r.y1()][r.x2()] = Constants.TileCodes.NE_CORNER
			WALLS[r.y2()][r.x1()] = Constants.TileCodes.SW_CORNER
			WALLS[r.y2()][r.x2()] = Constants.TileCodes.SE_CORNER

			for x in range(r.x1(), r.x2()+1):
				for y in range(r.y1(), r.y2()+1):
					FLOOR[y][x] = Constants.TileCodes.ROOM_FLOOR

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


func run(w, h):
	var bsp_gen = BSP_Generator.new(rng)
	var children = bsp_gen.generate_tree(0, w-1, 0, h-1)
	var root = TNode.new(children["left"], children["right"], 0, 0, w, h)

	# generate_rooms(root)
	# generate_halls(root)

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
