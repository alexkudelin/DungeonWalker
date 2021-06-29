extends Area2D

onready var marker = get_node("../Label")

var action_state = 0

func _process(_delta):
	if Input.is_action_just_pressed("player_interact"):
		if action_state == 0:
			pass
		elif action_state == 1:
			get_tree().change_scene("res://Scenes/UI/GameSetupMenu.tscn")


func OnExitAreaEntered(_body):
	marker.visible = true
	action_state = 1


func OnExitAreaExited(_body):
	marker.visible = false
	action_state = 0

