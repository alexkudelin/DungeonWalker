extends Camera2D

const MOVE_SPEED = 10000
const ZOOM_SPEED = 5

func _process(delta):
	var z = zoom.x / 12.5

	if Input.is_action_pressed("ui_left"):
		global_position += Vector2.LEFT * delta * MOVE_SPEED * z
	elif Input.is_action_pressed("ui_right"):
		global_position += Vector2.RIGHT * delta * MOVE_SPEED * z
	elif Input.is_action_pressed("ui_up"):
		global_position += Vector2.UP * delta * MOVE_SPEED * z
	elif Input.is_action_pressed("ui_down"):
		global_position += Vector2.DOWN * delta * MOVE_SPEED * z
	elif Input.is_action_pressed("zoom_in"):
		zoom -= Vector2.ONE * delta * ZOOM_SPEED
	elif Input.is_action_pressed("zoom_out"):
		zoom += Vector2.ONE * delta * ZOOM_SPEED
