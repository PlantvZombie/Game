extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("space") and is_on_floor() or Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 80)
	else:
		velocity.x = move_toward(velocity.x, 0, 65)

	move_and_slide()
