extends Control

const INPUT_ACTIONS = ['up', 'down', 'left', 'right', 'jump', 'fire', 'dash', 'prev', 'next', 'select', 'start'] 

var option_a = 'UP\n\nDOWN\n\nLEFT\n\nRGHT\n\nJUMP\n\nFIRE\n\nDASH\n\nPREV\n\nNEXT\n\nSLCT\n\nSTRT'
var option_b = 'USE RIGHT ANALOG/ NUMPAD TO SWAP WEAPONS QUICKLY?'
var option_c = 'MUSIC\n\nEFFECTS'
var option_d = 'SCALE\n\n\n\nFULLSCREEN'
var option_e = 'RETURN TO MAIN MENU?'

func _ready():
	$opt_text.set_text(option_e)


func _on_fade_fadein():
	pass # Replace with function body.


func _on_fade_fadeout():
	pass # Replace with function body.
