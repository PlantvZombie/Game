extends CharacterBody2D

@onready var anim = get_node("CollisionShape2D/Rat")
var ChaseMode:bool = false
var AnimOver:bool = true
signal StartMovement
var right:bool = false
var left:bool = false
var tween
var FirstRun:bool = true


func _physics_process(_delta):
	if ChaseMode:
		tween.stop()
		position.x = move_toward(position.x, get_node("/root/Global").PlayerPos.x, 2)
		if (position.x - get_node("/root/Global").PlayerPos.x) < 0:
			anim.play("WalkRight")
		elif (position.x - get_node("/root/Global").PlayerPos.x) > 0:
			anim.play("WalkLeft")
	if AnimOver and !ChaseMode:
		anim.play("WalkRight")
		right = true
		left = false
		AnimOver = false
		StartMovement.emit()
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.name == "Character":
		ChaseMode = true


func _on_start_movement():
	if FirstRun:
		await get_tree().create_timer(1).timeout
		FirstRun = false
	tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x + 100, position.y), 1)
	await get_tree().create_timer(1).timeout
	tween.stop()
	anim.play("WalkLeft")
	left = true
	right = false
	get_node("Sight").rotate(PI)
	get_node("Sight/POV").position.x += 1
	tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x - 100, position.y), 1)
	await get_tree().create_timer(1).timeout
	tween.stop()
	AnimOver = true
	get_node("Sight").rotate(PI)
	get_node("Sight/POV").position.x -= 1
	get_node("CloseDetection").rotate(PI)
	get_node("CloseDetection/CollisionPolygon2D").position.x -= 1

