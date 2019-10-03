extends KinematicBody2D

#Most of these variables will be shared amongst all enemies.

#Get the player node.
onready var player = get_parent().get_parent().get_child(2)

#Starting X and Y coordinates. To allow the enemy to respawn when off screen.
var start_pos = Vector2()

#The distance between the player and enemy.
var dist

#Enemy HP.
var hp = 10

#Other
var dead = false

var timer = 120

func _ready():
	start_pos = Vector2(global_position.x, global_position.y)
	
	$anim.play("idle1")

func _physics_process(delta):
	
	#Calculate the X distance between the player and Met.
	dist = abs(player.global_position.x) - abs(global_position.x)
	
	print(dist)