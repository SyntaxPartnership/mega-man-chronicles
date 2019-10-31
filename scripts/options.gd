extends Control

const INPUT_ACTIONS = ['up', 'down', 'left', 'right', 'jump', 'fire', 'dash', 'prev', 'next', 'select', 'start'] 

var option_a = 'UP\n\nDOWN\n\nLEFT\n\nRIGHT\n\nJUMP\n\nFIRE\n\nDASH\n\nPREV\n\nNEXT\n\nSELECT\n\nSTART'
var option_b = 'JUMP\n\nFIRE\n\nDASH\n\nPREV\n\nNEXT\n\nSELECT\n\nSTART'
var option_c = 'USE RIGHT ANALOG/ NUMPAD TO SWAP WEAPONS QUICKLY?'
var option_d = 'MUSIC\n\nEFFECTS'
var option_e = 'SCALE\n\n\n\nFULLSCREEN'
var option_f = 'RETURN TO MAIN MENU?'

var ctrl_lock = true
var pressed = false
var cur_a_pos = Vector2()
var cur_b_pos = Vector2()

var menu = 0
var menu_a_pos = 0
var menu_b_pos = 0
var menu_b_max = 0

func _ready():
	cur_a_pos = $cursor.position
	cur_b_pos = $cursor2.position

func _input(event):
	
	if !ctrl_lock:
		var x_dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		var y_dir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		
		if menu == 0:
			if y_dir == -1 and menu_a_pos > 0:
				menu_a_pos -= 1
			if y_dir == 1 and menu_a_pos < 6:
				menu_a_pos += 1
		
			if Input.is_action_just_pressed("jump"):
				pressed = true
				match menu_a_pos:
					0:
						$opt_text.set_text(option_a)
						menu_b_max = 10
						var id = 1
						var opt_dict = {
							"opt01" : $opt_text/opt01,
							"opt02" : $opt_text/opt02,
							"opt03" : $opt_text/opt03,
							"opt04" : $opt_text/opt04,
							"opt05" : $opt_text/opt05,
							"opt06" : $opt_text/opt06,
							"opt07" : $opt_text/opt07,
							"opt08" : $opt_text/opt08,
							"opt09" : $opt_text/opt09,
							"opt10" : $opt_text/opt10,
							"opt11" : $opt_text/opt11
							}
						for actions in INPUT_ACTIONS:
							var act_list = InputMap.get_action_list(actions)
							#Assume that the first entry deals with keyboard commands.
							var scancode = OS.get_scancode_string(act_list[0].scancode)
							match id:
								1:
									$opt_text/opt01.set_text('['+scancode+']')
								2:
									$opt_text/opt02.set_text('['+scancode+']')
								3:
									$opt_text/opt03.set_text('['+scancode+']')
								4:
									$opt_text/opt04.set_text('['+scancode+']')
								5:
									$opt_text/opt05.set_text('['+scancode+']')
								6:
									$opt_text/opt06.set_text('['+scancode+']')
								7:
									$opt_text/opt07.set_text('['+scancode+']')
								8:
									$opt_text/opt08.set_text('['+scancode+']')
								9:
									$opt_text/opt09.set_text('['+scancode+']')
								10:
									$opt_text/opt10.set_text('['+scancode+']')
								11:
									$opt_text/opt11.set_text('['+scancode+']')
							id += 1
					1:
						$opt_text.set_text(option_b)
						menu_b_max = 6
				menu = 1
				$txt_fade.interpolate_property($opt_text, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$txt_fade.start()
		
		if menu == 2:
			#Add if statement for certain menus.
			if y_dir == -1 and menu_b_pos > 0:
				menu_b_pos -= 1
			if y_dir == 1 and menu_b_pos < menu_b_max:
				menu_b_pos += 1
	
	$cursor.position.y = cur_a_pos.y + (menu_a_pos * 16)
	#Add if statement for certain menus
	$cursor2.position.y = cur_b_pos.y + (menu_b_pos * 16)

func _on_fade_fadein():
	ctrl_lock = false
	$cursor.show()

func _on_fade_fadeout():
	pass # Replace with function body.

func _on_txt_fade_completed():
	if menu == 1:
		$cursor2.show()
		menu = 2
