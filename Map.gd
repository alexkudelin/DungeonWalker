extends Node2D

var TNode = load("TNode.gd")
var Room = load("Room.gd")
var Hall = load("Hall.gd")
var Constants = load("Constants.gd")
var rng = RandomNumberGenerator.new()

onready var level_floor = $Floor
onready var level_walls = $Walls

func _draw_dungeon(node):
	if node:
		_draw_dungeon(node.left)
		_draw_dungeon(node.right)

#		for x in range(node.x1(), node.x2()):
#			level_floor.set_cell(x, node.y1(), 0)
#			level_floor.set_cell(x, node.y2(), 0)
#
#		for y in range(node.y1(), node.y2()):
#			level_floor.set_cell(node.x1(), y, 0)
#			level_floor.set_cell(node.x2(), y, 0)

		if node.room:
#			for x in range(node.room.x1() + 1, node.room.x2()):
#				level_walls.set_cell(x, node.room.y1(), level_walls.tile_set.find_tile_by_name("stoneWall_S"))
#				level_walls.set_cell(x, node.room.y2(), level_walls.tile_set.find_tile_by_name("stoneWall_N"))
#
#			for y in range(node.room.y1() + 1, node.room.y2()):
#				level_walls.set_cell(node.room.x1(), y, level_walls.tile_set.find_tile_by_name("stoneWall_E"))
#				level_walls.set_cell(node.room.x2(), y, level_walls.tile_set.find_tile_by_name("stoneWall_W"))
#
#			var topleft = level_walls.tile_set.find_tile_by_name("stoneWallCorner_S")
#			level_walls.set_cell(node.room.x1(), node.room.y1(), topleft)
#
#			var bottomleft = level_walls.tile_set.find_tile_by_name("stoneWallCorner_E")
#			level_walls.set_cell(node.room.x1(), node.room.y2(), bottomleft)
#
#			var topright = level_walls.tile_set.find_tile_by_name("stoneWallCorner_W")
#			level_walls.set_cell(node.room.x2(), node.room.y1(), topright)
#
#			var bottomright = level_walls.tile_set.find_tile_by_name("stoneWallCorner_N")
#			level_walls.set_cell(node.room.x2(), node.room.y2(), bottomright)
			
			for x in range(node.room.x1(), node.room.x2()):
				for y in range(node.room.y1(), node.room.y2()):
					level_floor.set_cell(x, y, level_floor.tile_set.find_tile_by_name("stone_E"))


		if node.hall:
			var x1 = node.hall.x1()
			var x2 = node.hall.x2()
			var y1 = node.hall.y1()
			var y2 = node.hall.y2()

			var split_dir = node.hall.get_direction()

			if split_dir == Constants.Direction.VERTICAL:
				x2 += 1
			elif split_dir == Constants.Direction.HORIZONTAL:
				y2 += 1

			for x in range(x1, x2):
				for y in range(y1, y2):
					level_floor.set_cell(x, y, level_floor.tile_set.find_tile_by_name("stoneTile_E"))

			if split_dir == Constants.Direction.VERTICAL:
				for y in range(y1, y2):
					level_walls.set_cell(x1, y, level_walls.tile_set.find_tile_by_name("stoneWall_E"))
					level_walls.set_cell(x2, y, level_walls.tile_set.find_tile_by_name("stoneWall_E"))
			elif split_dir == Constants.Direction.HORIZONTAL:
				for x in range(x1, x2):
					level_walls.set_cell(x, y1, level_walls.tile_set.find_tile_by_name("stoneWall_S"))
					level_walls.set_cell(x, y2, level_walls.tile_set.find_tile_by_name("stoneWall_S"))

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
				intersection = _get_intersection(range(left_room.x1() + 1, left_room.x2() - 1), range(right_room.x1() + 1, right_room.x2() - 1))
			elif split_dir == Constants.Direction.VERTICAL:
				intersection = _get_intersection(range(left_room.y1() + 1, left_room.y2() - 1), range(right_room.y1() + 1, right_room.y2() - 1))

			if intersection:
				var choice = intersection[rng.randi() % intersection.size()]

				if split_dir == Constants.Direction.HORIZONTAL:
					node.hall = Hall.new(
						choice, left_room.y2(),
						right_room.y1() - left_room.y2() + 1,
						Constants.Direction.VERTICAL
					)
				elif split_dir == Constants.Direction.VERTICAL:
					node.hall = Hall.new(
						left_room.x2(), choice,
						right_room.x1() - left_room.x2() + 1,
						Constants.Direction.HORIZONTAL
					)
		elif node.left.hall and node.right.room:
			var boundary_box = node.left.get_boundary_box()

			var objects = node.left.get_objects()
			var intersection = []

			if split_dir == Constants.Direction.HORIZONTAL:
				intersection = _get_intersection(
					range(boundary_box[0] + 1, boundary_box[2] - 1),
					range(node.right.room.x1() + 1, node.right.room.x2() - 1)
				)
			elif split_dir == Constants.Direction.VERTICAL:
				intersection = _get_intersection(
					range(boundary_box[1] + 1, boundary_box[3] - 1),
					range(node.right.room.y1() + 1, node.right.room.y2() - 1)
				)

			if intersection:
				var ignore = []

				for item in objects:
					if split_dir == Constants.Direction.HORIZONTAL:
						ignore.append(item.x1())
						ignore.append(item.x2())
					elif split_dir == Constants.Direction.VERTICAL:
						ignore.append(item.y1())
						ignore.append(item.y2())

				_unique(ignore)
				_set_subtraction(intersection, ignore)

				var choice = intersection[rng.randi() % intersection.size()]
				var children = []

				if split_dir == Constants.Direction.HORIZONTAL:
					children = node.left.get_objects_on_x_line(choice)
					children.sort_custom(self, "sort_by_y2")

					node.hall = Hall.new(
						choice, children.back().y2(),
						node.right.room.y1() - children.back().y2() + 1,
						Constants.Direction.VERTICAL
					)
				elif split_dir == Constants.Direction.VERTICAL:
					children = node.left.get_objects_on_y_line(choice)
					children.sort_custom(self, "sort_by_x2")

					node.hall = Hall.new(
						children.back().x2(), choice,
						node.right.room.x1() - children.back().x2() + 1,
						Constants.Direction.HORIZONTAL
					)
		elif node.left.room and node.right.hall:
			var boundary_box = node.right.get_boundary_box()

			var objects = node.right.get_objects()
			var intersection = []

			if split_dir == Constants.Direction.HORIZONTAL:
				intersection = _get_intersection(
					range(boundary_box[0] + 1, boundary_box[2] - 1),
					range(node.left.room.x1() + 1, node.left.room.x2() - 1)
				)
			elif split_dir == Constants.Direction.VERTICAL:
				intersection = _get_intersection(
					range(boundary_box[1] + 1, boundary_box[3] - 1),
					range(node.left.room.y1() + 1, node.left.room.y2() - 1)
				)

			if intersection:
				var ignore = []

				for item in objects:
					if split_dir == Constants.Direction.HORIZONTAL:
						ignore.append(item.x1())
						ignore.append(item.x2())
					elif split_dir == Constants.Direction.VERTICAL:
						ignore.append(item.y1())
						ignore.append(item.y2())

				_unique(ignore)
				_set_subtraction(intersection, ignore)

				var choice = intersection[rng.randi() % intersection.size()]
				var children = []

				if split_dir == Constants.Direction.HORIZONTAL:
					children = node.right.get_objects_on_x_line(choice)
					children.sort_custom(self, "sort_by_y1")

					node.hall = Hall.new(
						choice, node.left.room.y2(),
						children.front().y1() - node.left.room.y2()  + 1,
						Constants.Direction.VERTICAL
					)
				elif split_dir == Constants.Direction.VERTICAL:
					children = node.right.get_objects_on_y_line(choice)
					children.sort_custom(self, "sort_by_x1")

					node.hall = Hall.new(
						node.left.room.x2(), choice,
						children.front().x1() - node.left.room.x2() + 1,
						Constants.Direction.HORIZONTAL
					)
		elif node.left.hall and node.right.hall:
			var left_box = node.left.get_boundary_box()
			var right_box = node.right.get_boundary_box()

			var intersection = []

			if split_dir == Constants.Direction.HORIZONTAL:
				intersection = _get_intersection(
					range(left_box[0] + 1, left_box[2] - 1),
					range(right_box[0] + 1, right_box[2] - 1)
				)
			elif split_dir == Constants.Direction.VERTICAL:
				intersection = _get_intersection(
					range(left_box[1] + 1, left_box[3] - 1),
					range(right_box[1] + 1, right_box[3] - 1)
				)

			if intersection:
				var left_objects = node.left.get_objects()
				var right_objects = node.right.get_objects()

				var ignore = []

				for item in left_objects + right_objects:
					if split_dir == Constants.Direction.HORIZONTAL:
						ignore.append(item.x1())
						ignore.append(item.x2())
					elif split_dir == Constants.Direction.VERTICAL:
						ignore.append(item.y1())
						ignore.append(item.y2())

				_unique(ignore)
				_set_subtraction(intersection, ignore)

				var choice = intersection[rng.randi() % intersection.size()]

				if split_dir == Constants.Direction.HORIZONTAL:
					left_objects = node.left.get_objects_on_x_line(choice)
					left_objects.sort_custom(self, "sort_by_y2")

					right_objects = node.right.get_objects_on_x_line(choice)
					right_objects.sort_custom(self, "sort_by_y1")

					node.hall = Hall.new(
						choice, left_objects.back().y2(),
						right_objects.front().y1() - left_objects.back().y2()  + 1,
						Constants.Direction.VERTICAL
					)
				elif split_dir == Constants.Direction.VERTICAL:
					left_objects = node.left.get_objects_on_y_line(choice)
					left_objects.sort_custom(self, "sort_by_x2")

					right_objects = node.right.get_objects_on_y_line(choice)
					right_objects.sort_custom(self, "sort_by_x1")

					node.hall = Hall.new(
						left_objects.back().x2(), choice,
						right_objects.front().x1() - left_objects.back().x2() + 1,
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

	if y2 <= y1 or x2 <= x1 or (y2 - y1 < 2*Constants.MIN_ROOM_SIZE or x2 - x1 < 2*Constants.MIN_ROOM_SIZE):
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

func _ready():
	var cur_seed = null

	if cur_seed == null:
		rng.randomize()
	else:
		rng.set_seed(cur_seed)

	print_debug(rng.get_seed())

	var w = 64
	var h = 64
	
	var children = generate_tree(0, w-1, 0, h-1)
	var root = TNode.new(children["left"], children["right"], 0, 0, w, h)

	generate_rooms(root)
	generate_halls(root)

	_draw_dungeon(root)
