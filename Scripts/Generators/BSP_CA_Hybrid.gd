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

func _outline():
	var w = len(FLOOR[0])
	var h = len(FLOOR)

	var outline = []

	for x in range(w):
		for y in range(h):
			if FLOOR[y][x] == Constants.FloorTileCode.MID_FLOOR:
				for nb in Utils.get_moore_nb(FLOOR, x, y):
					if nb and nb[2] == Constants.FloorTileCode.EMPTY:
						outline.append(nb)

	for item in outline:
		WALLS[item[1]][item[0]] = Constants.WallTileCode.MID_WALL
		FLOOR[item[1]][item[0]] = Constants.FloorTileCode.MID_FLOOR


func _fill_singles():
	var w = len(FLOOR[0])
	var h = len(FLOOR)

	var singles_walls = []
	var singles_floors = []

	while true:
		for x in range(w):
			for y in range(h):
				if FLOOR[y][x] == Constants.FloorTileCode.EMPTY:
					var nbhood = Utils.get_moore_nb(WALLS, x, y)

					if Utils.count_objects_in_nb(nbhood, [Constants.WallTileCode.MID_WALL]) >= 7:
						singles_walls.append([x, y, Constants.WallTileCode.MID_WALL])
						singles_floors.append([x, y, Constants.FloorTileCode.MID_FLOOR])

		if not (singles_walls and singles_floors):
			break
		else:
			while singles_walls or singles_floors:
				if singles_walls:
					var item = singles_walls.pop_front()
					WALLS[item[1]][item[0]] = item[2]
				if singles_floors:
					var item = singles_floors.pop_front()
					FLOOR[item[1]][item[0]] = item[2]


func _fill_level(node):
	if node:
		_fill_level(node.left)
		_fill_level(node.right)

		if node.hall:
			var p1 = node.hall[0]
			var p2 = node.hall[1]
			var d = node.hall[2]

			if Utils.distance(p1, [0, 0]) > Utils.distance(p2, [0, 0]):
				var temp_p1 = p1
				p1 = p2
				p2 = temp_p1

			var i = 0
			var wide = (rng.randi() % 2 == 0)

			for p in Utils.line(p1, p2, d):
				var x = ceil(p[0])
				var y = ceil(p[1])

				if FLOOR[y][x] != Constants.FloorTileCode.MID_FLOOR:
					FLOOR[y][x] = Constants.FloorTileCode.MID_FLOOR

				var extra_points = []

				if wide:
					extra_points = [
						[x-1, y],
						[x-1, y-1],
						[x  , y-1],
						[x+1, y-1],
						[x+1, y],
						[x+1, y+1],
						[x  , y+1],
						[x-1, y+1],
					]
				else:
					if i % 2 == 0:
						extra_points = [
							[x+1, y],
							[x+1, y+1],
							[x  , y+1],
						]
					else:
						extra_points = [
							[x  , y+1],
							[x-1, y+1],
							[x-1, y]
						]

					i += 1

				for ep in extra_points:
					if FLOOR[ep[1]][ep[0]] != Constants.FloorTileCode.MID_FLOOR:
						FLOOR[ep[1]][ep[0]] = Constants.FloorTileCode.MID_FLOOR

		if node.room:
			var r = node.room

			# for x in range(r.x1(), r.x2()+1):
			# 	WALLS[r.y1()][x] = Constants.FloorTileCode.NORTH_WALL
			# 	WALLS[r.y2()][x] = Constants.FloorTileCode.SOUTH_WALL

			# for y in range(r.y1(), r.y2()+1):
			# 	WALLS[y][r.x1()] = Constants.FloorTileCode.WEST_WALL
			# 	WALLS[y][r.x2()] = Constants.FloorTileCode.EAST_WALL

			# WALLS[r.y1()][r.x1()] = Constants.FloorTileCode.NW_CORNER
			# WALLS[r.y1()][r.x2()] = Constants.FloorTileCode.NE_CORNER
			# WALLS[r.y2()][r.x1()] = Constants.FloorTileCode.SW_CORNER
			# WALLS[r.y2()][r.x2()] = Constants.FloorTileCode.SE_CORNER

			for i in range(r.get_width()):
				for j in range(r.get_height()):
					var x = r.x1() + i
					var y = r.y1() + j
					var val = r.ca.matrix[j][i]

					if val == Constants.CA_Tiles.ALIVE:
						FLOOR[y][x] = Constants.FloorTileCode.MID_FLOOR
						WALLS[y][x] = Constants.WallTileCode.EMPTY
					elif val == Constants.CA_Tiles.DEAD:
						FLOOR[y][x] = Constants.FloorTileCode.EMPTY
						WALLS[y][x] = Constants.WallTileCode.EMPTY


