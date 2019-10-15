extends KinematicBody2D

onready var world = get_parent().get_parent()

const JUMP_SPEED = -310
const GRAVITY = 900

var x_spd = 0
var velocity = Vector2()
var time = -1
var f_delay = 0

var new_plyr

func _ready():
	#Set appropriate palette
	#Get the colors to be replaced.
	material.set_shader_param('t_col1', global.t_color1)
	material.set_shader_param('t_col2', global.t_color2)
	material.set_shader_param('t_col3', global.t_color3)
	material.set_shader_param('t_col4', global.t_color4)
	#Set transparent pixels.
	material.set_shader_param('trans', global.trans)
	#Set facial colors
	material.set_shader_param('f_col1', global.black)
	material.set_shader_param('f_col2', global.yellow0)
	material.set_shader_param('f_col3', global.white)
	
	new_plyr = global.player
	
	if global.player == 0:
		$sprite.set_frame(13)
	
	if global.player == 1:
		$sprite.set_frame(14)
		
	if global.player == 2:
		$sprite.set_frame(15)
	
	#Set X/Y velocity and time at spawn time if dropped by an enemy.

func _physics_process(delta):
	
	#Set the appropriate sprite.
	if global.player != new_plyr:
		if global.player == 0:
			$sprite.set_frame(13)
	
		if global.player == 1:
			$sprite.set_frame(14)
		
		if global.player == 2:
			$sprite.set_frame(15)
		
		new_plyr = global.player
	
	velocity.x = x_spd
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if time > -1:
		time -= 1
	
	#If spawned from an enemy, make the item start flashing when the time is lowe enough
	if time <= 60 and time > -1:
		f_delay += 1
	
	if f_delay == 1:
		$sprite.hide()
	
	if f_delay == 3:
		$sprite.show()
	
	#Loop the f_delay value.
	if f_delay > 3:
		f_delay = 0
	
	#Kill the item if the time expires.
	if time == 0:
		queue_free()