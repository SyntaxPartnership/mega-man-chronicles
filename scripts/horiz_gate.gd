extends Node2D

onready var player = get_parent().get_child(2)
var higher = false

func _physics_process(delta):
	if higher == false and player.position.y > self.position.y:
		higher == true
		print(higher)