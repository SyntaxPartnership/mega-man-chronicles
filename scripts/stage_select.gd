extends Node2D

var x_pos = 1
var y_pos = 1

var flash = true
var f_timer = 0

var b_pos

var stg_pick = false
var pick_timer = 0
var pick_limit = 16

var bars = false
var bars_rev = false
var bar_spd = 200
var bar_pos
var tile_y_pos = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(false)

# warning-ignore:unused_argument
func _input(event):
	#Make the menu selectable with the d-pad/analog stick.
	if Input.is_action_just_pressed('up') and y_pos > 0:
		y_pos -= 1
		f_timer = 8
		$back_layer/highlight.show()
	if Input.is_action_just_pressed('down') and y_pos < 2:
		y_pos += 1
		f_timer = 8
		$back_layer/highlight.show()
	if Input.is_action_just_pressed('left') and x_pos > 0:
		x_pos -= 1
		f_timer = 8
		$back_layer/highlight.show()
	if Input.is_action_just_pressed('right') and x_pos < 2:
		x_pos += 1
		f_timer = 8
		$back_layer/highlight.show()
	
	if Input.is_action_just_pressed('jump'):
		stg_pick = true
		$back_layer/highlight.show()
		set_process_input(false)
	

# warning-ignore:unused_argument
func _physics_process(delta):
	#Set blinker position and visibility.	
	b_pos = Vector2((56 + (x_pos * 72)), (56 + (y_pos * 64)))
	
	if $back_layer/highlight.global_position != b_pos:
		$back_layer/highlight.global_position = b_pos
	
	if !stg_pick:
		if f_timer > -1:
			f_timer -= 1
		
		if f_timer < 0:
			if $back_layer/highlight.visible:
				$back_layer/highlight.hide()
			else:
				$back_layer/highlight.show()
			f_timer = 8
		
	if stg_pick and pick_limit > -1:
		if pick_timer > -1:
			pick_timer -= 1
		
		if pick_timer < 0:
			if $back_layer/flash.visible:
				$back_layer/flash.hide()
				pick_limit -= 1
			else:
				$back_layer/flash.show()
				
			pick_timer = 2
	
	if pick_limit == 0:
		$next.interpolate_property($back_layer, 'modulate', Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.125, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$next.start()
		
	bar_pos = $back_layer/background.world_to_map($front_layer/top_bar.position)
	
	if bars:
		if !bars_rev:
			$front_layer/top_bar.position.y += bar_spd * delta
			$front_layer/bottom_bar.position.y += -bar_spd * delta
			
			if $front_layer/top_bar.position.y >= 116:
				bars_rev = true
		else:
			if $front_layer/top_bar.position.y > 76:
				$front_layer/top_bar.position.y += -bar_spd * delta
				$front_layer/bottom_bar.position.y += bar_spd * delta
				
				if bar_pos.y == 14:
					for i in range(0, 32):
						$back_layer/background.set_cellv(Vector2(tile_y_pos[i], 14), 48, false, false, false)
						$back_layer/background.set_cellv(Vector2(tile_y_pos[i], 15), 48, false, false, false)
				if bar_pos.y == 13:
					for i in range(0, 32):
						$back_layer/background.set_cellv(Vector2(tile_y_pos[i], 13), 48, false, false, false)
						$back_layer/background.set_cellv(Vector2(tile_y_pos[i], 16), 48, false, false, false)
				if bar_pos.y == 12:
					for i in range(0, 32):
						$back_layer/background.set_cellv(Vector2(tile_y_pos[i], 12), 48, false, false, false)
						$back_layer/background.set_cellv(Vector2(tile_y_pos[i], 17), 48, false, false, false)
				if bar_pos.y == 11:
					for i in range(0, 32):
						$back_layer/background.set_cellv(Vector2(tile_y_pos[i], 11), 48, false, false, false)
						$back_layer/background.set_cellv(Vector2(tile_y_pos[i], 18), 48, false, false, false)
				if bar_pos.y == 10:
					for i in range(0, 32):
						$back_layer/background.set_cellv(Vector2(tile_y_pos[i], 10), 47, false, false, false)
						$back_layer/background.set_cellv(Vector2(tile_y_pos[i], 19), 44, false, false, false)
			elif $front_layer/top_bar.position.y > 76:
				$front_layer/top_bar.position.y = 76
				$front_layer/bottom_bar.position.y = 164
				bars = false
	
	print($back_layer/background.world_to_map($front_layer/top_bar.position))
func _on_fade_fadein():
	set_process_input(true)

func _on_next_tween_all_completed():
	$back_layer/background.clear()
	$back_layer/boss_names.hide()
	$back_layer/mugshot1.hide()
	$back_layer/mugshot2.hide()
	$back_layer/mugshot3.hide()
	$back_layer/mugshot4.hide()
	$back_layer/mugshot5.hide()
	$back_layer/mugshot6.hide()
	$back_layer/mugshot7.hide()
	$back_layer/mugshot8.hide()
	$back_layer/mugshot9.hide()
	$back_layer/info.hide()
	$back_layer/info2.hide()
	$back_layer/highlight.hide()
	$back_layer.modulate = Color(1.0, 1.0, 1.0, 1.0)
	bars = true
