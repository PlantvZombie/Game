extends CharacterBody2D

const SPEED = 400.0

const JUMP_VELOCITY = -400.0
var grapplingHook = true
var currentTarget

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
	


func _process(delta):
	if currentTarget != null:
		currentTarget.turnOn(false)
	currentTarget = find_closest_or_furthest(self,"targets")
	if currentTarget != null:
		currentTarget.turnOn(true)
	

func find_closest_or_furthest(node: Object, group_name: String, get_closest:= true) -> Object:
	var target_group = get_tree().get_nodes_in_group(group_name)
	if str(target_group) != "[]":
		var distance_away = node.global_transform.origin.distance_to(target_group[0].global_transform.origin)
		var return_node = target_group[0]
		for index in target_group.size():
			var distance = node.global_transform.origin.distance_to(target_group[index].global_transform.origin)
			if (get_closest && distance < distance_away) or (!get_closest && distance > distance_away):
				distance_away = distance
				return_node = target_group[index];
		return return_node
	else:
		
		return null

func distance(pos1):
	return sqrt((pos1.position.x - self.position.x)**2+(pos1.postion.y - self.position.y)**2)
