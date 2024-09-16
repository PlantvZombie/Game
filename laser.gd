extends Area2D

var speed = 10
var target
var slope
var negativeX
var negativeY

func _on_body_entered(body):
	if body.name == "Character":
		body.health -= 10

func _ready():
	target = target.position
	slope = (self.global_position.y - target.y)/(self.global_position.x - target.x)
	negativeX = abs(self.global_position.x - target.x)/(self.global_position.x - target.x)
	negativeY = abs(self.global_position.y - target.y)/(self.global_position.y - target.y)
	look_at(target)

func _physics_process(delta):
	
	
	position.x = (-negativeX*sqrt(pow(speed, 2))/(pow(slope, 2)+1)) + position.x
	position.y = (-negativeY*sqrt(pow(speed, 2)*pow(slope,2))/(pow(slope, 2)+1)) + position.y
	
	var x = abs(self.global_position.y - target.y)/(self.global_position.y - target.y)
