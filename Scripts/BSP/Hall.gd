class_name Hall

var Constants = load("res://Scripts/Utils/Constants.gd")

var x = null
var y = null
var width = null setget , get_width
var height = null setget , get_height
var length = null setget set_length, get_length
var thinness = null setget set_thinness, get_thinness
var direction = null setget set_direction, get_direction


func get_width():
	if direction == Constants.Direction.VERTICAL:
		return x2() - x1() + 1
	elif direction == Constants.Direction.HORIZONTAL:
		return x2() - x1()

func get_height():
	if direction == Constants.Direction.VERTICAL:
		return y2() - y1()
	elif direction == Constants.Direction.HORIZONTAL:
		return y2() - y1() + 1

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

func _to_string():
	return ("[Hall] => " +
		"x=" + str(x) + "; y=" + str(y) +
		"; x1=" + str(x1()) + "; y1=" + str(y1()) + 
		"; x2=" + str(x2()) + "; y2=" + str(y2()) +
		"; w=" + str(get_width()) + "; h=" + str(get_height()) + "; d=" + str(direction)
	)

func _init(_x, _y, l, d, t=Constants.HALL_THINNESS):
	x = _x # X coordinate of hall axis
	y = _y # Y coordinate of hall axis
	length = l
	thinness = t # Better to be odd number
	direction = d
