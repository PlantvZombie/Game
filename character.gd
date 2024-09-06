extends CharacterBody2D

const SPEED = 400.0

const JUMP_VELOCITY = -400.0
var grapplingHook = true
var grappleTargets = []
var grappleTarget

var left:bool = false
var right:bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = get_node("CollisionShape2D/Sprite2D")

func _physics_process(delta):
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if  is_on_floor() and (Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space")):
		velocity.y = JUMP_VELOCITY
		

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 80)
		if Input.is_action_pressed("left"):
			anim.play("Run Left")
			left = true
			right = false
		else:
			anim.play("Run Right")
			right = true
			left = false
	else:
		velocity.x = move_toward(velocity.x, 0, 65)

		if velocity.x == 0 and !left and !right:
			anim.play("Idle")
		elif velocity.x == 0 and left:
			anim.play("IdleLeft")
		elif velocity.x == 0 and right:
			anim.play("IdleRight")
	
	get_node("/root/Global").PlayerPos = self.position

	move_and_slide()
	
func distance(pos1):
	return sqrt((pos1.x - self.position.x)**2+(pos1.y - self.position.y)**2)

func _process(delta):
	
	if grappleTargets.size() > 0:
		if not grappleTarget == null:
			grappleTarget.spriteOn(false)
		print([Vector2(1,0), Vector2(0,0)].map(distance)
		
