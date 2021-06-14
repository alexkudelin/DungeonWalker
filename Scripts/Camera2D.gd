extends Camera2D

const MOVE_SPEED = 5000
const ZOOM_SPEED = 1.025

func _process(delta):
	var z = zoom.x / 12.5

	if Input.is_action_pressed("ui_left"):
		if Input.is_action_pressed("slow_move"):	
			delta *= 0.5

		global_position += Vector2.LEFT * delta * MOVE_SPEED * z
	elif Input.is_action_pressed("ui_right"):
		if Input.is_action_pressed("slow_move"):	
			delta *= 0.5

		global_position += Vector2.RIGHT * delta * MOVE_SPEED * z
	elif Input.is_action_pressed("ui_up"):
		if Input.is_action_pressed("slow_move"):	
			delta *= 0.5

		global_position += Vector2.UP * delta * MOVE_SPEED * z
	elif Input.is_action_pressed("ui_down"):
		if Input.is_action_pressed("slow_move"):	
			delta *= 0.5

		global_position += Vector2.DOWN * delta * MOVE_SPEED * z
	elif Input.is_action_pressed("zoom_in"):
		zoom -= Vector2.ONE * delta * ZOOM_SPEED
	elif Input.is_action_pressed("zoom_out"):
		zoom += Vector2.ONE * delta * ZOOM_SPEED
