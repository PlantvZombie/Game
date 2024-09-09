extends StaticBody2D

var laser = preload("res://laser.tscn")
var startpos:Vector2
var endpos:Vector2
var Laser
var Entered:bool = false


func _physics_process(_delta):
	if Entered:
		print("run")
		Laser.global_position.move_toward(get_node("/root/Global").PlayerPos, 1)



func _on_area_2d_body_entered(body):
	if body.name == "Character":
		await get_tree().create_timer(0.2).timeout
		Laser = laser.instantiate()
		call_deferred("add_child", Laser)
		Laser.global_position = get_node("CollisionShape2D").position
		Laser.look_at(body.global_position)
		Entered = true
		Laser.look_at(body.global_position)
		await get_tree().create_timer(4).timeout
		remove_child(Laser)
		Entered = false
