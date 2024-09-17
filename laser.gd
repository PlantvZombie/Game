extends Area2D

var speed = 10
var target
var slope
var negativeX
var negativeY
var direction

func _on_body_entered(body):
	if body.name == "Character":

		body.health -= 10


func _ready():
	slope = (self.global_position.y - target.y)/(self.global_position.x - target.x)
	negativeX = direction*(self.global_position.x - target.x)/abs(self.global_position.x - target.x)
	negativeY = direction*(self.global_position.y - target.y)/abs(self.global_position.y - target.y)
	look_at(target)

func _physics_process(_delta):
	
	
	position.x = -negativeX*(sqrt(pow(speed, 2))/(pow(slope, 2)+1)) + position.x
	position.y = -negativeY*sqrt(pow(speed, 2))*(pow(slope,2))/(pow(slope, 2)+1) + position.y
	
