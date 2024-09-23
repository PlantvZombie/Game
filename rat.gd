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
var Attacking:bool = false
signal Death
signal RatAttack
var AttackPossible:bool = false
signal AttackTrue

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if ChaseMode and !Dead and !Attacking:
		if !TweenIsBlank:
			tween.stop()
		position.x = move_toward(position.x, get_node("/root/Global").PlayerPos.x, 1.5)
		if (position.x - get_node("/root/Global").PlayerPos.x) < 0:
			anim.play("WalkRight")
			right = true
			left = false
			get_node("Sight").set_rotation(0)
			get_node("CloseDetection").set_rotation(0)
		elif (position.x - get_node("/root/Global").PlayerPos.x) > 0:
			anim.play("WalkLeft")
			left = true
			right = false
			get_node("Sight").set_rotation(PI)
			get_node("CloseDetection").set_rotation(PI)
	if health < 1 and !Dead:
		if right:
			anim.play("DeathRight")
			Death.emit()
			Dead = true
		elif left:
			anim.play("DeathLeft")
			Death.emit()
			Dead = true
	if AnimOver and !ChaseMode and !Dead and !Attacking:
		anim.play("WalkRight")
		right = true
		left = false
		AnimOver = false
		StartMovement.emit()
	
	if AttackPossible:
		AttackTrue.emit()
		
	if anim.get_animation() == "AttackRight" and anim.get_frame() == 6:
		get_node("Right/CollisionShape2D").set_disabled(false)
	elif anim.get_animation() == "AttackLeft" and anim.get_frame() == 6:
		get_node("Left/CollisionShape2D").set_disabled(false)
	else:
		get_node("Right/CollisionShape2D").set_disabled(true)
		get_node("Left/CollisionShape2D").set_disabled(true)
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.name == "Character":
		ChaseMode = true

func _on_sight_body_exited(body):
	if body.name == "Character":
		ChaseMode = false

func _on_start_movement():
	if FirstRun:
		await get_tree().create_timer(1).timeout
		FirstRun = false
	if Dead or ChaseMode or Attacking: 
		AnimOver = true
		return
	TweenIsBlank = false
	tween = create_tween()
	tween.tween_property(self, "position:x", position.x + MoveDist, 1.2)
	await get_tree().create_timer(1.2).timeout
	tween.stop()
	if Dead or ChaseMode or Attacking: 
		AnimOver = true
		return
	anim.play("WalkLeft")
	left = true
	right = false
	get_node("Sight").set_rotation(PI)
	get_node("CloseDetection").set_rotation(PI)
	if Dead or ChaseMode or Attacking:
		AnimOver = true
		return
	tween = create_tween()
	tween.tween_property(self, "position:x", position.x - MoveDist, 1.2)
	await get_tree().create_timer(1.2).timeout
	tween.stop()
	AnimOver = true
	get_node("Sight").set_rotation(0)
	get_node("CloseDetection").set_rotation(0)

func _on_death():
	await get_tree().create_timer(1.2).timeout
	self.queue_free()


func _on_character_attacked():
	get_node("AnimationPlayer").play("flash")
	if !Dead:
		Engine.time_scale = 0.07
		await get_tree().create_timer(0.07 * 0.3).timeout
		Engine.time_scale = 1

func _on_right_body_entered(body):
	if body.name == "Character":
		body.health -= 40
		get_node("/root/Global").HitRight = true
		get_node("/root/Global").HitLeft = false
		RatAttack.emit()


func _on_left_body_entered(body):
	if body.name == "Character":
		body.health -= 40
		get_node("/root/Global").HitRight = false
		get_node("/root/Global").HitLeft = true
		RatAttack.emit()

func _on_close_detection_body_entered(body):
	if body.name == "Character":
		AttackPossible = true

func _on_attack_true():
	if !TweenIsBlank:
		tween.stop()
	if right and !Attacking:
		Attacking = true
		anim.play("AttackRight")
		await get_tree().create_timer(1.5).timeout
		Attacking = false
		get_node("/root/Global").HitRight = false
	if left and !Attacking:
		Attacking = true
		anim.play("AttackLeft")
		await get_tree().create_timer(1.5).timeout
		Attacking = false
		get_node("/root/Global").HitLeft = false

func _on_close_detection_body_exited(body):
	AttackPossible = false
