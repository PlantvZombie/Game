extends CharacterBody2D

const SPEED = 400.0

const JUMP_VELOCITY = -400.0

var hasGrapplingHook:bool = true
var currentTarget 


var left:bool = false
var right:bool = false
var Attack:bool = false
signal AttackTimer
signal Attacked
signal hideRope
var AttackComplete:bool = false
var AfterJump:bool = false

var tween 

var health:int = 100
var Dead:bool = false
signal Death



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = get_node("CollisionShape2D/Sprite2D")

func _physics_process(delta):

	
	if Input.is_action_just_pressed("rClick") and hasGrapplingHook and currentTarget != null:
		tween = create_tween()

	if health < 1 and !Dead:
		if right:
			anim.play("DeathRight")
			Death.emit()
			Dead = true
		elif left:
			anim.play("DeathLeft")
			Death.emit()
			Dead = true
		else:
			Death.emit()
			Dead = true

	
		currentTarget.rope(self.global_position)
		tween.tween_property(self, "position", currentTarget.global_position, .1)
		hideRope.emit(tween)
	
	if anim.get_animation() == "AttackRight" and anim.get_frame() == 2:
		get_node("Right/CollisionShape2D").set_disabled(false)
	elif anim.get_animation() == "AttackLeft" and anim.get_frame() == 2:
		get_node("Left/CollisionShape2D").set_disabled(false)
	else:
		get_node("Right/CollisionShape2D").set_disabled(true)
		get_node("Left/CollisionShape2D").set_disabled(true)
	# Add the gravity.
	if not is_on_floor():
		if velocity.y  > 0:
			AfterJump = true
		if !AfterJump:
			velocity.y += gravity * delta
		else:
			velocity.y += gravity * (1.5 *delta)
		
	if is_on_floor():
		AfterJump = false

	# Handle Jump.
	if  is_on_floor() and (Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space")) and !Dead:
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()

func _input(event):
	if (event.is_action_released("space") or event.is_action_released("up")) and !Dead:
		if velocity.y < 0:
			velocity.y *= 0.5
  
func _process(_delta):

	if currentTarget != null:
		currentTarget.turnOn(false)
	currentTarget = find_closest_or_furthest(self, "targets")
	if currentTarget != null:
		currentTarget.turnOn(true)
	
	var direction = Input.get_axis("left", "right")
	if direction and !Dead:
		velocity.x = move_toward(velocity.x, direction * SPEED, 80)
		if Input.is_action_pressed("left") and !Dead:
			if Input.is_action_just_pressed("click") and !Attack and !Dead:
				AttackComplete = false
				Attack = true
				anim.play("AttackLeft")
				AttackTimer.emit()
			if !Attack and !Dead:
				anim.play("Run Left")
			left = true
			right = false
			if AttackComplete:
				Attack = false
		else:
			if Input.is_action_just_pressed("click") and !Attack and !Dead:
				AttackComplete = false
				Attack = true
				anim.play("AttackRight")
				AttackTimer.emit()
			if Input.is_action_pressed("right") and !Attack and !Dead:
				anim.play("Run Right")
			right = true
			left = false
			if AttackComplete:
				Attack = false
	else:
		velocity.x = move_toward(velocity.x, 0, 65)
		if velocity.x == 0 and Input.is_action_just_pressed("click") and !Attack and left and !Dead:
				AttackComplete = false
				Attack = true
				anim.play("AttackLeft")
				AttackTimer.emit()
				
		if velocity.x == 0 and Input.is_action_just_pressed("click") and !Attack and right and !Dead:
				AttackComplete = false
				Attack = true
				anim.play("AttackRight")
				AttackTimer.emit()
		if velocity.x == 0 and !left and !right and !Dead:
			anim.play("Idle")
		elif velocity.x == 0 and left and !Attack and !Dead:
			anim.play("IdleLeft")
		elif velocity.x == 0 and right and !Attack and !Dead:
			anim.play("IdleRight")
		if AttackComplete:
				Attack = false
	get_node("/root/Global").PlayerPos = self.position


func _on_attack_timer():
	await get_tree().create_timer(0.9).timeout
	AttackComplete = true

	
func distance(x0, y0, x1, y1):
	return sqrt((x0 - x1)**2+(y0-y1)**2)

func find_closest_or_furthest(node: Object, group_name: String, get_closest:= true) -> Object:
	var target_group = get_tree().get_nodes_in_group(group_name)
	if target_group.size() != 0:
		var distance_away = node.global_transform.origin.distance_to(target_group[0].global_transform.origin)
		var return_node = target_group[0]
		for index in target_group.size():
			var Distance = node.global_transform.origin.distance_to(target_group[index].global_transform.origin)
			if (get_closest && Distance < distance_away) || (!get_closest && Distance > distance_away):
				distance_away = Distance
				return_node = target_group[index];
		return return_node
	else:
		return null


func _on_right_body_entered(body):
	if body.is_in_group("Enemies"):
		body.health -= 10
		Attacked.emit()

func _on_left_body_entered(body):
	if body.is_in_group("Enemies"):
		body.health -= 10
		Attacked.emit()



func _on_hide_rope():
	await tween.finished
	currentTarget.rope(null)

func _on_rat_rat_attack():
	get_node("AnimationPlayer").play("flash")
	if !Dead:
		Engine.time_scale = 0.07
		await get_tree().create_timer(0.07 * 0.5).timeout
		if get_node("/root/Global").HitRight:
			velocity.x = 10000
		elif get_node("/root/Global").HitLeft:
			velocity.x = -10000
		Engine.time_scale = 1


func _on_death():
	await get_tree().create_timer(1).timeout
	self.queue_free()

