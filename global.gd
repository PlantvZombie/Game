extends Node

var PlayerPos:Vector2
var HitLeft:bool = false
var HitRight:bool = false

func _ready():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
