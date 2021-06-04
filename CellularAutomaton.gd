class_name CellularAutomaton

var rng = null

const SPACE = 0  # alive
const ROCK = 1  # dead
const SPACE_OUTLINE = 2  # outline of space

# Best fallback options = (0.44, 5, 5, 3)
var R = null
var EPOCHS = null
var MIN_NUM_OF_NB_TO_ROCK = null
var MAX_NUM_OF_NB_TO_SPACE = null


class DistributionSorter:
	static func sort_by_purified_desc(a, b):
		return a[1] > b[1]

func _init_matrix(width, height):
	var matrix = []

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


func _initial_matrix_fill(matrix):
	for y in range(len(matrix)):
		for x in range(len(matrix[y])):
			if x == 0 or x == len(matrix[y])-1 or y == 0 or y == len(matrix)-1:
				matrix[y][x] = ROCK
			else:
				matrix[y][x] = [SPACE, ROCK][int(rng.randf() < R)]


func _get_moore_neighbourhood(m, x, y, count_spaces=false):
	var n = 0

	for i in range(x-1, (x+1) + 1):
		for j in range(y-1, (y+1) + 1):
			if (0 <= i and i < len(m[0])) and (0 <= j and j < len(m)):
				n += m[j][i]
			else:
				n += 1

	if count_spaces:
		return 8 - n
	else:
		return n


func _get_von_neumann_neighbourhood_count(m, x, y, count_spaces=false):
	var n = 0

	for i in [-1, 1]:
		if (0 <= (x+i) and (x+i) < len(m[0])):
			n += m[y][x+i]
		else:
			n += 1

	for j in [-1, 1]:
		if (0 <= (y+j) and (y+j) < len(m)):
			n += m[y+j][x]
		else:
			n += 1

	if count_spaces:
		return 4 - n
	else:
		return n



func _get_von_neumann_neighbourhood(m, x, y):
	var n = []

	if y - 1 >= 0:
		n.append([x, y-1, m[y-1][x]])
	else:
		n.append(null)

	if x + 1 < len(m[0]):
		n.append([x+1, y, m[y][x+1]])
	else:
		n.append(null)

	if y + 1 < len(m):
		n.append([x, y+1, m[y+1][x]])
	else:
		n.append(null)

	if x - 1 >= 0:
		n.append([x-1, y, m[y][x-1]])
	else:
		n.append(null)

	return n
	

func _make_step(matrix):
	var new_matrix = _copy_matrix(matrix)

	var w = len(matrix[0])
	var h = len(matrix)

	for x in range(w):
		for y in range(h):
			var n = _get_moore_neighbourhood(matrix, x, y)

			if n > MIN_NUM_OF_NB_TO_ROCK:
				new_matrix[y][x] = ROCK
			elif n < MAX_NUM_OF_NB_TO_SPACE:
				new_matrix[y][x] = SPACE

	return new_matrix


func __pourify(m, x, y, color):
	var pourified = 0
	var q = [[x, y]]

	while len(q) > 0:
		var t = q.pop_front()
		var next_x = t[0]
		var next_y = t[1]

		if m[next_y][next_x] == SPACE:
			m[next_y][next_x] = color
			pourified += 1

			for item in _get_von_neumann_neighbourhood(m, next_x, next_y):
				if item != null:
					q.append([item[0], item[1]])

	return pourified


func _pourify(w, h, m):
	var color_distribution = {}
	var color = max(max(SPACE, ROCK), SPACE_OUTLINE) + 1
	var counter = 0

	var y = counter / w
	var x = counter % w

	while x*y < (w-1)*(h-1):
		if m[y][x] == SPACE:
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

	color_distrib_arr.sort_custom(DistributionSorter, "sort_by_purified_desc")

	return color_distrib_arr[0][0]


func _fill_caverns(m):
	var w = len(m[0])
	var h = len(m)

	var color_distribution = _pourify(w, h, m)

	if color_distribution.keys().size() > 0:
		var dominant_color = _find_dominant_color(color_distribution)

		for x in range(w):
			for y in range(h):
				if m[y][x] != dominant_color:
					m[y][x] = ROCK
				else:
					m[y][x] = SPACE


func _set_border_rocks(m):
	var w = len(m[0])
	var h = len(m)

	for x in range(w):
		for y in range(h):
			if x == 0 or x == w-1 or y == 0 or y == h-1:
				m[y][x] = ROCK


func _highlight_room_outline(m):
	var w = len(m[0])
	var h = len(m)

	var q = []

	for x in range(w):
		for y in range(h):
			if m[y][x] == ROCK and _get_von_neumann_neighbourhood_count(m, x, y, true) > 0:
				q.append([x,y])

	for t in q:
		m[t[1]][t[0]] = SPACE_OUTLINE


func _smooth_corners(m):
	var w = len(m[0])
	var h = len(m)

	var q = []

	for x in range(w):
		for y in range(h):
			if m[y][x] == ROCK:
				var n = _get_von_neumann_neighbourhood(m, x, y)
				var counter = 0

				for nb in n:
					if nb != null and m[nb[1]][nb[0]] == SPACE_OUTLINE:
						counter += 1

					if counter >= 2:
						q.append([x, y])
						break

	for t in q:
		m[t[1]][t[0]] = SPACE_OUTLINE


func do_process(width, height):
	var matrix = _init_matrix(width, height)
	_initial_matrix_fill(matrix)

	for _step in range(EPOCHS):
		matrix = _make_step(matrix)

	while true:
		var q = []

		for x in range(1, width-1):
			for y in range(1, height-1):
				if matrix[y][x] == ROCK:
					var nc = _get_von_neumann_neighbourhood_count(matrix, x, y, true)

					if nc >= 3:
						q.append([x, y])

						for item in _get_von_neumann_neighbourhood(matrix, x, y):
							if item != null and item[2] == ROCK:
								if _get_von_neumann_neighbourhood_count(matrix, item[0], item[1]) >= 3:
									q.append([item[0], item[1]])
					elif nc == 2:
						var n = _get_von_neumann_neighbourhood(matrix, x, y)

						var vertical_nbs_are_spaces = (n[0] and n[2] and n[0][2] == SPACE and n[2][2] == SPACE)
						var horizontal_nbs_are_spaces = (n[1] and n[3] and n[1][2] == SPACE and n[3][2] == SPACE)

						if vertical_nbs_are_spaces or horizontal_nbs_are_spaces:
							q.append([x, y])

		if not q:
			break
		else:
			while q:
				var t = q.pop_front()
				var x = t[0]
				var y = t[1]

				matrix[y][x] = SPACE

	_fill_caverns(matrix)
	_set_border_rocks(matrix)
	_highlight_room_outline(matrix)
	_smooth_corners(matrix)

	return matrix


func _init(r, e, min_nbs_to_rock, max_nbs_to_space, _rng):
	R = r
	EPOCHS = e
	MIN_NUM_OF_NB_TO_ROCK = min_nbs_to_rock
	MAX_NUM_OF_NB_TO_SPACE = max_nbs_to_space
	rng = _rng
