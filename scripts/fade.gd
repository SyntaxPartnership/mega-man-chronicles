extends Node2D

signal fadein
signal fadeout

var begin = true
var end = false
var fade_out = false
var state = 0
var complete = false

func _process(delta):
	
	if begin:
		begin = false
		$fade_fade.interpolate_property($fade_mask, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$fade_fade.start()
	
	#Modify for state value.
	if end:
		end = false
		$fade_fade.interpolate_property($fade_mask, 'modulate', Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$fade_fade.start()

func _on_fade_fade_tween_completed(object, key):
	if state == 0 or state == 3:
		emit_signal("fadein")
	if state == 1 or state == 2:
		emit_signal("fadeout")
		
