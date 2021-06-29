extends KinematicBody2D

var ACCELERATION = 400
var MAX_SPEED = 125
var FRICTION = 400

onready var _animated_sprite = null

const KnightMaleAnimatedSprite = preload("res://Scenes/Heroes/KnightMaleAnimatedSprite.tscn")
const LizardMaleAnimatedSprite = preload("res://Scenes/Heroes/LizardMaleAnimatedSprite.tscn")
const WizardAnimatedSprite = preload("res://Scenes/Heroes/WizardAnimatedSprite.tscn")

var velocity = Vector2.ZERO

func _physics_process(delta):
	var input = Vector2.ZERO

	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	var accelerate = Input.get_action_strength("player_accelerate")

	if input.x > 0:
		_animated_sprite.flip_h = false
	elif input.x < 0:
		_animated_sprite.flip_h = true

	input = input.normalized()

	if input != Vector2.ZERO:
		velocity = velocity.move_toward(input * (MAX_SPEED + MAX_SPEED*0.8*accelerate), ACCELERATION  * delta)

		if accelerate:
			_animated_sprite.speed_scale = 2
		else:
			_animated_sprite.speed_scale = 1

		_animated_sprite.play("run")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		_animated_sprite.play("idle")

	velocity = move_and_slide(velocity)


func _ready():
	var hero_sprite = null

	if Global.hero == 0:
		ACCELERATION = 250
		MAX_SPEED = 125
		hero_sprite = KnightMaleAnimatedSprite.instance()
	elif Global.hero == 1:
		ACCELERATION = 175
		MAX_SPEED = 75
		hero_sprite = WizardAnimatedSprite.instance()
	elif Global.hero == 2:
		MAX_SPEED = 175
		hero_sprite = LizardMaleAnimatedSprite.instance()
		
	_animated_sprite = hero_sprite

	add_child(hero_sprite)
