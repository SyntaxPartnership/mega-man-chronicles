extends KinematicBody2D

signal dead

#Get the player and world nodes.
onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

#Starting X and Y coordinates. To allow the enemy to respawn when off screen.
var start_pos = Vector2()

#The distance between the player and enemy.
var dist

#Enemy HP.
const DEFAULT_HP = 200
var hp

#Damage enemy does to the player.
var touch = false
var damage = 60

var dead = false
var flash = false
var f_delay = 0

#Variables for this enemy
#Velocity
var velocity = Vector2()
var x_speed = 0
const GRAVITY = 900
const JUMP_SPEED = -500

#AI
var state = 0
const DEF_TIME = 60
var time = 60
var attack = false
var reset = false

func _ready():
	start_pos = Vector2(global_position.x, global_position.y)
	
	hp = DEFAULT_HP
	
	dist = global_position.distance_to(player.global_position)
	
	if global_position.x > player.global_position.x:
		$sprite.flip_h = true
	else:
		$sprite.flip_h = false
	
	$anim.play("idle")

func _physics_process(delta):
	if time > -1:
		time -= 1
	
	if time == 30:
		if global_position.x > player.global_position.x:
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
	
	if time == 0:
		state = round(rand_range(0, 1))
		attack = true
		pick_attack()
	
	if state == 1:
		if x_speed < 0:
			x_speed += 2
		elif x_speed > 0:
			x_speed -= 2
		
		if x_speed == 2 or x_speed == -2:
			$anim.play_backwards("jets")
			reset = true
	
	velocity.x = x_speed
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
		
func pick_attack():
	if attack:
		if state == 0:
			$anim.play("squat")
		else:
			$anim.play("jets")
		attack = false

func _on_anim_finished(anim_name):
	if anim_name == "squat":
		$anim.play("jump")
	
	if anim_name == "jets":
		if !reset:
			if $sprite.flip_h:
				x_speed = -180
			else:
				x_speed = 180
			$anim.play("dash")
		else:
			$anim.play("idle")
			time = DEF_TIME
			reset = false