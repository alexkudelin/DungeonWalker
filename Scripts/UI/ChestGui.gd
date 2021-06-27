extends Area2D

onready var marker = get_node("../Label")
onready var animated_sprite = get_node("../AnimatedSprite")

var action_state = 0
var is_opened = false

func _process(_delta):
	if Input.is_action_just_pressed("player_open_chest"):
		if action_state == 0:
			animated_sprite.play("closed")
		elif action_state == 1:
			animated_sprite.play("open")
			is_opened = true


func OnChestAreaEntered(_body):
	marker.visible = true
	action_state = 1


func OnChestAreaExited(_body):
	marker.visible = false
	action_state = 0

	if is_opened:
		animated_sprite.play("close")
		is_opened = false
