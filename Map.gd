extends Node2D

var TNode = load("res://TNode.gd")
var Room = load("res://Room.gd")
var Hall = load("res://Hall.gd")
var Constants = load("res://Constants.gd")
var CellularAutomaton = load("res://CellularAutomaton.gd")

var rng = RandomNumberGenerator.new()

onready var FLOOR = $Floor
onready var WALLS = $Walls

onready var ROOM_FLOOR_TILE_1 = FLOOR.tile_set.find_tile_by_name("stone_E")
onready var ROOM_FLOOR_TILE_2 = FLOOR.tile_set.find_tile_by_name("dirt_E")

onready var HALL_FLOOR_TILE_1 = FLOOR.tile_set.find_tile_by_name("stoneInset_E")
onready var HALL_FLOOR_TILE_2 = FLOOR.tile_set.find_tile_by_name("dirtTiles_E")

onready var NODE_WALL_TILE_1 = FLOOR.tile_set.find_tile_by_name("planks_E")
onready var NODE_WALL_TILE_2 = FLOOR.tile_set.find_tile_by_name("planksHole_E")

onready var WALL_TILE_N_1 = WALLS.tile_set.find_tile_by_name("stoneWall_N")
onready var WALL_TILE_S_1 = WALLS.tile_set.find_tile_by_name("stoneWall_S")
onready var WALL_TILE_E_1 = WALLS.tile_set.find_tile_by_name("stoneWall_E")
onready var WALL_TILE_W_1 = WALLS.tile_set.find_tile_by_name("stoneWall_W")

onready var WALL_TILE_N_2 = WALLS.tile_set.find_tile_by_name("stoneWallHole_N")
onready var WALL_TILE_S_2 = WALLS.tile_set.find_tile_by_name("stoneWallHole_S")
onready var WALL_TILE_E_2 = WALLS.tile_set.find_tile_by_name("stoneWallHole_E")
onready var WALL_TILE_W_2 = WALLS.tile_set.find_tile_by_name("stoneWallHole_W")

onready var WALL_CORNER_TILE_N = WALLS.tile_set.find_tile_by_name("stoneWallCorner_N")
onready var WALL_CORNER_TILE_S = WALLS.tile_set.find_tile_by_name("stoneWallCorner_S")
onready var WALL_CORNER_TILE_E = WALLS.tile_set.find_tile_by_name("stoneWallCorner_E")
onready var WALL_CORNER_TILE_W = WALLS.tile_set.find_tile_by_name("stoneWallCorner_W")

