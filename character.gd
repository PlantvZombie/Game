extends CharacterBody2D

const SPEED = 400.0

const JUMP_VELOCITY = -400.0

@export var hasGrapplingHook:bool = false
var grappleRange:float = 100000
var currentTarget 

var result


var left:bool = false
var right:bool = false
var Attack:bool = false
var frame:int 
signal Turned
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

	get_node("ProgressBar").value = health


	if currentTarget != null:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(self.global_position, currentTarget.global_position)
		result = space_state.intersect_ray(query)
		if Input.is_action_just_pressed("rClick") and hasGrapplingHook and distance(self.global_position, currentTarget.global_position) < grappleRange and str(result.collider).left(str(result.collider).find(":")) != "TileMap" and str(result.collider).left(str(result.collider).find(":")) != "deathBox":
			tween = create_tween()
			currentTarget.rope(self.global_position)
			tween.tween_property(self, "position", currentTarget.global_position, .1)
			hideRope.emit()

		
	if health < 1 and !Dead:
		if right:
			get_node("Death").play()
			anim.play("DeathRight")
			Death.emit()
			Dead = true
		elif left:
			get_node("Death").play()
			anim.play("DeathLeft")
			Death.emit()
			Dead = true
		else:
			Death.emit()
			Dead = true

	if anim.get_animation() == "AttackRight" and anim.get_frame() == 1:
		get_node("Attack").play()
	elif anim.get_animation() == "AttackLeft" and anim.get_frame() == 1:
		get_node("Attack").play()

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
	if anim.get_animation() == "AttackRight" and !right:
		frame = anim.get_frame()
		anim.play("AttackLeft")
		anim.set_frame(frame)
	if anim.get_animation() == "AttackLeft" and !left:
		frame = anim.get_frame()
		anim.play("AttackRight")
		anim.set_frame(frame)
	currentTarget = find_closest_or_furthest(self, "targets")
	if currentTarget != null and distance(self.global_position, currentTarget.global_position) < grappleRange and hasGrapplingHook:
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
	
func distance(pos0, pos1):
	return sqrt((pos0.x - pos1.x)**2+(pos0.y-pos1.x)**2)

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
		get_node("Hurt").play()


func _on_death():
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://Level1.tscn")



func _on_hide_rope():
	await tween.finished
	currentTarget.rope(null)
	print("wa")
	position.y = position.y - 10
