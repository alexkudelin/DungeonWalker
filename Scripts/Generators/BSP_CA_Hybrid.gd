extends Node

class_name BSP_CA_Generator

var BSPNode = load("res://Scripts/BSP/BSPNode.gd")
var CellularAutomaton = load("res://Scripts/CA/CellularAutomaton.gd")
var CARoom = load("res://Scripts/CA/Room.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")
var Utils = load("res://Scripts/Utils/Utils.gd")

var BSP_Generator = load("res://Scripts/Generators/BSP.gd")

var rng = null

var FLOOR = []
var WALLS = []
var STUFF = []

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

			for p in Utils.line(p1, p2, d):
				var x = ceil(p[0])
				var y = ceil(p[1])

				if FLOOR[y][x] != Constants.FloorTileCode.MID_FLOOR:
					FLOOR[y][x] = Constants.FloorTileCode.MID_FLOOR

				var extra_points = [
					[x-1, y],
					[x-1, y-1],
					[x  , y-1],
					[x+1, y-1],
					[x+1, y],
					[x+1, y+1],
					[x  , y+1],
					[x-1, y+1],
				]

				for ep in extra_points:
					if FLOOR[ep[1]][ep[0]] != Constants.FloorTileCode.MID_FLOOR:
						FLOOR[ep[1]][ep[0]] = Constants.FloorTileCode.MID_FLOOR

		# for x in range(node.x1(), node.x2()):
		# 	WALLS[node.y1()][x] = Constants.WallTileCode.NODE_WALL
		# 	WALLS[node.y2()][x] = Constants.WallTileCode.NODE_WALL

		# for y in range(node.y1(), node.y2()+1):
		# 	WALLS[y][node.x1()] = Constants.WallTileCode.NODE_WALL
		# 	WALLS[y][node.x2()] = Constants.WallTileCode.NODE_WALL

		if node.room:
			var r = node.room

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

func _add_stuff(w, h):
	var ignore = []

	for x in range(w):
		for y in range(h):
			if not ignore.has([x, y]):
				if FLOOR[y][x] == Constants.FloorTileCode.MID_FLOOR and WALLS[y][x] == Constants.WallTileCode.EMPTY:
					var nb = Utils.get_moore_nb(WALLS, x, y)
					var nc = Utils.count_objects_in_nb(nb, [Constants.WallTileCode.MID_WALL])
					if nc in [5, 6]:
						var p = rng.randf()

						if p > 0 and p <= 0.25:
							STUFF[y][x] = Constants.StuffTileCode.CHEST
						elif p > 0.25 and p <= 0.35:
							STUFF[y][x] = Constants.StuffTileCode.BIG_FLASK
						elif p > 0.35 and p <= 0.45:
							STUFF[y][x] = Constants.StuffTileCode.SMALL_FLASK
						else:
							continue

						for item in nb:
							ignore.append([item[0], item[1]])
					else:
						if rng.randf() <= 0.0075:
							STUFF[y][x] = Constants.StuffTileCode.CHEST
							for item in nb:
								ignore.append([item[0], item[1]])
							continue

						if rng.randf() <= 0.01:
							STUFF[y][x] = Constants.StuffTileCode.BIG_FLASK
							for item in nb:
								ignore.append([item[0], item[1]])
							continue

						if rng.randf() <= 0.01:
							STUFF[y][x] = Constants.StuffTileCode.SMALL_FLASK
							for item in nb:
								ignore.append([item[0], item[1]])
							continue


func _add_enter_and_exit(root):
	var enter = root.get_left_leaf()
	var exit = root.get_right_leaf()

	var enter_room_bbox = enter.room.get_boundary_box()
	var exit_room_bbox = exit.room.get_boundary_box()

	var enter_point = []
	var exit_point = []

	var ignore = []

	while not enter_point or not exit_point:
		if not enter_point:
			var enter_x = rng.randi_range(enter_room_bbox[0], enter_room_bbox[2])
			var enter_y = rng.randi_range(enter_room_bbox[1], enter_room_bbox[3])

			if not ignore.has([enter_x, enter_y]):
				if FLOOR[enter.room.y1()+enter_y][enter.room.x1()+enter_x] != Constants.FloorTileCode.EMPTY:
					enter_point = [enter_x, enter_y]
				else:
					ignore.append([enter_x, enter_y])

		if not exit_point:
			var exit_x = rng.randi_range(exit_room_bbox[0], exit_room_bbox[2])
			var exit_y = rng.randi_range(exit_room_bbox[1], exit_room_bbox[3])

			if not ignore.has([exit_x, exit_y]):
				if FLOOR[exit.room.y1()+exit_y][exit.room.x1()+exit_x] != Constants.FloorTileCode.EMPTY:
					exit_point = [exit_x, exit_y]
				else:
					ignore.append([exit_x, exit_y])

	STUFF[enter.room.y1()+enter_point[1]][enter.room.x1()+enter_point[0]] = Constants.StuffTileCode.LEVEL_ENTER
	STUFF[exit.room.y1()+exit_point[1]][exit.room.x1()+exit_point[0]] = Constants.StuffTileCode.LEVEL_EXIT


func _init_level(w, h):
	FLOOR.clear()
	WALLS.clear()
	STUFF.clear()

	for i in range(w):
		FLOOR.append([])
		WALLS.append([])
		STUFF.append([])

		for _j in range(h):
			FLOOR[i].append(Constants.FloorTileCode.EMPTY)
			WALLS[i].append(Constants.WallTileCode.EMPTY)
			STUFF[i].append(Constants.StuffTileCode.EMPTY)


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
	_add_stuff(w, h)
	_add_enter_and_exit(root)


func get_map():
	return {
		"floor": FLOOR,
		"walls": WALLS,
		"stuff": STUFF,
	}


func _init(_rng=null):
	if _rng:
		rng = _rng
	else:
		rng = RandomNumberGenerator.new()
