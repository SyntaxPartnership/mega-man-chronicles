extends Node2D

var allow_ctrl = false

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
