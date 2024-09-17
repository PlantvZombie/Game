extends Area2D





func _on_body_entered(body):
	if body.name == "Character":
		get_tree().change_scene_to_file("res://Level1.tscn")
	if body.name.left(3) == "Rat":
		body.queue_free()
