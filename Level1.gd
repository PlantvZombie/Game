extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_area_2d_body_entered(body):
	if body.name == "Character":
		get_tree().change_scene_to_file("res://Level1.tscn")
	if body.is_in_group("Enemies"):
		body.queue_free()
