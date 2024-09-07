extends Node2D

func _ready():
	add_to_group("targets")

func turnOn(ans):
	$Sprite2D.visible = ans
