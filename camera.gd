extends StaticBody2D

var laser = preload("res://laser.tscn")
var startpos:Vector2
var endpos:Vector2


func _on_area_2d_body_entered(body):
	if body.name == "Character":
		await get_tree().create_timer(0.2).timeout
		var Laser = laser.instantiate()
		call_deferred("add_child", Laser)
		Laser.global_position = get_node("CollisionShape2D").position
		Laser.look_at(body.position)
		var tween = create_tween()
		tween.tween_property(Laser, "position", Vector2(body.position.x, body.position.y), 2)
		await get_tree().create_timer(2).timeout
		remove_child(Laser)
