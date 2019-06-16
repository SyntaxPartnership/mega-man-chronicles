extends Node2D

var allow_ctrl = false

const INPUT_ACTIONS = ['up', 'down', 'left', 'right', 'jump', 'fire', 'dash', 'prev', 'next', 'select', 'start']
const CONFIG_FILE = 'user://options.cfg'


func _ready():
	load_config()

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

# warning-ignore:unused_argument
func _process(delta):
	#Include this to allow skipping of filler screens and legal mumbo jumbo.
	if allow_ctrl:
		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("start"):
			allow_ctrl = false
			$timer.stop()
			$fade.set("end", true)

func _on_timer_timeout():
	$fade.set("end", true)

#Include this function to allow the player to have control.
func _on_fade_fadein():
	allow_ctrl = true
	$timer.start(5)

#Fade out and move to the next scene.
func _on_fade_fadeout():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/title.tscn")
