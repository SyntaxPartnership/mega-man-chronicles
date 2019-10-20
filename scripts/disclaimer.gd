extends Node2D

var allow_ctrl = false

var text_a = "       ----WARNING!----\n\n\n\n\nThis is a test demo of a fan\ngame currently in production.\n\n\nAnything found within is\nsubject to change and may not\nbe included in the final\nrelease.\n\n\nMega Man™ and all related\ncharacters are © Capcom\nCo., LTD.\n\n\nThis game was developed as\na free, non profit project."
var text_b = "\n\n\n\n\n\n\n   Dedicated to my wife and\n   children.\n\n\n   You guys are a constant\n   source of inspiration to\n   me.\n\n\n   I love you all.\n\n\n                    -Dad."

const INPUT_ACTIONS = ['up', 'down', 'left', 'right', 'jump', 'fire', 'dash', 'prev', 'next', 'select', 'start']
const CONFIG_FILE = 'user://options.cfg'

var txt_line = 0

func _ready():
	$text.set_text(text_a)
#	load_config()
	pass

#Using the example of loading/saving from the Input Mapping tutorial.
func load_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if err: #Assuming that options.cfg doesn't exist.
		for action_name in INPUT_ACTIONS:
			var action_list = InputMap.get_action_list(action_name)
			#Since there are two control types, get data for both.
			var keyboard = OS.get_scancode_string(action_list[0].scancode)
			var gamepad = Input.get_joy_button_string(action_list[1].button_index)
			config.set_value('k_input', action_name, keyboard)
			config.set_value('g_input', action_name, gamepad)
		#Set values for global options.
		config.set_value('options', 'sound', global.sound)
		config.set_value('options', 'music', global.music)
		config.set_value('options', 'res', global.res)
		config.set_value('options', 'f_screen', global.f_screen)
		config.set_value('options', 'quick_swap', global.quick_swap)
		#Save initial config file.
		config.save(CONFIG_FILE)
	else: #Successful load. Set values.
		#Set keyboard controls.
		for k_action in config.get_section_keys('k_input'):
			var keyboard = OS.find_scancode_from_string(config.get_value('k_input', k_action))
			var k_event = InputEventKey.new()
			k_event.scancode = keyboard
			for old_event in InputMap.get_action_list(k_action):
				if old_event is InputEventKey:
					InputMap.action_erase_event(k_action, old_event)
			InputMap.action_add_event(k_action, k_event)
			var get_list = InputMap.get_action_list(k_action)
			print(OS.get_scancode_string(get_list[1].scancode))
#		for g_action in config.get_section_keys('g_input'):
#			var get_list = InputMap.get_action_list(g_action)
#			var gamepad = Input.get_joy_button_from_string(config.get_value('g_input', g_action))
#			print(gamepad)

# warning-ignore:unused_argument
func _process(delta):
	#Include this to allow skipping of filler screens and legal mumbo jumbo.
	if allow_ctrl:
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("start"):
			allow_ctrl = false
			$timer.stop()
			$fade.state = 1
			$fade.set("end", true)

func _on_timer_timeout():
	$fade.state = 1
	$fade.set("end", true)

#Include this function to allow the player to have control.
func _on_fade_fadein():
	allow_ctrl = true
	$timer.start(10)
	$txt_timer.start(5)

#Fade out and move to the next scene.
func _on_fade_fadeout():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/title.tscn")

func _on_txt_timeout():
	$txt_fade.interpolate_property($text, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$txt_fade.start()

func _on_txt_fade_completed(object, key):
	if txt_line == 0:
		$text.set_text(text_b)
		$txt_fade.interpolate_property($text, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$txt_fade.start()
		txt_line += 1
