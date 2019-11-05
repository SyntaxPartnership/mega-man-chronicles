extends KinematicBody2D

const GRAVITY = 900

var x_spd = 0

var dir = 0
var velocity = Vector2()

func _ready():
	$anim.play("idle")
	
	velocity.y = rand_range(-200, -400)

func _physics_process(delta):
	
	#Set which direction the projectile will fly.
	if $sprite.flip_h:
		dir = -1
	else:
		dir = 1
	
	velocity.x = x_spd * dir
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))