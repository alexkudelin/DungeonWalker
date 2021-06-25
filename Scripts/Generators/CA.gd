extends Node

class_name CA_Generator

var CellularAutomaton = load("res://Scripts/CA/CellularAutomaton.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")
var Utils = load("res://Scripts/Utils/Utils.gd")
var CommonAlgos = load("res://Scripts/Generators/Common.gd")

var rng = null

var FLOOR = []
var WALLS = []
var STUFF = []

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


func _add_enter_and_exit():
	var enter_point = []
	var exit_point = []

	var ignore = []

	while not enter_point or not exit_point:
		if not enter_point:
			var enter_x = rng.randi_range(0, FLOOR[0].size()-1)
			var enter_y = rng.randi_range(0, FLOOR.size())

			if not ignore.has([enter_x, enter_y]):
				if FLOOR[enter_y][enter_x] != Constants.FloorTileCode.EMPTY:
					enter_point = [enter_x, enter_y]
				else:
					ignore.append([enter_x, enter_y])

		if not exit_point:
			var exit_x = rng.randi_range(0, FLOOR[0].size()-1)
			var exit_y = rng.randi_range(0, FLOOR.size())

			if not ignore.has([exit_x, exit_y]):
				if FLOOR[exit_y][exit_x] != Constants.FloorTileCode.EMPTY:
					exit_point = [exit_x, exit_y]
				else:
					ignore.append([exit_x, exit_y])

	STUFF[enter_point[1]][enter_point[0]] = Constants.StuffTileCode.LEVEL_ENTER
	STUFF[exit_point[1]][exit_point[0]] = Constants.StuffTileCode.LEVEL_EXIT

	return [enter_point, exit_point]


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

	CommonAlgos.new(rng).add_stuff(FLOOR, WALLS, STUFF)

	var start_and_end = _add_enter_and_exit()

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
