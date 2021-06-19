class_name BSPNode

var Constants = load("res://Scripts/Utils/Constants.gd")

var left = null setget set_left, get_left
var right = null setget set_right, get_right
var x = null
var y = null
var width = null setget set_width, get_width
var height = null setget set_height, get_height
var depth = null
var room = null setget set_room, get_room
var hall = null setget set_hall, get_hall


func set_room(new_room):
	room = new_room

func get_room():
	return room

func set_hall(new_hall):
	hall = new_hall

func get_hall():
	return hall

func x1():
	return self.x

func x2():
	return self.x + self.width - 1

func y1():
	return self.y

func y2():
	return self.y + self.height - 1

func set_left(new_left):
	left = new_left

func get_left():
	return left

func set_right(new_right):
	right = new_right

func get_right():
	return right

func set_width(new_width):
	width = new_width

func get_width():
	return width

func set_height(new_height):
	height = new_height

func get_height():
	return height

func get_split_direction():
	var res = Constants.Direction.NONE

	if not left or not right:
		return res

	if max(0, min(left.x2(), right.x2()) - max(left.x1(), right.x1())):
		res |= Constants.Direction.HORIZONTAL

	if max(0, min(left.y2(), right.y2()) - max(left.y1(), right.y1())):
		res |= Constants.Direction.VERTICAL

	return res

func get_boundary_box():
	var x1 = null
	var y1 = null
	var x2 = null
	var y2 = null

	if room:
		x1 = room.x1()
		y1 = room.y1()
		x2 = room.x2()
		y2 = room.y2()
	else:
		if left:
			var res = left.get_boundary_box()
			x1 = res[0]
			y1 = res[1]

		if right:
			var res = right.get_boundary_box()
			x2 = res[2]
			y2 = res[3]

	return [x1, y1, x2, y2]

func get_objects():
	var objects = []
	var queue = [self]

	while queue:
		var node = queue.pop_front()

		if node:
			if node.hall:
				objects.append(node.hall)

			if node.room:
				objects.append(node.room)
			
			queue.append(node.left)
			queue.append(node.right)

	return objects

func get_objects_on_x_line(temp_x):
	var objects = []
	var queue = [self]

	while queue:
		var node = queue.pop_front()

		if node:
			if node.hall and node.hall.x1() <= temp_x and temp_x <= node.hall.x2():
				objects.append(node.hall)

			if node.room and node.room.x1() <= temp_x and temp_x <= node.room.x2():
				objects.append(node.room)

			queue.append(node.left)
			queue.append(node.right)

	return objects

func get_objects_on_y_line(temp_y):
	var objects = []
	var queue = [self]

	while queue:
		var node = queue.pop_front()

		if node:
			if node.hall and node.hall.y1() <= temp_y and temp_y <= node.hall.y2():
				objects.append(node.hall)

			if node.room and node.room.y1() <= temp_y and temp_y <= node.room.y2():
				objects.append(node.room)

			queue.append(node.left)
			queue.append(node.right)
	
	return objects

func get_leaves():
	var leaves = []
	var q = [self]

	while q:
		var node = q.pop_front()

		if node:
			if node.left and node.right:
				q.append(node.left)
				q.append(node.right)
			else:
				leaves.append(node)

	return leaves

func get_rooms():
	var rooms = []
	var q = [self]

	while q:
		var node = q.pop_front()

		if node:
			if node.room:
				rooms.append(node.room)
			else:
				q.append(node.left)
				q.append(node.right)

	return rooms

func _to_string():
	var s = ""
	for _i in range(depth):
		s += "=="

	s += (
		">" + "  x1=" + str(x1()) + "; y1=" + str(y1()) + 
		"; x2=" + str(x2()) + "; y2=" + str(y2()) +
		"; w=" + str(width) + "; h=" + str(height) + 
		"; room=" + str(room) + 
		"; hall=" + str(hall) + "\n"
	)

	if left:
		s += str(left)

	if right:
		s += str(right)

	return s

func _init(l, r, _x, _y, w, h, d=0):
	x = _x
	y = _y
	left = l
	right = r
	width = w
	height = h
	depth = d
