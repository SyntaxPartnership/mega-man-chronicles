extends Node2D

var x_pos = 1
var y_pos = 1

var flash = true
var f_timer = 0
var cells = []

var b_pos
var b_act_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# warning-ignore:unused_argument
func _input(event):
	#Make the menu selectable with the d-pad/analog stick,
	if Input.is_action_just_pressed('up') and y_pos > 0:
		y_pos -= 1
	elif Input.is_action_just_pressed('down') and y_pos < 2:
		y_pos += 1
		
	if Input.is_action_just_pressed('left') and x_pos > 0:
		x_pos -= 1
	elif Input.is_action_just_pressed('right') and x_pos < 2:
		x_pos += 1

# warning-ignore:unused_argument
func _physics_process(delta):
	#Set blinker position and visibility.
	b_pos = Vector2((56 + (x_pos * 72)), (56 + (y_pos * 64)))
	
	if $highlight.global_position != b_pos:
		$highlight.global_position = b_pos
	
	if f_timer > -1:
		f_timer -= 1
	
	if f_timer < 0:
		if $highlight.visible:
			$highlight.hide()
		else:
			$highlight.show()
		f_timer = 8