func _draw_dungeon(node):
	if node:
		_draw_dungeon(node.left)
		_draw_dungeon(node.right)

		# for x in range(node.x1(), node.x2()):
		# 	FLOOR.set_cell(x, node.y1(), [NODE_WALL_TILE_1, NODE_WALL_TILE_2][x%2])
		# 	FLOOR.set_cell(x, node.y2(), [NODE_WALL_TILE_1, NODE_WALL_TILE_2][x%2])

		# for y in range(node.y1(), node.y2()+1):
		# 	FLOOR.set_cell(node.x1(), y, [NODE_WALL_TILE_1, NODE_WALL_TILE_2][y%2])
		# 	FLOOR.set_cell(node.x2(), y, [NODE_WALL_TILE_1, NODE_WALL_TILE_2][y%2])

		if node.room:
			var r = node.room

			for x in range(r.x1(), r.x2()):
				WALLS.set_cell(x, r.y1(), [WALL_TILE_S_1, WALL_TILE_S_2][x%2])
				WALLS.set_cell(x, r.y2(), [WALL_TILE_N_1, WALL_TILE_N_2][x%2])

			for y in range(r.y1(), r.y2()):
				WALLS.set_cell(r.x1(), y, [WALL_TILE_E_1, WALL_TILE_E_2][y%2])
				WALLS.set_cell(r.x2(), y, [WALL_TILE_W_1, WALL_TILE_W_2][y%2])

			WALLS.set_cell(r.x1(), r.y1(), WALL_CORNER_TILE_S)
			WALLS.set_cell(r.x1(), r.y2(), WALL_CORNER_TILE_E)
			WALLS.set_cell(r.x2(), r.y1(), WALL_CORNER_TILE_W)
			WALLS.set_cell(r.x2(), r.y2(), WALL_CORNER_TILE_N)

			for x in range(r.x1(), r.x2()+1):
				for y in range(r.y1(), r.y2()+1):
					FLOOR.set_cell(x, y, [ROOM_FLOOR_TILE_1, ROOM_FLOOR_TILE_2][(x+y)%2])

		if node.hall:
			var h = node.hall

			for x in range(h.x1(), h.x1() + h.get_width()):
				for y in range(h.y1(), h.y1() + h.get_height()):
					FLOOR.set_cell(x, y, [HALL_FLOOR_TILE_1, HALL_FLOOR_TILE_2][(x+y)%2])
					
			var split_dir = h.get_direction()

			if split_dir == Constants.Direction.HORIZONTAL:
				for x in range(h.x1(), h.x1() + h.get_width()):
					WALLS.set_cell(x, h.y1(), [WALL_TILE_S_1, WALL_TILE_S_2][x%2])
					WALLS.set_cell(x, h.y2(), [WALL_TILE_N_1, WALL_TILE_N_2][x%2])

				for y in range(h.y1(), h.y1() + h.get_height()):
					WALLS.set_cell(h.x1()-1, y, -1)
					WALLS.set_cell(h.x2(), y, -1)
			elif split_dir == Constants.Direction.VERTICAL:
				for y in range(h.y1(), h.y1() + h.get_height()):
					WALLS.set_cell(h.x1(), y, [WALL_TILE_E_1, WALL_TILE_E_2][y%2])
					WALLS.set_cell(h.x2(), y, [WALL_TILE_W_1, WALL_TILE_W_2][y%2])

				for x in range(h.x1(), h.x1() + h.get_width()):
					WALLS.set_cell(x, h.y1()-1, -1)
					WALLS.set_cell(x, h.y2(), -1)

func _get_intersection(l1, l2):
	var intersection = []

	for item in l1:
		if l2.has(item):
			intersection.append(item)

	return intersection

func _unique(l):
	var idx1 = 0
	var idx2 = idx1

	while idx1 < l.size():
		var val = l[idx1]
		idx2 = idx1 + 1

		while idx2 < l.size():
			if l[idx2] == val:
				l.remove(idx2)
			else:
				idx2 += 1

		idx1 += 1

func _set_subtraction(from_set, what_subtract):
	for item in what_subtract:
		if from_set.has(item):
			from_set.remove(from_set.find(item))

func sort_by_x1(a, b):
	return (a.x1() < b.x1())

func sort_by_x2(a, b):
	return (a.x2() < b.x2())

func sort_by_y1(a, b):
	return (a.y1() < b.y1())

func sort_by_y2(a, b):
	return (a.y2() < b.y2())

