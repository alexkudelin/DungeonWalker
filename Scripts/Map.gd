extends Node2D

var BSPNode = load("res://Scripts/BSP/BSPNode.gd")
var Room = load("res://Scripts/BSP/Room.gd")
var Hall = load("res://Scripts/BSP/Hall.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")
var CellularAutomaton = load("res://Scripts/CA/CellularAutomaton.gd")

var BSP_Generator = load("res://Scripts/Generators/BSP.gd")
var CA_Generator = load("res://Scripts/Generators/CA.gd")
var BSP_CA_Generator = load("res://Scripts/Generators/BSP_CA_Hybrid.gd")

var rng = RandomNumberGenerator.new()

const W = 64
const H = 64

onready var FLOOR = $Floor
onready var WALLS = $Walls
onready var STUFF = $Stuff
onready var PLAYER = $Player

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
		WALLS.tile_set.find_tile_by_name("node-wall"),
	]
}

onready var StuffTileTextureMap = {
	Constants.StuffTileCode.CHEST: [
		STUFF.tile_set.find_tile_by_name("chest-empty"),
	],

	Constants.StuffTileCode.BIG_FLASK: [
		STUFF.tile_set.find_tile_by_name("flask-big-blue"),
		STUFF.tile_set.find_tile_by_name("flask-big-green"),
		STUFF.tile_set.find_tile_by_name("flask-big-red"),
		STUFF.tile_set.find_tile_by_name("flask-big-yellow"),
	],

	Constants.StuffTileCode.SMALL_FLASK: [
		STUFF.tile_set.find_tile_by_name("flask-blue"),
		STUFF.tile_set.find_tile_by_name("flask-green"),
		STUFF.tile_set.find_tile_by_name("flask-red"),
		STUFF.tile_set.find_tile_by_name("flask-yellow"),
	],

	Constants.StuffTileCode.EMPTY: [
		STUFF.tile_set.find_tile_by_name("stuff-empty"),
	],

	Constants.StuffTileCode.LEVEL_ENTER: [
		STUFF.tile_set.find_tile_by_name("level-enter"),
	],

	Constants.StuffTileCode.LEVEL_EXIT: [
		STUFF.tile_set.find_tile_by_name("level-exit"),
	]
}


func _draw_dungeon(map):
	var level_floor = map["floor"]
	var level_walls = map["walls"]
	var level_stuff = map["stuff"]

	var w = len(level_floor[0])
	var h = len(level_floor)

	for x in range(w):
		for y in range(h):
			FLOOR.set_cell(x, y, FloorTileTextureMap[level_floor[y][x]][0])
			WALLS.set_cell(x, y, WallTileTextureMap[level_walls[y][x]][0])
			STUFF.set_cell(x, y, StuffTileTextureMap[level_stuff[y][x]][0])


func _clean(w, h):
	for i in range(-2*w, 2*w+1):
		for j in range(-2*h, 2*h+1):
			FLOOR.set_cell(i, j, FloorTileTextureMap[Constants.FloorTileCode.EMPTY][0])
			WALLS.set_cell(i, j, WallTileTextureMap[Constants.WallTileCode.EMPTY][0])

func _create_map():
	_clean(W, H)

	var cur_seed = null # 1818724167630780775

	if cur_seed == null:
		rng.randomize()
	else:
		rng.set_seed(cur_seed)

	print_debug(rng.get_seed())

	var gen = null

	if Global.selected_algorithm == 0:
		gen = BSP_Generator.new(rng)
	elif Global.selected_algorithm == 1:
		gen = CA_Generator.new(rng)
	elif Global.selected_algorithm == 2:
		gen = BSP_CA_Generator.new(rng)

	var map = gen.run(W, H)

	_draw_dungeon(map)

	PLAYER.position = FLOOR.map_to_world(Vector2(map.start[0], map.start[1]))

#func _process(_delta):	
#	if Input.is_action_just_pressed("recreate_map"):
#		_recreate_map()

func _ready():
	_create_map()
