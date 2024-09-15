extends Area2D


func _on_body_entered(body):
	if body.name == "Character":
		body.hasGrapplingHook = true
		visible = false
