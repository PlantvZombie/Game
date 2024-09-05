extends Node2D



func _on_area_2d_body_entered(body):
	if body.name == "Character" and body.grapplingHook == true:
		body.grappleTargets.append(self)


func _on_area_2d_body_exited(body):
	if body.name == "Character":
		body.grappleTargets.erase(self)

func spriteOn(bol):
	$Sprite2D.visible = bol
