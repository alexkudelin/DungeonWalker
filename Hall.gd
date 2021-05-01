class_name Hall

var Constants = load("Constants.gd")

var x = null
var y = null
var width = null setget set_width, get_width
var height = null setget set_height, get_height
var length = null setget set_length, get_length
var thinness = null setget set_thinness, get_thinness
var direction = null setget set_direction, get_direction


func set_width(new_width):
	width = new_width

func get_width():
	return width

func set_height(new_height):
	height = new_height

func get_height():
	return height

func set_length(new_length):
	length = new_length

func get_length():
	return length

func set_thinness(new_thinness):
	thinness = new_thinness

func get_thinness():
	return thinness

func set_direction(new_direction):
	direction = new_direction

func get_direction():
	return direction

func x1():
	if direction == Constants.Direction.VERTICAL:
		return x - ceil((thinness - 1) / 2)
	elif direction == Constants.Direction.HORIZONTAL:
		return x

func x2():
	if direction == Constants.Direction.VERTICAL:
		return x + ceil((thinness - 1) / 2)
	elif direction == Constants.Direction.HORIZONTAL:
		return x + length - 1

func y1():
	if direction == Constants.Direction.VERTICAL:
		return y
	elif direction == Constants.Direction.HORIZONTAL:
		return y - ceil((thinness - 1) / 2)

func y2():
	if direction == Constants.Direction.VERTICAL:
		return y + length - 1
	elif direction == Constants.Direction.HORIZONTAL:
		return y + ceil((thinness - 1) / 2)

func _init(_x, _y, l, d, t=Constants.HALL_THINNESS):
	x = _x # X coordinate of hall axis
	y = _y # Y coordinate of hall axis
	length = l
	thinness = t # Better to be odd number
	direction = d
