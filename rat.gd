extends AnimatableBody2D

@onready var anim = get_node("CollisionShape2D/Rat")
var ChaseMode:bool = false
var AnimOver:bool = true
signal StartMovement


func _physics_process(_delta):
	if ChaseMode:
		position.x = move_toward(position.x, get_node("/root/Global").PlayerPos.x, 1)
		if (position.x - get_node("/root/Global").PlayerPos.x) < 0:
			anim.play("WalkRight")
		elif (position.x - get_node("/root/Global").PlayerPos.x) > 0:
			anim.play("WalkLeft")
	if AnimOver and !ChaseMode:
		anim.play("WalkRight")
		AnimOver = false
		StartMovement.emit()


func _on_area_2d_body_entered(body):
	if body.name == "Character":
		ChaseMode = true


func _on_start_movement():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x + 100, position.y), 1)
	await get_tree().create_timer(1).timeout
	tween.stop()
	anim.play("WalkLeft")
	get_node("Area2D").rotate(PI)
	get_node("Area2D/POV").position.x += 1
	tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x - 100, position.y), 1)
	await get_tree().create_timer(1).timeout
	tween.stop()
	AnimOver = true
	get_node("Area2D").rotate(PI)
	get_node("Area2D/POV").position.x -= 1
