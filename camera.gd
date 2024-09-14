extends StaticBody2D

var laser = preload("res://laser.tscn")
var startpos:Vector2
var endpos:Vector2
var speed = 2
var direction = 1


func _on_area_2d_body_entered(body):
	if body.name == "Character":
		await get_tree().create_timer(0.2).timeout
		var Laser = laser.instantiate()
		call_deferred("add_child", Laser)
		Laser.target = body
		remove_child(Laser)

func _process(delta):
	$Area2D.rotate(.001*speed*direction)
	if $Area2D.rotation_degrees >= 20 or $Area2D.rotation_degrees <= -20:
		direction = -1 * direction