func generate_halls(node):
	if node.left and not node.left.room:
		generate_halls(node.left)

	if node.right and not node.right.room:
		generate_halls(node.right)

	if node.left and node.right:
		var split_dir = node.get_split_direction()

		if node.left.room and node.right.room:
			var left_room = node.left.room
			var right_room = node.right.room
			
			var intersection = []

			if split_dir == Constants.Direction.HORIZONTAL:
				intersection = _get_intersection(range(left_room.x1()+2, left_room.x2()-1), range(right_room.x1()+2, right_room.x2()-1))
			elif split_dir == Constants.Direction.VERTICAL:
				intersection = _get_intersection(range(left_room.y1()+2, left_room.y2()-1), range(right_room.y1()+2, right_room.y2()-1))

			if intersection:
				# var ignore = []
				
				# if split_dir == Constants.Direction.HORIZONTAL:
				# 	ignore.append_array([left_room.x1()+2, left_room.x2()-2, right_room.x1()+2, right_room.x2()-2])
				# elif split_dir == Constants.Direction.VERTICAL:
				# 	ignore.append_array([left_room.y1()+2, left_room.y2()-2, right_room.y1()+2, right_room.y2()-2])
					
				# _unique(ignore)
				# _set_subtraction(intersection, ignore)

				var choice = intersection[rng.randi() % intersection.size()]
					
				if split_dir == Constants.Direction.HORIZONTAL:
					node.hall = Hall.new(
						choice, left_room.y2()+1,
						right_room.y1() - left_room.y2(),
						Constants.Direction.VERTICAL
					)
				elif split_dir == Constants.Direction.VERTICAL:
					node.hall = Hall.new(
						left_room.x2()+1, choice,
						right_room.x1() - left_room.x2(),
						Constants.Direction.HORIZONTAL
					)
		elif node.left.hall and node.right.room:
			var boundary_box = node.left.get_boundary_box()

			var objects = node.left.get_objects()
			var intersection = []

			if split_dir == Constants.Direction.HORIZONTAL:
				intersection = _get_intersection(
					range(boundary_box[0], boundary_box[2]),
					range(node.right.room.x1() + 2, node.right.room.x2()-1)
				)
			elif split_dir == Constants.Direction.VERTICAL:
				intersection = _get_intersection(
					range(boundary_box[1], boundary_box[3]),
					range(node.right.room.y1() + 2, node.right.room.y2()-1)
				)

			if intersection:
				var ignore = []

				for item in objects:
					if split_dir == Constants.Direction.HORIZONTAL:
						ignore.append_array([item.x1(), item.x1() + 1, item.x2(), item.x2()-1])
					elif split_dir == Constants.Direction.VERTICAL:
						ignore.append_array([item.y1(), item.y1() + 1, item.y2(), item.y2()-1])

				_unique(ignore)
				_set_subtraction(intersection, ignore)

				var choice = intersection[rng.randi() % intersection.size()]
				var children = []

				if split_dir == Constants.Direction.HORIZONTAL:
					children = node.left.get_objects_on_x_line(choice)
					children.sort_custom(self, "sort_by_y2")

					node.hall = Hall.new(
						choice, children.back().y2()+1,
						node.right.room.y1() - children.back().y2(),
						Constants.Direction.VERTICAL
					)
				elif split_dir == Constants.Direction.VERTICAL:
					children = node.left.get_objects_on_y_line(choice)
					children.sort_custom(self, "sort_by_x2")

					node.hall = Hall.new(
						children.back().x2()+1, choice,
						node.right.room.x1() - children.back().x2(),
						Constants.Direction.HORIZONTAL
					)
		elif node.left.room and node.right.hall:
			var boundary_box = node.right.get_boundary_box()

			var objects = node.right.get_objects()
			var intersection = []

			if split_dir == Constants.Direction.HORIZONTAL:
				intersection = _get_intersection(
					range(boundary_box[0], boundary_box[2]),
					range(node.left.room.x1() + 2, node.left.room.x2()-1)
				)
			elif split_dir == Constants.Direction.VERTICAL:
				intersection = _get_intersection(
					range(boundary_box[1], boundary_box[3]),
					range(node.left.room.y1() + 2, node.left.room.y2()-1)
				)

			if intersection:
				var ignore = []

				for item in objects:
					if split_dir == Constants.Direction.HORIZONTAL:
						ignore.append_array([item.x1(), item.x1() + 1, item.x2(), item.x2()-1])
					elif split_dir == Constants.Direction.VERTICAL:
						ignore.append_array([item.y1(), item.y1() + 1, item.y2(), item.y2()-1])

				_unique(ignore)
				_set_subtraction(intersection, ignore)

				var choice = intersection[rng.randi() % intersection.size()]
				var children = []

				if split_dir == Constants.Direction.HORIZONTAL:
					children = node.right.get_objects_on_x_line(choice)
					children.sort_custom(self, "sort_by_y1")

					node.hall = Hall.new(
						choice, node.left.room.y2()+1,
						children.front().y1() - node.left.room.y2(),
						Constants.Direction.VERTICAL
					)
				elif split_dir == Constants.Direction.VERTICAL:
					children = node.right.get_objects_on_y_line(choice)
					children.sort_custom(self, "sort_by_x1")

					node.hall = Hall.new(
						node.left.room.x2()+1, choice,
						children.front().x1() - node.left.room.x2(),
						Constants.Direction.HORIZONTAL
					)
		elif node.left.hall and node.right.hall:
			var left_box = node.left.get_boundary_box()
			var right_box = node.right.get_boundary_box()

			var intersection = []

			if split_dir == Constants.Direction.HORIZONTAL:
				intersection = _get_intersection(
					range(left_box[0], left_box[2]),
					range(right_box[0], right_box[2])
				)
			elif split_dir == Constants.Direction.VERTICAL:
				intersection = _get_intersection(
					range(left_box[1], left_box[3]),
					range(right_box[1], right_box[3])
				)

			if intersection:
				var left_objects = node.left.get_objects()
				var right_objects = node.right.get_objects()

				var ignore = []

				for item in left_objects + right_objects:
					if split_dir == Constants.Direction.HORIZONTAL:
						ignore.append_array([item.x1(), item.x1() + 1, item.x2(), item.x2()-1])
					elif split_dir == Constants.Direction.VERTICAL:
						ignore.append_array([item.y1(), item.y1() + 1, item.y2(), item.y2()-1])

				_unique(ignore)
				_set_subtraction(intersection, ignore)

				var choice = intersection[rng.randi() % intersection.size()]

				if split_dir == Constants.Direction.HORIZONTAL:
					left_objects = node.left.get_objects_on_x_line(choice)
					left_objects.sort_custom(self, "sort_by_y2")

					right_objects = node.right.get_objects_on_x_line(choice)
					right_objects.sort_custom(self, "sort_by_y1")

					node.hall = Hall.new(
						choice, left_objects.back().y2()+1,
						right_objects.front().y1() - left_objects.back().y2(),
						Constants.Direction.VERTICAL
					)
				elif split_dir == Constants.Direction.VERTICAL:
					left_objects = node.left.get_objects_on_y_line(choice)
					left_objects.sort_custom(self, "sort_by_x2")

					right_objects = node.right.get_objects_on_y_line(choice)
					right_objects.sort_custom(self, "sort_by_x1")

					node.hall = Hall.new(
						left_objects.back().x2()+1, choice,
						right_objects.front().x1() - left_objects.back().x2(),
						Constants.Direction.HORIZONTAL
					)

