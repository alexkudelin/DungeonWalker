extends KinematicBody2D

const ACCELERATION = 400
const MAX_SPEED = 125
const FRICTION = 400

onready var _animated_sprite = $AnimatedSprite
var velocity = Vector2.ZERO

func _physics_process(delta):
	var input = Vector2.ZERO

	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input.x > 0:
		_animated_sprite.flip_h = false
	elif input.x < 0:
		_animated_sprite.flip_h = true

	input = input.normalized()

	if input != Vector2.ZERO:
		velocity = velocity.move_toward(input * MAX_SPEED, ACCELERATION * delta)
		_animated_sprite.play("run")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		_animated_sprite.play("idle")

	velocity = move_and_slide(velocity)
