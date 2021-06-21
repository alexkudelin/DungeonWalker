extends Node2D

var BSPNode = load("res://Scripts/BSP/BSPNode.gd")
var Room = load("res://Scripts/BSP/Room.gd")
var Hall = load("res://Scripts/BSP/Hall.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")
var CellularAutomaton = load("res://Scripts/CA/CellularAutomaton.gd")

var BSP_Generator = load("res://Scripts/Generators/BSP.gd")
var BSP_CA_Generator = load("res://Scripts/Generators/BSP_CA_Hybrid.gd")

var rng = RandomNumberGenerator.new()

const W = 64
const H = 64

onready var FLOOR = $Floor
onready var WALLS = $Walls

onready var FloorTileTextureMap = {
	Constants.FloorTileCode.MID_FLOOR: [
		FLOOR.tile_set.find_tile_by_name("caves-rails-floor-0"),
		FLOOR.tile_set.find_tile_by_name("caves-rails-floor-1"),
		FLOOR.tile_set.find_tile_by_name("caves-rails-floor-2"),
		FLOOR.tile_set.find_tile_by_name("caves-rails-floor-3"),
		FLOOR.tile_set.find_tile_by_name("caves-rails-floor-4"),
		FLOOR.tile_set.find_tile_by_name("caves-rails-floor-5"),
		FLOOR.tile_set.find_tile_by_name("caves-rails-floor-6"),
		FLOOR.tile_set.find_tile_by_name("caves-rails-floor-7"),
	],

	Constants.FloorTileCode.EMPTY: [
		FLOOR.tile_set.find_tile_by_name("caves-rails-floor-empty"),
	],
}

onready var WallTileTextureMap = {
	Constants.WallTileCode.MID_WALL: [
		WALLS.tile_set.find_tile_by_name("caves-rails-wall-0"),
	],

	Constants.WallTileCode.EMPTY: [
		WALLS.tile_set.find_tile_by_name("caves-rails-wall-empty"),
	],

	Constants.WallTileCode.NODE_WALL: [
		WALLS.tile_set.find_tile_by_name("caves-rails-tileset-node-wall"),
	]
}


func _draw_dungeon(map):
	var level_floor = map["floor"]
	var level_walls = map["walls"]

	var w = len(level_floor[0])
	var h = len(level_floor)

	for x in range(w):
		for y in range(h):
			FLOOR.set_cell(x, y, FloorTileTextureMap[level_floor[y][x]][0])
			WALLS.set_cell(x, y, WallTileTextureMap[level_walls[y][x]][0])


func _clean(w, h):
	for i in range(-2*w, 2*w+1):
		for j in range(-2*h, 2*h+1):
			FLOOR.set_cell(i, j, FloorTileTextureMap[Constants.FloorTileCode.EMPTY][0])
			WALLS.set_cell(i, j, WallTileTextureMap[Constants.WallTileCode.EMPTY][0])


func _process(_delta):	
	if Input.is_action_just_pressed("recreate_map"):
		_clean(W, H)

		var cur_seed = null

		if cur_seed == null:
			rng.randomize()
		else:
			rng.set_seed(cur_seed)

		print_debug(rng.get_seed())

		var bsp = BSP_CA_Generator.new(rng)
		bsp.run(W, H)

		var map = bsp.get_map()
		_draw_dungeon(map)


func _ready():
	_clean(W, H)
