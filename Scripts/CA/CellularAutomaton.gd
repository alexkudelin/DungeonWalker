extends Node

class_name CellularAutomaton

var Constants = load("res://Scripts/Utils/Constants.gd")
var Utils = load("res://Scripts/Utils/Utils.gd")

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

			for item in Utils.get_von_neumann_nb(m, next_x, next_y):
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


func _make_step():
	var new_matrix = _copy_matrix(matrix)

	var w = len(matrix[0])
	var h = len(matrix)

	for x in range(w):
		for y in range(h):
			var nr = Utils.count_objects_in_nb(Utils.get_moore_nb(matrix, x, y), [Constants.CA_Tiles.DEAD])

			if nr > MIN_NUM_OF_NB_TO_ROOM_WALL:
				new_matrix[y][x] = Constants.CA_Tiles.DEAD
			elif nr < MAX_NUM_OF_NB_TO_SPACE:
				new_matrix[y][x] = Constants.CA_Tiles.ALIVE

	return new_matrix


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


func _smooth():
	var w = len(matrix[0])
	var h = len(matrix)

	while true:
		var q = []

		for x in range(1, w-1):
			for y in range(1, h-1):

				if matrix[y][x] == Constants.CA_Tiles.ALIVE:
					var nb = Utils.get_von_neumann_nb(matrix, x, y)
					var nc = Utils.count_objects_in_nb(nb, [Constants.CA_Tiles.ALIVE])

					if nc == 2:
						if nb[0] and nb[2] and nb[0][2] == Constants.CA_Tiles.ALIVE and nb[2][2] == Constants.CA_Tiles.ALIVE:
							q.append(nb[1])
							q.append(nb[3])
						elif nb[1] and nb[3] and nb[1][2] == Constants.CA_Tiles.ALIVE and nb[3][2] == Constants.CA_Tiles.ALIVE:
							q.append(nb[0])
							q.append(nb[2])

					nb = Utils.get_moore_nb(matrix, x, y)
					nc = Utils.count_objects_in_nb(nb, [Constants.CA_Tiles.DEAD])

					if nc == 2:
						if (nb[0] and nb[7] and nb[0][2] == Constants.CA_Tiles.DEAD and nb[7][2] == Constants.CA_Tiles.DEAD):
							q.append(nb[0])
							q.append(nb[7])
						elif(nb[2] and nb[5] and nb[2][2] == Constants.CA_Tiles.DEAD and nb[5][2] == Constants.CA_Tiles.DEAD):
							q.append(nb[2])
							q.append(nb[5])

		if not q:
			break
		else:
			while q:
				var p = q.pop_front()
				matrix[p[1]][p[0]] = Constants.CA_Tiles.ALIVE


func _set_borders():
	var w = len(matrix[0])
	var h = len(matrix)

	for x in range(w):
		for y in range(h):
			if x == 0 or x == w-1 or y == 0 or y == h-1:
				matrix[y][x] = Constants.CA_Tiles.DEAD


func _smooth_corners():
	var w = len(matrix[0])
	var h = len(matrix)

	var q = []

	for x in range(w):
		for y in range(h):
			if matrix[y][x] == Constants.CA_Tiles.DEAD:
				var n = Utils.get_von_neumann_nb(matrix, x, y)
				var counter = 0

				for nb in n:
					if nb and matrix[nb[1]][nb[0]] == Constants.CA_Tiles.OUTLINE:
						counter += 1

					if counter >= 2:
						q.append([x, y])
						break

	for p in q:
		matrix[p[1]][p[0]] = Constants.CA_Tiles.OUTLINE


func do_process(width, height):
	_init_matrix(width, height)
	_initial_matrix_fill()

	for _step in range(EPOCHS):
		matrix = _make_step()

	_set_borders()
	_fill_caverns()
	_smooth()
	_set_borders()


func _init(r, e, min_nbs_to_rock, max_nbs_to_space, _rng):
	R = r
	EPOCHS = e
	MIN_NUM_OF_NB_TO_ROOM_WALL = min_nbs_to_rock
	MAX_NUM_OF_NB_TO_SPACE = max_nbs_to_space
	rng = _rng
