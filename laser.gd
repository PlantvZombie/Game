extends Area2D

var speed = 10
var target
var slope
var negativeX
var negativeY
var direction = abs(rotation - 180.1)/(rotation - 180.1)

func _on_body_entered(body):
	if body.name == "Character":
		get_tree().change_scene_to_file("res://Level1.tscn")

func _ready():
	target = target.position
	slope = (self.global_position.y - target.y)/(self.global_position.x - target.x)
	negativeX = direction*(self.global_position.x - target.x)/abs(self.global_position.x - target.x)
	negativeY = direction*(self.global_position.y - target.y)/abs(self.global_position.y - target.y)
	look_at(target)

func _physics_process(delta):
	
	
	position.x = -negativeX*(sqrt(pow(speed, 2))/(pow(slope, 2)+1)) + position.x
	position.y = -negativeY*sqrt(pow(speed, 2))*(pow(slope,2))/(pow(slope, 2)+1) + position.y
	
