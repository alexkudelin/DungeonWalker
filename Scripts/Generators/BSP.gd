extends Node

class_name BSP_Generator

var BSPNode = load("res://Scripts/BSP/BSPNode.gd")
var Room = load("res://Scripts/BSP/Room.gd")
var Hall = load("res://Scripts/BSP/Hall.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")

var rng = null

var FLOOR = []
var WALLS = []
var STUFF = []


func _fill_level(node):
	if node:
		_fill_level(node.left)
		_fill_level(node.right)

		# for x in range(node.x1(), node.x2()):
		# 	WALLS[node.y1()][x] = Constants.WallTileCode.NODE_WALL
		# 	WALLS[node.y2()][x] = Constants.WallTileCode.NODE_WALL

		# for y in range(node.y1(), node.y2()+1):
		# 	WALLS[y][node.x1()] = Constants.WallTileCode.NODE_WALL
		# 	WALLS[y][node.x2()] = Constants.WallTileCode.NODE_WALL

		if node.room:
			var r = node.room

			for x in range(r.x1(), r.x2()+1):
				for y in range(r.y1(), r.y2()+1):
					FLOOR[y][x] = Constants.FloorTileCode.MID_FLOOR
					WALLS[y][x] = Constants.WallTileCode.EMPTY

			for x in range(r.x1(), r.x2()+1):
				WALLS[r.y1()][x] = Constants.WallTileCode.MID_WALL
				WALLS[r.y2()][x] = Constants.WallTileCode.MID_WALL

			for y in range(r.y1(), r.y2()+1):
				WALLS[y][r.x1()] = Constants.WallTileCode.MID_WALL
				WALLS[y][r.x2()] = Constants.WallTileCode.MID_WALL

			WALLS[r.y1()][r.x1()] = Constants.WallTileCode.MID_WALL
			WALLS[r.y1()][r.x2()] = Constants.WallTileCode.MID_WALL
			WALLS[r.y2()][r.x1()] = Constants.WallTileCode.MID_WALL
			WALLS[r.y2()][r.x2()] = Constants.WallTileCode.MID_WALL

		if node.hall:
			var h = node.hall

			for x in range(h.x1(), h.x1() + h.get_width()):
				for y in range(h.y1(), h.y1() + h.get_height()):
					FLOOR[y][x] = Constants.FloorTileCode.MID_FLOOR

			var hall_direction = h.get_direction()

			if hall_direction == Constants.Direction.HORIZONTAL:
				for x in range(h.x1()-1, h.x1() + h.get_width()):
					WALLS[h.y1()][x] = Constants.WallTileCode.MID_WALL
					WALLS[h.y2()][x] = Constants.WallTileCode.MID_WALL

				for x in range(h.x1()-1, h.x2()+1):
					WALLS[h.y][x] = Constants.WallTileCode.EMPTY
			elif hall_direction == Constants.Direction.VERTICAL:
				for y in range(h.y1()-1, h.y1() + h.get_height()):
					WALLS[y][h.x1()] = Constants.WallTileCode.MID_WALL
					WALLS[y][h.x2()] = Constants.WallTileCode.MID_WALL

				for y in range(h.y1()-1, h.y2() + 1):
					WALLS[y][h.x] = Constants.WallTileCode.EMPTY


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


func _get_wall(a, b):
	var borders = [a, b]

	borders.sort()
	borders = range(borders[0], borders[1])

	return borders[rng.randi() % borders.size()]


func generate_rooms(node):
	if node:
		if node.left or node.right:
			generate_rooms(node.left)
			generate_rooms(node.right)
		else:
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


func generate_tree(x1, x2, y1, y2, depth=1, max_depth=null):
	var left = null
	var right = null

	# initial check for room size
	if y2 <= y1 or x2 <= x1:
		return {"left": left, "right": right}

	if max_depth and depth > max_depth:
		return {"left": left, "right": right}

	var direction = null

	# if width is much bigger than height or ... 
	if (x2 - x1) / (y2 - y1) >= 1.25:
		direction = Constants.Direction.VERTICAL

	# ... height is much bigger than width we force the direction to part
	if (y2 - y1) / (x2 - x1) >= 1.25:
		direction = Constants.Direction.HORIZONTAL

	# if the situation is common we randomly choose direction
	if direction == null:
		direction = [Constants.Direction.VERTICAL, Constants.Direction.HORIZONTAL][rng.randi() % 2]

	# Then we check that if split both resulted partitions will be good
	var max_size = null

	if direction == Constants.Direction.VERTICAL:
		max_size = (x2 - x1)
	else:
		max_size = (y2 - y1)

	# Just check that dominating dimension can not suit two parts. If so, exit
	if max_size - Constants.MIN_ROOM_SIZE < Constants.MIN_ROOM_SIZE:
		return {"left": left, "right": right}

	var wall_shift = Constants.MIN_ROOM_FREE_SPACE + Constants.WALL_SIZE

	if direction == Constants.Direction.VERTICAL:
		var wall = _get_wall(x1 + wall_shift, x2 - wall_shift)
		var children = generate_tree(x1, wall, y1, y2, depth+1, max_depth)

		left = BSPNode.new(
			children["left"],
			children["right"],
			x1, y1, wall-x1+1, y2-y1+1,
			depth
		)

		children = generate_tree(wall, x2, y1, y2, depth+1, max_depth)

		right = BSPNode.new(
			children["left"],
			children["right"],
			wall, y1, x2-wall+1, y2-y1+1,
			depth
		)
	elif direction == Constants.Direction.HORIZONTAL:
		var wall = _get_wall(y1 + wall_shift, y2 - wall_shift)
		var children = generate_tree(x1, x2, y1, wall, depth+1, max_depth)

		left = BSPNode.new(
			children["left"],
			children["right"],
			x1, y1, x2-x1+1, wall-y1+1,
			depth
		)

		children = generate_tree(x1, x2, wall, y2, depth+1, max_depth)

		right = BSPNode.new(
			children["left"],
			children["right"],
			x1, wall, x2-x1+1, y2-wall+1,
			depth
		)

	return {"left": left, "right": right}


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
				if FLOOR[enter_y][enter_x] != Constants.FloorTileCode.EMPTY:
					enter_point = [enter_x, enter_y]
				else:
					ignore.append([enter_x, enter_y])

		if not exit_point:
			var exit_x = rng.randi_range(exit_room_bbox[0], exit_room_bbox[2])
			var exit_y = rng.randi_range(exit_room_bbox[1], exit_room_bbox[3])

			if not ignore.has([exit_x, exit_y]):
				if FLOOR[exit_y][exit_x] != Constants.FloorTileCode.EMPTY:
					exit_point = [exit_x, exit_y]
				else:
					ignore.append([exit_x, exit_y])

	STUFF[enter_point[1]][enter_point[0]] = Constants.StuffTileCode.LEVEL_ENTER
	STUFF[exit_point[1]][exit_point[0]] = Constants.StuffTileCode.LEVEL_EXIT

	return [enter_point, exit_point]


func run(w, h):
	var children = generate_tree(0, w-1, 0, h-1)
	var root = BSPNode.new(children["left"], children["right"], 0, 0, w, h)
	
	generate_rooms(root)
	generate_halls(root)

	_init_level(w, h)
	_fill_level(root)
	# _add_stuff(w, h)

	var start_and_end = _add_enter_and_exit(root)

	return {
		"floor": FLOOR,
		"walls": WALLS,
		"stuff": STUFF,
		"start": start_and_end[0],
		"end": start_and_end[1]
	}


func _init(_rng=null):
	if _rng:
		rng = _rng
	else:
		rng = RandomNumberGenerator.new()
