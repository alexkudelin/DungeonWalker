extends Node2D

var BSPNode = load("res://Scripts/BSP/BSPNode.gd")
var Room = load("res://Scripts/BSP/Room.gd")
var Hall = load("res://Scripts/BSP/Hall.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")
var CellularAutomaton = load("res://Scripts/CA/CellularAutomaton.gd")

var BSP_Generator = load("res://Scripts/Generators/BSP.gd")
var BSP_CA_Generator = load("res://Scripts/Generators/BSP_CA_Hybrid.gd")

var rng = RandomNumberGenerator.new()

onready var FLOOR = $Floor
onready var WALLS = $Walls

onready var ROOM_FLOOR_TILE_1 = FLOOR.tile_set.find_tile_by_name("floor_1")
onready var ROOM_FLOOR_TILE_2 = FLOOR.tile_set.find_tile_by_name("floor_2")
onready var ROOM_FLOOR_TILE_3 = FLOOR.tile_set.find_tile_by_name("floor_3")
onready var ROOM_FLOOR_TILE_4 = FLOOR.tile_set.find_tile_by_name("floor_4")
onready var ROOM_FLOOR_TILE_5 = FLOOR.tile_set.find_tile_by_name("floor_5")
onready var ROOM_FLOOR_TILE_6 = FLOOR.tile_set.find_tile_by_name("floor_6")
onready var ROOM_FLOOR_TILE_7 = FLOOR.tile_set.find_tile_by_name("floor_7")
onready var ROOM_FLOOR_TILE_8 = FLOOR.tile_set.find_tile_by_name("floor_8")

onready var HALL_FLOOR_TILE_8 = FLOOR.tile_set.find_tile_by_name("hole")

onready var NODE_WALL_TILE_1 = FLOOR.tile_set.find_tile_by_name("planks_E")
onready var NODE_WALL_TILE_2 = FLOOR.tile_set.find_tile_by_name("planksHole_E")

onready var WALL_TILE_N = WALLS.tile_set.find_tile_by_name("wall_mid")
onready var WALL_TILE_S = WALLS.tile_set.find_tile_by_name("wall_mid")
onready var WALL_TILE_E = WALLS.tile_set.find_tile_by_name("wall_side_mid_right")
onready var WALL_TILE_W = WALLS.tile_set.find_tile_by_name("wall_side_mid_left")

onready var WALL_TILE_TOP_N = WALLS.tile_set.find_tile_by_name("wall_top_mid")
onready var WALL_TILE_TOP_S = WALLS.tile_set.find_tile_by_name("wall_top_mid")
onready var WALL_TILE_TOP_E = WALLS.tile_set.find_tile_by_name("wall_inner_corner_t_top_right")
onready var WALL_TILE_TOP_W = WALLS.tile_set.find_tile_by_name("wall_inner_corner_t_top_left")

onready var WALL_CORNER_TILE_NW = WALLS.tile_set.find_tile_by_name("wall_inner_corner_mid_left")
onready var WALL_CORNER_TILE_NE = WALLS.tile_set.find_tile_by_name("wall_inner_corner_mid_right")
onready var WALL_CORNER_TILE_SW = WALLS.tile_set.find_tile_by_name("wall_corner_bottom_left")
onready var WALL_CORNER_TILE_SE = WALLS.tile_set.find_tile_by_name("wall_corner_bottom_right")

