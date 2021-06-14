extends Node

class_name CellularAutomaton

var Constants = load("res://Scripts/Utils/Constants.gd")

var rng = null

# const ROOM_OUTLINE = 2  # outline of room

var R = null
var EPOCHS = null
var MIN_NUM_OF_NB_TO_ROOM_WALL = null
var MAX_NUM_OF_NB_TO_SPACE = null

var matrix = []


class DistributionSorter:
	static func sort_by_pourified_desc(a, b):
		return a[1] > b[1]


func _init_matrix(width, height):
	for _y in range(height):
		var row = []

		for _x in range(width):
			row.append(0)

		matrix.append(row)

	return matrix


func _copy_matrix(source):
	var target = []

	for row in source:
		var temp_row = []

		for val in row:
			temp_row.append(val)

		target.append(row)

	return target


func _initial_matrix_fill():
	for y in range(len(matrix)):
		for x in range(len(matrix[y])):
			if x == 0 or x == len(matrix[y])-1 or y == 0 or y == len(matrix)-1:
				matrix[y][x] = Constants.CA_Tiles.DEAD
			else:
				matrix[y][x] = [Constants.CA_Tiles.ALIVE, Constants.CA_Tiles.DEAD][int(rng.randf() < R)]


func _get_moore_neighbourhood(m, x, y):
	var nb = []

	for i in [x-1, x, x+1]:
		for j in [y-1, y, y+1]:
			if i == x and j == y:
				continue

			if (0 <= i and i < len(m[0])) and (0 <= j and j < len(m)):
				nb.append([i, j, m[j][i]])
			else:
				nb.append(null)

	return nb


func _count_objects_in_nb(neighbourhood, objects):
	var c = 0

	for item in neighbourhood:
		if item != null and item[2] in objects:
			c += 1

	return c


func _get_von_neumann_nb(m, x, y):
	var nb = []

	if y - 1 >= 0:
		nb.append([x, y-1, m[y-1][x]])
	else:
		nb.append(null)

	if x + 1 < len(m[0]):
		nb.append([x+1, y, m[y][x+1]])
	else:
		nb.append(null)

	if y + 1 < len(m):
		nb.append([x, y+1, m[y+1][x]])
	else:
		nb.append(null)

	if x - 1 >= 0:
		nb.append([x-1, y, m[y][x-1]])
	else:
		nb.append(null)

	return nb
	

func _make_step():
	var new_matrix = _copy_matrix(matrix)

	var w = len(matrix[0])
	var h = len(matrix)

	for x in range(w):
		for y in range(h):
			var nr = _count_objects_in_nb(_get_moore_neighbourhood(matrix, x, y), [Constants.CA_Tiles.DEAD])

			if nr > MIN_NUM_OF_NB_TO_ROOM_WALL:
				new_matrix[y][x] = Constants.CA_Tiles.DEAD
			elif nr < MAX_NUM_OF_NB_TO_SPACE:
				new_matrix[y][x] = Constants.CA_Tiles.ALIVE

	return new_matrix


func __pourify(m, x, y, color):
	var pourified = 0
	var q = [[x, y]]

	while len(q) > 0:
		var t = q.pop_front()
		var next_x = t[0]
		var next_y = t[1]

		if m[next_y][next_x] == Constants.CA_Tiles.ALIVE:
			m[next_y][next_x] = color
			pourified += 1

			for item in _get_von_neumann_nb(m, next_x, next_y):
				if item != null:
					q.append([item[0], item[1]])

	return pourified


func _pourify(w, h, m):
	var color_distribution = {}
	var color = 100
	var counter = 0

	var y = counter / w
	var x = counter % w

	while x*y < (w-1)*(h-1):
		if m[y][x] == Constants.CA_Tiles.ALIVE:
			color_distribution[color] = __pourify(m, x, y, color)
			color += 1

		counter += 1
		y = counter / w
		x = counter % w

	return color_distribution


func _find_dominant_color(color_distrib):
	var color_distrib_arr = []

	for k in color_distrib.keys():
		color_distrib_arr.append([k, color_distrib[k]])

	color_distrib_arr.sort_custom(DistributionSorter, "sort_by_pourified_desc")

	return color_distrib_arr[0][0]


