class_name Constants

const WALL_SIZE = 1
const MIN_ROOM_FREE_SPACE = 10
const MIN_ROOM_SIZE = WALL_SIZE*2 + MIN_ROOM_FREE_SPACE
const HALL_THINNESS = 3

enum Direction {
	NONE,
	VERTICAL,
	HORIZONTAL,
	MIXED,
}

enum TileCodes {
	EMPTY = -1,
	ROOM_FLOOR = 0,
	HALL_FLOOR,

	NE_CORNER,
	SE_CORNER,
	SW_CORNER,
	NW_CORNER,

	NORTH_WALL,
	EAST_WALL,
	SOUTH_WALL,
	WEST_WALL,

	NODE_WALL = 100 # should be last :)
}

enum CA_Tiles {
	ALIVE,
	DEAD,
	OUTLINE,
}