func _init_level(w, h):
	FLOOR = []
	WALLS = []

	for i in range(w):
		FLOOR.append([])
		WALLS.append([])

		for _j in range(h):
			FLOOR[i].append(Constants.FloorTileCode.EMPTY)
			WALLS[i].append(Constants.WallTileCode.EMPTY)


func _generate_rooms(root):
	for leaf in root.get_leaves():
		var ca = CellularAutomaton.new(0.475, 4, 6, 3, rng)
		ca.do_process(leaf.get_width()-2, leaf.get_height()-2)
		leaf.set_room(CARoom.new(
			ca, leaf.x1() + 1, leaf.y1() + 1, leaf.get_width()-2, leaf.get_height()-2
		))


func _get_hall_path(room1, room2):
	var room1_bbox = room1.get_boundary_box()
	var room2_bbox = room2.get_boundary_box()

	var room1_center_point = [room1.x1() + ceil((room1_bbox[2] + room1_bbox[0])/2), room1.y1() + ceil((room1_bbox[3] + room1_bbox[1])/2)]
	var room2_center_point = [room2.x1() + ceil((room2_bbox[2] + room2_bbox[0])/2), room2.y1() + ceil((room2_bbox[3] + room2_bbox[1])/2)]

	room1_center_point[0] += rng.randi_range(-3, 3)
	room1_center_point[1] += rng.randi_range(-3, 3)

	room2_center_point[0] += rng.randi_range(-3, 3)
	room2_center_point[1] += rng.randi_range(-3, 3)

	return [
		room1_center_point,
		room2_center_point,
		Utils.distance(room1_center_point, room2_center_point)
	]


func _generate_halls(node):
	if node.left and not node.left.room:
		_generate_halls(node.left)

	if node.right and not node.right.room:
		_generate_halls(node.right)

	if node.left and node.right:
		if node.left.room and node.right.room:
			node.hall = _get_hall_path(node.left.room, node.right.room)
		elif node.left.hall and node.right.room:
			var paths = []

			for lr in node.left.get_rooms():
				paths.append(_get_hall_path(lr, node.right.room))

			paths.sort_custom(Utils.DistanceSorter, "sort_asc")
			node.hall = paths[0]
		elif node.left.room and node.right.hall:
			var paths = []

			for rr in node.right.get_rooms():
				paths.append(_get_hall_path(rr, node.left.room))

			paths.sort_custom(Utils.DistanceSorter, "sort_asc")
			node.hall = paths[0]
		elif node.left.hall and node.right.hall:
			var paths = []

			for lr in node.left.get_rooms():
				for rr in node.right.get_rooms():
					paths.append(_get_hall_path(rr, lr))

			paths.sort_custom(Utils.DistanceSorter, "sort_asc")
			node.hall = paths[0]


func run(w, h):
	var bsp_gen = BSP_Generator.new(rng)
	var children = bsp_gen.generate_tree(0, w-1, 0, h-1)
	var root = BSPNode.new(children["left"], children["right"], 0, 0, w, h)

	_generate_rooms(root)
	_generate_halls(root)

	_init_level(w, h)
	_fill_level(root)
	_outline()
	_fill_singles()


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
