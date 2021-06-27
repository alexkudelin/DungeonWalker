extends Node2D

var BSPNode = load("res://Scripts/BSP/BSPNode.gd")
var Room = load("res://Scripts/BSP/Room.gd")
var Hall = load("res://Scripts/BSP/Hall.gd")
var Constants = load("res://Scripts/Utils/Constants.gd")
var CellularAutomaton = load("res://Scripts/CA/CellularAutomaton.gd")

var BSP_Generator = load("res://Scripts/Generators/BSP.gd")
var CA_Generator = load("res://Scripts/Generators/CA.gd")
var BSP_CA_Generator = load("res://Scripts/Generators/BSP_CA_Hybrid.gd")

var TextureMaps = preload("res://Scripts/TextureMaps.gd").new()
onready var gui = get_node("./GUI")

var rng = RandomNumberGenerator.new()

const W = 64
const H = 64

onready var FLOOR = $Floor
onready var WALLS = $Walls
onready var STUFF = $Stuff
onready var PLAYER = $Player

const Chest = preload("res://Scenes/Chest.tscn")
const ChestArea = preload("res://Scenes/ChestArea.tscn")


func _add_chest(x, y):
	var chest = Chest.instance()
	var chest_area = ChestArea.instance()

	chest.set_position(STUFF.map_to_world(Vector2(x, y)))
	# chest_area.set_position(STUFF.map_to_world(Vector2(x, y)))

	chest.add_child(chest_area)
	# self.add_child(chest_area)
	self.add_child(chest)


func _draw_dungeon(map):
	var level_floor = map["floor"]
	var level_walls = map["walls"]
	var level_stuff = map["stuff"]

	var w = len(level_floor[0])
	var h = len(level_floor)

	for x in range(w):
		for y in range(h):
			var floor_texture = TextureMaps.FloorTextures[level_floor[y][x]]
			var idx = 0

			if floor_texture.size() > 1:
				idx = rng.randi() % floor_texture.size()

			FLOOR.set_cell(x, y, floor_texture[idx])
			WALLS.set_cell(x, y, TextureMaps.WallTextures[level_walls[y][x]][0])

			if level_stuff[y][x] == Constants.StuffTileCode.CHEST:
				_add_chest(x, y)
			else:
				var stuff_texture = TextureMaps.StuffTextures[level_stuff[y][x]]
				idx = 0

				if stuff_texture.size () > 1:
					idx = rng.randi() % stuff_texture.size()

				STUFF.set_cell(x, y, stuff_texture[idx])


func _clean(w, h):
	for i in range(-2*w, 2*w+1):
		for j in range(-2*h, 2*h+1):
			FLOOR.set_cell(i, j, TextureMaps.FloorTextures[Constants.FloorTileCode.EMPTY][0])
			WALLS.set_cell(i, j, TextureMaps.WallTextures[Constants.WallTileCode.EMPTY][0])
			STUFF.set_cell(i, j, TextureMaps.StuffTextures[Constants.StuffTileCode.EMPTY][0])


func _create_map():
	_clean(W, H)

	var cur_seed = Global._seed

	if cur_seed == null:
		rng.randomize()
		Global._seed = rng.seed
	else:
		rng.set_seed(cur_seed.hash())

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

	for area in get_tree().get_nodes_in_group("LootAreas"):
		area.connect("body_entered", gui, "OnChestAreaEntered")
		area.connect("body_exited", gui, "OnChestAreaExited")


func _process(_delta):
	if Input.is_action_just_pressed("recreate_map"):
		Global._seed = null
		_create_map()


func _ready():
	_create_map()
