extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -300.0
var grapplingHook = true
var grappleTargets = []

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if  is_on_floor() and (Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space")):
		velocity.y = JUMP_VELOCITY
	if grappleTargets.size() > 0 and not is_on_floor() and (Input.is_action_just_pressed("up") or Input.is_action_just_pressed("space")):
		
		var grappleDistance = -1
		for j in grappleTargets.size():
			if sqrt((grappleTargets[j].x)^2) > grappleDistance:
				pass
		print(grappleTargets[0].position)

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 80)
	else:
		velocity.x = move_toward(velocity.x, 0, 65)
	
	move_and_slide()
	
func distance(x0, y0, x1, y1):
	return sqrt((x0 - x1)**2+(y0-y1)**2)


