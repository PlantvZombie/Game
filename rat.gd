extends CharacterBody2D

@onready var anim = get_node("CollisionShape2D/Rat")
var ChaseMode:bool = false
var AnimOver:bool = true
signal StartMovement
var right:bool = false
var left:bool = false
var tween
var FirstRun:bool = true
var health:int = 10
var MoveDist:int = 100


func _physics_process(_delta):
	if ChaseMode:
		tween.stop()
		position.x = move_toward(position.x, get_node("/root/Global").PlayerPos.x, 3)
		if (position.x - get_node("/root/Global").PlayerPos.x) < 0:
			anim.play("WalkRight")
			get_node("Sight").set_rotation(0)
			get_node("CloseDetection").set_rotation(0)
		elif (position.x - get_node("/root/Global").PlayerPos.x) > 0:
			anim.play("WalkLeft")
			get_node("Sight").set_rotation(PI)
			get_node("CloseDetection").set_rotation(PI)
	if AnimOver and !ChaseMode:
		anim.play("WalkRight")
		right = true
		left = false
		AnimOver = false
		StartMovement.emit()
	if health < 1:
		self.queue_free()
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.name == "Character":
		ChaseMode = true


func _on_start_movement():
	if FirstRun:
		await get_tree().create_timer(1).timeout
		FirstRun = false
	tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x + MoveDist, position.y), (MoveDist/100))
	await get_tree().create_timer(1).timeout
	tween.stop()
	anim.play("WalkLeft")
	left = true
	right = false
	get_node("Sight").rotate(PI)
	get_node("CloseDetection").rotate(PI)
	tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x - MoveDist, position.y), (MoveDist/100))
	await get_tree().create_timer(1).timeout
	tween.stop()
	AnimOver = true
	get_node("Sight").rotate(PI)
	get_node("CloseDetection").rotate(PI)