func _smooth_singles():
	var w = len(matrix[0])
	var h = len(matrix)

	while true:
		var q = []

		for x in range(1, w-1):
			for y in range(1, h-1):
				if matrix[y][x] == Constants.CA_Tiles.DEAD:
					var nb = _get_von_neumann_nb(matrix, x, y)
					var nc = _count_objects_in_nb(nb, [Constants.CA_Tiles.ALIVE])

					if nc >= 3:
						q.append([x, y])

						for item in _get_von_neumann_nb(matrix, x, y):
							if item != null and item[2] == Constants.CA_Tiles.DEAD:
								if _count_objects_in_nb(_get_von_neumann_nb(matrix, item[0], item[1]), [Constants.CA_Tiles.DEAD]) >= 3:
									q.append([item[0], item[1]])
					elif nc == 2:
						var n = _get_von_neumann_nb(matrix, x, y)

						var vertical_nbs_are_spaces = (n[0] and n[2] and n[0][2] == Constants.CA_Tiles.ALIVE and n[2][2] == Constants.CA_Tiles.ALIVE)
						var horizontal_nbs_are_spaces = (n[1] and n[3] and n[1][2] == Constants.CA_Tiles.ALIVE and n[3][2] == Constants.CA_Tiles.ALIVE)

						if vertical_nbs_are_spaces or horizontal_nbs_are_spaces:
							q.append([x, y])
		if not q:
			break
		else:
			while q:
				var t = q.pop_front()
				var x = t[0]
				var y = t[1]
	
				matrix[y][x] = Constants.CA_Tiles.ALIVE


func _fill_caverns():
	var w = len(matrix[0])
	var h = len(matrix)

	var color_distribution = _pourify(w, h, matrix)

	if color_distribution.keys().size() > 0:
		var dominant_color = _find_dominant_color(color_distribution)

		for x in range(w):
			for y in range(h):
				if matrix[y][x] != dominant_color:
					matrix[y][x] = Constants.CA_Tiles.DEAD
				else:
					matrix[y][x] = Constants.CA_Tiles.ALIVE


func _set_borders():
	var w = len(matrix[0])
	var h = len(matrix)

	for x in range(w):
		for y in range(h):
			if x == 0 or x == w-1 or y == 0 or y == h-1:
				matrix[y][x] = Constants.CA_Tiles.DEAD


# func _highlight_room_outline():
# 	var w = len(matrix[0])
# 	var h = len(matrix)

# 	var q = []

# 	for x in range(w):
# 		for y in range(h):
# 			if matrix[y][x] == Constants.CA_Tiles.DEAD:
# 				var nb = _get_von_neumann_nb(matrix, x, y)

# 				if _count_objects_in_nb(nb, [Constants.CA_Tiles.ALIVE]) > 0:
# 					q.append([x,y])

# 	for t in q:
# 		matrix[t[1]][t[0]] = ROOM_OUTLINE


# func _smooth_corners():
# 	var w = len(matrix[0])
# 	var h = len(matrix)

# 	var q = []

# 	for x in range(w):
# 		for y in range(h):
# 			if matrix[y][x] == Constants.CA_Tiles.DEAD:
# 				var n = _get_von_neumann_nb(matrix, x, y)
# 				var counter = 0

# 				for nb in n:
# 					if nb != null and matrix[nb[1]][nb[0]] == ROOM_OUTLINE:
# 						counter += 1

# 					if counter >= 2:
# 						q.append([x, y])
# 						break

# 	for t in q:
# 		matrix[t[1]][t[0]] = ROOM_OUTLINE


func do_process(width, height):
	_init_matrix(width, height)
	_initial_matrix_fill()

	for _step in range(EPOCHS):
		matrix = _make_step()

	_smooth_singles()
	_fill_caverns()
	_set_borders()
	# _highlight_room_outline()
	# _smooth_corners()


func _init(r, e, min_nbs_to_rock, max_nbs_to_space, _rng):
	R = r
	EPOCHS = e
	MIN_NUM_OF_NB_TO_ROOM_WALL = min_nbs_to_rock
	MAX_NUM_OF_NB_TO_SPACE = max_nbs_to_space
	rng = _rng