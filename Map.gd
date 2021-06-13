extends Node2D

var TNode = load("res://TNode.gd")
var Room = load("res://Room.gd")
var Hall = load("res://Hall.gd")
var Constants = load("res://Constants.gd")
var CellularAutomaton = load("res://CellularAutomaton.gd")

var BSP_Generator = load("res://BSP.gd")
var BSP_CA_Generator = load("res://BSP_CA_Hybrid.gd")

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

onready var HALL_FLOOR_TILE_1 = FLOOR.tile_set.find_tile_by_name("stoneInset_E")
onready var HALL_FLOOR_TILE_2 = FLOOR.tile_set.find_tile_by_name("dirtTiles_E")

onready var NODE_WALL_TILE_1 = FLOOR.tile_set.find_tile_by_name("planks_E")
onready var NODE_WALL_TILE_2 = FLOOR.tile_set.find_tile_by_name("planksHole_E")

onready var WALL_TILE_N = WALLS.tile_set.find_tile_by_name("wall_mid")
onready var WALL_TILE_S = WALLS.tile_set.find_tile_by_name("wall_mid")
onready var WALL_TILE_E = WALLS.tile_set.find_tile_by_name("wall_side_mid_right")
onready var WALL_TILE_W = WALLS.tile_set.find_tile_by_name("wall_side_mid_left")

onready var WALL_CORNER_TILE_NW = WALLS.tile_set.find_tile_by_name("wall_inner_corner_mid_left")
onready var WALL_CORNER_TILE_NE = WALLS.tile_set.find_tile_by_name("wall_inner_corner_mid_right")
onready var WALL_CORNER_TILE_SW = WALLS.tile_set.find_tile_by_name("wall_corner_bottom_left")
onready var WALL_CORNER_TILE_SE = WALLS.tile_set.find_tile_by_name("wall_corner_bottom_right")


onready var CodeToTile = {
	Constants.TileCodes.ROOM_FLOOR: [
		ROOM_FLOOR_TILE_1,
		ROOM_FLOOR_TILE_2,
		ROOM_FLOOR_TILE_3,
		ROOM_FLOOR_TILE_4,
		ROOM_FLOOR_TILE_5,
		ROOM_FLOOR_TILE_6,
		ROOM_FLOOR_TILE_7,
		ROOM_FLOOR_TILE_8
	],

	Constants.TileCodes.NE_CORNER: WALL_CORNER_TILE_NE,
	Constants.TileCodes.NW_CORNER: WALL_CORNER_TILE_NW,
	Constants.TileCodes.SE_CORNER: WALL_CORNER_TILE_SE,
	Constants.TileCodes.SW_CORNER: WALL_CORNER_TILE_SW,

	Constants.TileCodes.NORTH_WALL: WALL_TILE_S,
	Constants.TileCodes.EAST_WALL: WALL_TILE_W,
	Constants.TileCodes.SOUTH_WALL: WALL_TILE_N,
	Constants.TileCodes.WEST_WALL: WALL_TILE_E,

	Constants.TileCodes.NODE_WALL: NODE_WALL_TILE_1,

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

			if level_walls[y][x] != Constants.TileCodes.EMPTY:
				WALLS.set_cell(x, y, CodeToTile[level_walls[y][x]])


# func bsp_ca_hybrid(w, h):
# 	var children = generate_tree(0, w-1, 0, h-1)
# 	var root = TNode.new(children["left"], children["right"], 0, 0, w, h)

# 	for leaf in root.get_leafs():
# 		var ca = CellularAutomaton.new(0.55, 6, 6, 2, rng)
# 		ca.do_process(leaf.get_width()-2, leaf.get_height()-2)
# 		leaf.set_room(ca)

# 		for i in range(leaf.get_width()-2):
# 			for j in range(leaf.get_height()-2):
# 				FLOOR.set_cell(leaf.x1() + i+1, leaf.y1() + j+1, [ROOM_FLOOR_TILE_1, -1, NODE_WALL_TILE_1][leaf.room.matrix[j][i]])

#				if res[j][i] == 2:
#					if is_vertical(res, i, j):
#						WALLS.set_cell(leaf.x1() + i+1, leaf.y1() + j+1, [WALL_TILE_N, WALL_TILE_N_2][(i+j)%2])
#					elif is_horizontal(res, i, j):
#						WALLS.set_cell(leaf.x1() + i+1, leaf.y1() + j+1, [WALL_TILE_E, WALL_TILE_E_2][(i+j)%2])
#					elif is_corner(res, i, j):
#						pass


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

		var bsp = BSP_Generator.new(rng)
		bsp.run(w, h)
		# bsp_ca_hybrid(w, h)

		var map = bsp.get_map()
		_draw_dungeon(map)