func _get_split_direction():
	var choices = [Constants.Direction.VERTICAL, Constants.Direction.HORIZONTAL]
	return choices[rng.randi() % choices.size()]

func _get_wall(a, b):
	var borders = [a, b]

	borders.sort()
	borders = range(borders[0], borders[1])

	return borders[rng.randi() % borders.size()]

func generate_rooms(node):
	if node != null:
		if node.left == null and node.right == null:
			var x1 = node.x1()
			var y1 = node.y1()
			var x2 = node.x2()
			var y2 = node.y2()
			
			var x_range = range(Constants.WALL_SIZE, ceil((x2-x1)*0.2))
			var y_range = range(Constants.WALL_SIZE, ceil((y2-y1)*0.2))

			var dx1 = x_range[rng.randi() % x_range.size()]
			var dx2 = x_range[rng.randi() % x_range.size()]
			var dy1 = y_range[rng.randi() % y_range.size()]
			var dy2 = y_range[rng.randi() % y_range.size()]

			node.room = Room.new(x1+dx1, y1+dy1, (x2-dx2) - (x1+dx1), (y2-dy2) - (y1+dy1))
		else:
			generate_rooms(node.left)
			generate_rooms(node.right)


func generate_tree(x1, x2, y1, y2, depth=1):
	var left = null
	var right = null

	if y2 <= y1 or x2 <= x1 or (y2 - y1 < Constants.MIN_ROOM_SIZE or x2 - x1 < Constants.MIN_ROOM_SIZE):
		return {"left": left, "right": right}

	var wall_shift = Constants.MIN_ROOM_FREE_SPACE + Constants.WALL_SIZE
	var direction = _get_split_direction()

	if (x2 - x1) / (y2 - y1) >= 1.25:
		direction = direction | Constants.Direction.VERTICAL

	if (y2 - y1) / (x2 - x1) >= 1.25:
		direction = direction | Constants.Direction.HORIZONTAL

	if direction == Constants.Direction.MIXED:
		direction = _get_split_direction()

	var max_size = (x2 - x1) if direction == Constants.Direction.VERTICAL else (y2 - y1)

	if max_size - Constants.MIN_ROOM_SIZE <= Constants.MIN_ROOM_SIZE:
		return {"left": left, "right": right}

	if (x2 - x1 > Constants.MIN_ROOM_SIZE) and direction == Constants.Direction.VERTICAL:
		var wall = _get_wall(x1 + wall_shift, x2 - wall_shift)
		var children = generate_tree(x1, wall, y1, y2, depth+1)

		left = TNode.new(
			children["left"],
			children["right"],
			x1, y1, wall-x1+1, y2-y1+1,
			depth
		)

		children = generate_tree(wall, x2, y1, y2, depth+1)

		right = TNode.new(
			children["left"],
			children["right"],
			wall, y1, x2-wall+1, y2-y1+1,
			depth
		)
	elif (y2 - y1 > Constants.MIN_ROOM_SIZE) and direction == Constants.Direction.HORIZONTAL:
		var wall = _get_wall(y1 + wall_shift, y2 - wall_shift)
		var children = generate_tree(x1, x2, y1, wall, depth+1)

		left = TNode.new(
			children["left"],
			children["right"],
			x1, y1, x2-x1+1, wall-y1+1,
			depth
		)

		children = generate_tree(x1, x2, wall, y2, depth+1)

		right = TNode.new(
			children["left"],
			children["right"],
			x1, wall, x2-x1+1, y2-wall+1,
			depth
		)

	return {"left": left, "right": right}