onready var CodeToTile = {
	Constants.TileCodes.ROOM_FLOOR: [
		ROOM_FLOOR_TILE_1,
		# ROOM_FLOOR_TILE_2,
		# ROOM_FLOOR_TILE_3,
		# ROOM_FLOOR_TILE_4,
		# ROOM_FLOOR_TILE_5,
		# ROOM_FLOOR_TILE_6,
		# ROOM_FLOOR_TILE_7,
		# ROOM_FLOOR_TILE_8,
	],

	Constants.TileCodes.HALL_FLOOR: [
		HALL_FLOOR_TILE_8,
	],

	Constants.TileCodes.NE_CORNER: WALL_CORNER_TILE_NE,
	Constants.TileCodes.NW_CORNER: WALL_CORNER_TILE_NW,
	Constants.TileCodes.SE_CORNER: WALL_CORNER_TILE_SE,
	Constants.TileCodes.SW_CORNER: WALL_CORNER_TILE_SW,

	Constants.TileCodes.NORTH_WALL: WALL_TILE_S,
	Constants.TileCodes.EAST_WALL: WALL_TILE_W,
	Constants.TileCodes.SOUTH_WALL: WALL_TILE_N,
	Constants.TileCodes.WEST_WALL: WALL_TILE_E,

	Constants.TileCodes.NODE_WALL: [HALL_FLOOR_TILE_8],

	Constants.TileCodes.EMPTY: [-1],
}


func _draw_dungeon(map):
	var level_floor = map["floor"]
	var level_walls = map["walls"]

	var w = len(level_floor[0])
	var h = len(level_floor)

	for x in range(w):
		for y in range(h):
			if level_floor[y][x] != Constants.TileCodes.EMPTY:
				var tiles = CodeToTile[level_floor[y][x]]
				FLOOR.set_cell(x, y, tiles[rng.randi() % tiles.size()])

#			if level_walls[y][x] != Constants.TileCodes.EMPTY:
#				if level_walls[y][x] == Constants.TileCodes.NORTH_WALL:
#					WALLS.set_cell(x, y-1, CodeToTile[level_walls[y][x]])
#					WALLS.set_cell(x, y-2, WALL_TILE_TOP_N)
#				elif level_walls[y][x] == Constants.TileCodes.SOUTH_WALL:
#					WALLS.set_cell(x, y, CodeToTile[level_walls[y][x]])
#					WALLS.set_cell(x, y-1, WALL_TILE_TOP_S)
#				elif level_walls[y][x] in [Constants.TileCodes.EAST_WALL, Constants.TileCodes.WEST_WALL]:
#					WALLS.set_cell(x, y, CodeToTile[level_walls[y][x]])
#				elif level_walls[y][x] == Constants.TileCodes.SE_CORNER:
#					WALLS.set_cell(x, y, WALL_TILE_S)
#					WALLS.set_cell(x, y-1, WALL_CORNER_TILE_SE)
#				elif level_walls[y][x] == Constants.TileCodes.SW_CORNER:
#					WALLS.set_cell(x, y, WALL_TILE_S)
#					WALLS.set_cell(x, y-1, WALL_CORNER_TILE_SW)
#				elif level_walls[y][x] == Constants.TileCodes.NE_CORNER:
#					WALLS.set_cell(x, y, WALL_TILE_W)
#					WALLS.set_cell(x, y-1, WALL_CORNER_TILE_NE)
#					WALLS.set_cell(x, y-2, WALL_TILE_TOP_E)
#				elif level_walls[y][x] == Constants.TileCodes.NW_CORNER:
#					WALLS.set_cell(x, y, WALL_TILE_E)
#					WALLS.set_cell(x, y-1, WALL_CORNER_TILE_NW)
#					WALLS.set_cell(x, y-2, WALL_TILE_TOP_W)

func _clean(w, h):
	for i in range(w):
		for j in range(h):
			FLOOR.set_cell(i, j, -1)
			WALLS.set_cell(i, j, -1)


func _process(_delta):
	if Input.is_action_just_pressed("recreate_map"):
		var w = 64
		var h = 64

		_clean(w, h)

		var cur_seed = null

		if cur_seed == null:
			rng.randomize()
		else:
			rng.set_seed(cur_seed)

		print_debug(rng.get_seed())

		var bsp = BSP_CA_Generator.new(rng)
		bsp.run(w, h)

		var map = bsp.get_map()
		_draw_dungeon(map)
