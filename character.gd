extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
var left:bool = false
var right:bool = false
var Attack:bool = false
signal AttackTimer
var AttackComplete:bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = get_node("CollisionShape2D/Sprite2D")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("space") and is_on_floor() or Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	move_and_slide()

func _process(_delta):
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 80)
		if Input.is_action_pressed("left"):
			if Input.is_action_just_pressed("click") and !Attack:
				AttackComplete = false
				Attack = true
				anim.play("AttackLeft")
				AttackTimer.emit()
			if !Attack:
				anim.play("Run Left")
			left = true
			right = false
			if AttackComplete:
				Attack = false
		else:
			if Input.is_action_just_pressed("click") and !Attack:
				AttackComplete = false
				Attack = true
				anim.play("AttackRight")
				AttackTimer.emit()
			if Input.is_action_pressed("right") and !Attack:
				anim.play("Run Right")
			right = true
			left = false
			if AttackComplete:
				Attack = false
	else:
		velocity.x = move_toward(velocity.x, 0, 65)
		if velocity.x == 0 and !left and !right:
			anim.play("Idle")
		elif velocity.x == 0 and left and !Attack:
			anim.play("IdleLeft")
		elif velocity.x == 0 and right and !Attack:
			anim.play("IdleRight")
	
	get_node("/root/Global").PlayerPos = self.position


func _on_attack_timer():
	await get_tree().create_timer(0.9).timeout
	AttackComplete = true