func bsp(w, h):
	var children = generate_tree(0, w-1, 0, h-1)
	var root = TNode.new(children["left"], children["right"], 0, 0, w, h)

	# generate_rooms(root)
	# generate_halls(root)

	for leaf in root.get_leafs():
		var ca = CellularAutomaton.new(0.50, 3, 5, 3, rng)
		var res = ca.do_process(leaf.get_width()-1, leaf.get_height()-1)

		for row in res:
			print(row)

		for i in range(leaf.get_width()-1):
			for j in range(leaf.get_height()-1):
				FLOOR.set_cell(leaf.x1() + i, leaf.y1() + j, [ROOM_FLOOR_TILE_1, ROOM_FLOOR_TILE_2, NODE_WALL_TILE_1][res[j][i]])

	# _draw_dungeon(root)

func _ready():
	var cur_seed = 123

	if cur_seed == null:
		rng.randomize()
	else:
		rng.set_seed(cur_seed)

	print_debug(rng.get_seed())

	var w = 64
	var h = 64

	bsp(w, h)

	# var ca = CellularAutomaton.new(0.50, 3, 5, 3)
	# var res = ca.do_process(w, h, cur_seed)

	# for x in range(w):
	# 	for y in range(h):
	# 		FLOOR.set_cell(x, y, [ROOM_FLOOR_TILE_1, ROOM_FLOOR_TILE_2, NODE_WALL_TILE_1][res[y][x]])
