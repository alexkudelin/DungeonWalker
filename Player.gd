extends KinematicBody2D

const ACCELERATION = 8
const MAX_SPEED = 175
const FRICTION = 12

var velocity = Vector2.ZERO

func _physics_process(delta):
	var input = Vector2.ZERO

	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	input = input.normalized()

	if input != Vector2.ZERO:
		velocity += input * ACCELERATION * delta
		velocity = velocity.clamped(MAX_SPEED * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_collide(velocity)
