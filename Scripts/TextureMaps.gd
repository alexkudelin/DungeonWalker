extends Node2D

class_name TextureMaps

const Constants = preload("res://Scripts/Utils/Constants.gd")

const floor_tilset = preload("res://Resources/16px_cave_floor.tres")
const walls_tilset = preload("res://Resources/16px_cave_walls.tres")
const stuff_tilset = preload("res://Resources/16px_cave_stuff.tres")

var FloorTextures = {
	Constants.FloorTileCode.MID_FLOOR: [
		floor_tilset.find_tile_by_name("caves-rails-floor-0"),
		floor_tilset.find_tile_by_name("caves-rails-floor-1"),
		floor_tilset.find_tile_by_name("caves-rails-floor-2"),
		floor_tilset.find_tile_by_name("caves-rails-floor-3"),
		floor_tilset.find_tile_by_name("caves-rails-floor-4"),
		floor_tilset.find_tile_by_name("caves-rails-floor-5"),
		floor_tilset.find_tile_by_name("caves-rails-floor-6"),
		floor_tilset.find_tile_by_name("caves-rails-floor-7")
	],

	Constants.FloorTileCode.EMPTY: [
		floor_tilset.find_tile_by_name("caves-rails-floor-empty")
	],
}

var WallTextures = {
	Constants.WallTileCode.MID_WALL: [
		walls_tilset.find_tile_by_name("caves-rails-wall-0")
	],

	Constants.WallTileCode.EMPTY: [
		walls_tilset.find_tile_by_name("caves-rails-wall-empty")
	],

	Constants.WallTileCode.NODE_WALL: [
		walls_tilset.find_tile_by_name("node-wall")
	]
}

var StuffTextures = {
	Constants.StuffTileCode.CHEST: [
		stuff_tilset.find_tile_by_name("chest-empty")
	],

	Constants.StuffTileCode.BIG_FLASK: [
		stuff_tilset.find_tile_by_name("flask-big-blue"),
		stuff_tilset.find_tile_by_name("flask-big-green"),
		stuff_tilset.find_tile_by_name("flask-big-red"),
		stuff_tilset.find_tile_by_name("flask-big-yellow")
	],

	Constants.StuffTileCode.SMALL_FLASK: [
		stuff_tilset.find_tile_by_name("flask-blue"),
		stuff_tilset.find_tile_by_name("flask-green"),
		stuff_tilset.find_tile_by_name("flask-red"),
		stuff_tilset.find_tile_by_name("flask-yellow")
	],

	Constants.StuffTileCode.EMPTY: [
		stuff_tilset.find_tile_by_name("stuff-empty")
	],

	Constants.StuffTileCode.LEVEL_ENTER: [
		stuff_tilset.find_tile_by_name("level-enter")
	],

	Constants.StuffTileCode.LEVEL_EXIT: [
		stuff_tilset.find_tile_by_name("level-exit")
	]
}
