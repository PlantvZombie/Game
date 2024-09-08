extends CharacterBody2D

@onready var anim = get_node("CollisionShape2D/Rat")
var ChaseMode:bool = false
var AnimOver:bool = true
signal StartMovement
var right:bool = false
var left:bool = false
var tween
var TweenIsBlank:bool = true
var FirstRun:bool = true
var health:int = 20
var MoveDist:int = 100
var Dead:bool = false
signal Death

func _physics_process(_delta):
	if ChaseMode and !Dead:
		if !TweenIsBlank:
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
	if health < 1 and !Dead:
		if (position.x - get_node("/root/Global").PlayerPos.x) < 0:
			anim.play("DeathRight")
			Death.emit()
			Dead = true
		elif (position.x - get_node("/root/Global").PlayerPos.x) > 0:
			anim.play("DeathLeft")
			Death.emit()
			Dead = true
	if AnimOver and !ChaseMode and !Dead:
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
	if Dead: return
	TweenIsBlank = false
	tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x + MoveDist, position.y), 1.2)
	await get_tree().create_timer(1.2).timeout
	tween.stop()
	if Dead or ChaseMode: return
	anim.play("WalkLeft")
	left = true
	right = false
	get_node("Sight").rotate(PI)
	get_node("CloseDetection").rotate(PI)
	if Dead: return
	tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x - MoveDist, position.y), 1.2)
	await get_tree().create_timer(1.2).timeout
	tween.stop()
	AnimOver = true
	get_node("Sight").rotate(PI)
	get_node("CloseDetection").rotate(PI)

func _on_death():
	await get_tree().create_timer(1.2).timeout
	self.queue_free()


func _on_character_attacked():
	get_node("AnimationPlayer").play("flash")
	if !Dead:
		Engine.time_scale = 0.07
		await get_tree().create_timer(0.07 * 0.3).timeout
		Engine.time_scale = 1
