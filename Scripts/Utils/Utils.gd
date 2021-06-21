class_name Utils

class DistanceSorter:
	static func sort_asc(a, b):
		return a[2] < b[2]

static func get_von_neumann_nb(m, x, y):
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


static func count_objects_in_nb(neighbourhood, objects):
	var c = 0

	for item in neighbourhood:
		if item != null and item[2] in objects:
			c += 1

	return c


static func get_moore_nb(m, x, y):
	var nb = []

	for xt in [x-1, x, x+1]:
		for yt in [y-1, y, y+1]:
			if xt == x and yt == y:
				continue

			if (0 <= xt and xt < len(m[0])) and (0 <= yt and yt < len(m)):
				nb.append([xt, yt, m[yt][xt]])
			else:
				nb.append(null)

	return nb


static func distance(p1, p2):
	return sqrt(pow((p1[0] - p2[0]), 2) + pow((p1[1] - p2[1]), 2))


static func lerp(start, end, t):
	return start + t * (end - start)


static func lerp_point(p1, p2, t):
	return [lerp(p1[0], p2[0], t), lerp(p1[1], p2[1], t)]


static func line(p1, p2, _d=null):
	var points = []
	var d = _d
	if d == null:
		d = distance(p1, p2)

	var steps = ceil(d)

	for step in range(1, steps):
		var t = step / d
		points.append(lerp_point(p1, p2, t))

	return points
