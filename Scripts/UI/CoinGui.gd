extends Area2D


func OnCoinAreaEntered(body):
	print(body.get_name())
	print("coin in")


func OnCoinAreaExited(_body):
	print("coin out")
