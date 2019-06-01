extends Node2D

onready var tween = $menu_fade

var menu_pos = 0
var menu = 0
var can_move = false
var accept = false
var cancel = false
var fade_in = false
var fade_out = false
var cursor_pos = Vector2()

func _ready():
	cursor_pos = $cursor.position

func _physics_process(delta):
	
	if can_move:
		#If this returns true, then a button is being held and menu selection cannot continue.
		if Input.is_action_pressed("start") or Input.is_action_pressed("jump"):
			accept = true
		else:
			accept = false
		
		if Input.is_action_pressed("fire"):
			cancel = true
		else:
			cancel = false
		
		if accept and menu == 1 and menu_pos == 0:
			menu += 1
			$fade.set("end", true)
		
		#If the accept button is pressed.
		if accept and menu == 0:
			menu += 1
			fade_in = true
			can_move = false
			$menu_fade.interpolate_property($menu, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$menu_fade.start()
		
		#If the cancel button is pressed.
		if cancel and menu == 1:
			menu -= 1
			fade_in = true
			can_move = false
			$menu_fade.interpolate_property($menu, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
			$menu_fade.start()
			$cursor.hide()
		
		#Set cursor position.
		if menu == 1 and Input.is_action_just_pressed("up"):
			menu_pos -= 1
		elif menu == 1 and Input.is_action_just_pressed("down"):
			menu_pos += 1
		
		#Loop position.
		if menu_pos < 0:
			menu_pos = 3
		elif menu_pos > 3:
			menu_pos = 0
		
		#Set sprite to position.
		$cursor.position.y = cursor_pos.y + (16 * menu_pos)
		

func _on_fade_fadein():
	can_move = true

func _on_fade_fadeout():
	get_tree().change_scene("res://scenes/world.tscn")


func _on_menu_fade_tween_completed(object, key):
	#Resume menu movement.
	if !fade_in and !fade_out:
		can_move = true
		if menu == 1:
			$cursor.show()
	
	#Make the menu fade back in.
	if fade_in:
		fade_in = false
		fade_out = true
		$menu_fade.interpolate_property($menu, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$menu_fade.start()
	#Change the text as needed.
	if fade_out:
		if menu == 0:
			$menu.set_text('\n\nPRESS START')
		elif menu == 1:
			$menu.set_text('NEW GAME\n\nLOAD GAME\n\nOPTIONS\n\nEXTRA MODES')
		fade_out = false