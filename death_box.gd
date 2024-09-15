extends Area2D





func _on_body_entered(body):
	if body.name == "Character":
		get_tree().change_scene_to_file("res://Level1.tscn")
	if body.is_in_group("Enemies"):
		body.queue_free()
