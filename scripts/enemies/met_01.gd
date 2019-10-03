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

const RESET_MAX = 120

var state = 0
var shoot = false
var shot_delay = 120
var reset = 0

func _ready():
	start_pos = Vector2(global_position.x, global_position.y)
	
	$anim.play("idle1")

func _physics_process(delta):
	print(reset)
	
	#Calculate the X distance between the player and Met.
	dist = floor(abs(player.global_position.x) - abs(global_position.x))
	
	#Let the reset timer expire and charge direction to face the player.
	if state == 0 and reset > 0:
		reset -= 1
	
	if reset == 60:
		if dist < 0:
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
			
	#If the player is within range, trigger animation.
	if dist >= -64 and dist <= 64 and state == 0 and reset == 0:
		state = 1
		$anim.play("open")
		
	#If the met has shot, start timer.
	if shoot and shot_delay > 0:
		shot_delay -= 1
	
	#When timer expires, start animation.
	if shoot and shot_delay == 0:
		state = 2
		shoot = false
		shot_delay = RESET_MAX
		$anim.play("close")

func _on_anim_finished(anim_name):
	#Shoot when open.
	if anim_name == "open":
		$anim.play("idle2")
		print('SHOT')
		shoot = true
	
	#Reset the Met
	if anim_name == "close":
		state = 0
		reset = RESET_MAX
