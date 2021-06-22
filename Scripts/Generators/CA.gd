extends Node

class_name CA_Generator

var CellularAutomaton = load("res://Scripts/CA/CellularAutomaton.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")
var Utils = load("res://Scripts/Utils/Utils.gd")

var rng = null

var FLOOR = null
var WALLS = null

func _outline():
	var w = len(FLOOR[0])
	var h = len(FLOOR)

	var outline = []

	for x in range(w):
		for y in range(h):
			if FLOOR[y][x] == Constants.FloorTileCode.MID_FLOOR:
				for nb in Utils.get_moore_nb(FLOOR, x, y):
					if nb and nb[2] == Constants.FloorTileCode.EMPTY:
						outline.append(nb)

	for item in outline:
		WALLS[item[1]][item[0]] = Constants.WallTileCode.MID_WALL
		FLOOR[item[1]][item[0]] = Constants.FloorTileCode.MID_FLOOR


func _fill_singles():
	var w = len(FLOOR[0])
	var h = len(FLOOR)

	var singles_walls = []
	var singles_floors = []

	while true:
		for x in range(w):
			for y in range(h):
				if FLOOR[y][x] == Constants.FloorTileCode.EMPTY:
					var nbhood = Utils.get_moore_nb(WALLS, x, y)

					if Utils.count_objects_in_nb(nbhood, [Constants.WallTileCode.MID_WALL]) >= 7:
						singles_walls.append([x, y, Constants.WallTileCode.MID_WALL])
						singles_floors.append([x, y, Constants.FloorTileCode.MID_FLOOR])

		if not (singles_walls and singles_floors):
			break
		else:
			while singles_walls or singles_floors:
				if singles_walls:
					var item = singles_walls.pop_front()
					WALLS[item[1]][item[0]] = item[2]
				if singles_floors:
					var item = singles_floors.pop_front()
					FLOOR[item[1]][item[0]] = item[2]


func _fill_level(room):
	for i in range(room.get_width()):
		for j in range(room.get_height()):
			var x = room.x1() + i
			var y = room.y1() + j
			var val = room.ca.matrix[j][i]

			if val == Constants.CA_Tiles.ALIVE:
				FLOOR[y][x] = Constants.FloorTileCode.MID_FLOOR
				WALLS[y][x] = Constants.WallTileCode.EMPTY
			elif val == Constants.CA_Tiles.DEAD:
				FLOOR[y][x] = Constants.FloorTileCode.EMPTY
				WALLS[y][x] = Constants.WallTileCode.EMPTY


func _init_level(w, h):
	FLOOR = []
	WALLS = []

	for i in range(w):
		FLOOR.append([])
		WALLS.append([])

		for _j in range(h):
			FLOOR[i].append(Constants.FloorTileCode.EMPTY)
			WALLS[i].append(Constants.WallTileCode.EMPTY)


func run(w, h):
	var ca = CellularAutomaton.new(0.475, 4, 6, 3, rng)
	ca.do_process(w-2, h-2)
	var room = CARoom.new(
		ca, 1, 1, w-2, h-2
	)

	_init_level(w, h)
	_fill_level(room)
	_outline()
	_fill_singles()


func get_map():
	return {
		"floor": FLOOR,
		"walls": WALLS
	}


func _init(_rng=null):
	if _rng:
		rng = _rng
	else:
		rng = RandomNumberGenerator.new()
