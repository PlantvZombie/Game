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
		
#	if grappleTargets.size() > 0 and not is_on_floor() and (Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space")):
#
#		if not grappleTarget == null:
#			grappleTarget.spriteOn(false)
#
#		var closestTarget = grappleTargets[0]
#		closestTarget.spriteOn(true)
#		for j in grappleTargets.size() -1:
#				if distance(grappleTargets[j+1].position.x,grappleTargets[j+1].position.y,self.position.x, self.position.y) < distance(closestTarget.position.x,closestTarget.position.y,self.position.x, self.position.y) :
#					closestTarget.spriteOn(false)
#					closestTarget = grappleTargets[j+1]
#					closestTarget.spriteOn(true)
#		grappleTarget = closestTarget
		

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
	
func distance(x0, y0, x1, y1):
	return sqrt((x0 - x1)**2+(y0-y1)**2)

func _process(delta):
	grappleTargets[0].spriteOn(false)
	if grappleTargets.size() > 3:
		if not grappleTarget == null:
			grappleTarget.spriteOn(false)
			
		var closestTarget = grappleTargets[0]
		closestTarget.spriteOn(true)
		for j in grappleTargets.size() -1:
				if distance(grappleTargets[j+1].position.x,grappleTargets[j+1].position.y,self.position.x, self.position.y) < distance(closestTarget.position.x,closestTarget.position.y,self.position.x, self.position.y) :
					closestTarget.spriteOn(false)
					closestTarget = grappleTargets[j+1]
					closestTarget.spriteOn(true)
		grappleTarget = closestTarget

