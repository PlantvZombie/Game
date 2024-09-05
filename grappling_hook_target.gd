extends Node2D



func _on_area_2d_body_entered(body):
	if body.name == "Character" and body.grapplingHook == true:
		$Sprite2D.show()
		body.grappleTargets.append(self)


func _on_area_2d_body_exited(body):
	if body.name == "Character":
		$Sprite2D.hide()
		body.grappleTargets.erase(self)
