extends Node2D

onready var icons = get_tree().get_nodes_in_group('item_icon')
onready var player = get_parent().get_parent().get_child(2)

var new_plyr

var menu = 0
var m_pos = 0

var blink = 8

var down_a = 1
var down_b = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_max()
	set_names()
	hide_icons()
	color()

# warning-ignore:unused_argument
func _input(event):
	if !get_tree().paused:
		return
	#Weapons menu.
	#Set the weapon values.
	if menu == 0:
		#Set this section here to prevent issues transitioning between weapon selection and item selection.
		if Input.is_action_just_pressed('down'):
			if global.player_weap[int(player.swap)] == down_a or global.player_weap[int(player.swap)] == down_b:
				menu += 1
		
		if Input.is_action_just_pressed('up'):
			#Left Side
			if global.player_weap[int(player.swap)] > 0 and global.player_weap[int(player.swap)] <= 5:
				global.player_weap[int(player.swap)] -= 1
			#Right Side
			if global.player_weap[int(player.swap)] > 6 and global.player_weap[int(player.swap)] <= 11:
				global.player_weap[int(player.swap)] -= 1
		
		if Input.is_action_just_pressed('down'):
			#Left Side
			if global.player_weap[int(player.swap)] >= 0 and global.player_weap[int(player.swap)] < down_a:
				global.player_weap[int(player.swap)] += 1
			#Right Side
			if global.player_weap[int(player.swap)] >= 6 and global.player_weap[int(player.swap)] < down_b:
				global.player_weap[int(player.swap)] += 1
		
		if Input.is_action_just_pressed('up'):
			#Skip unacquired weapons.
			#Left Side
			if global.player_weap[int(player.swap)] == 5 and !global.weapon3[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 4 and !global.weapon2[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 3 and !global.weapon1[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int(player.swap)] == 2 and global.player == 2:
				global.player_weap[int(player.swap)] -= 1
			
			#Right Side (Weapon ID 6 is skipped because the player should not be able to access this side when down_b = 0)
			if global.player == 0 and global.player_weap[int(player.swap)] == 11 and !global.beat[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player == 1 and global.player_weap[int(player.swap)] == 11 and !global.tango[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player == 2 and global.player_weap[int(player.swap)] == 11 and !global.reggae[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 10 and !global.weapon8[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 9 and !global.weapon7[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 8 and !global.weapon6[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 7 and !global.weapon5[0]:
				global.player_weap[int(player.swap)] -= 1
		
		if Input.is_action_just_pressed('down'):
			#Skip unacquired weapons.
			#Left Side
			if global.player_weap[int(player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int(player.swap)] == 2 and global.player == 2:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 3 and !global.weapon1[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 4 and !global.weapon2[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 5 and !global.weapon3[0]:
				global.player_weap[int(player.swap)] += 1
			
			#Right Side
			if global.player_weap[int(player.swap)] == 6 and !global.weapon4[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 7 and !global.weapon5[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 8 and !global.weapon6[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 9 and !global.weapon7[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 10 and !global.weapon8[0]:
				global.player_weap[int(player.swap)] += 1
		
		if Input.is_action_just_pressed('left'):
			#Move selection to left side.
			if global.player_weap[int(player.swap)] > 5:
				global.player_weap[int(player.swap)] -= 6
			
		if Input.is_action_just_pressed('left'):
			#Skip unacquired weapons.
			if global.player_weap[int(player.swap)] > down_a and global.player_weap[int(player.swap)] < 6:
				global.player_weap[int(player.swap)] = down_a
		
		if Input.is_action_just_pressed('right'):
			#Move selection to the right side.
			if down_b != 0 and global.player_weap[int(player.swap)] < 6:
				global.player_weap[int(player.swap)] += 6
		
		if Input.is_action_just_pressed('right'):
			#Move selection to the right side.
			if global.player_weap[int(player.swap)] > down_b and global.player_weap[int(player.swap)] > 5:
				global.player_weap[int(player.swap)] = down_b
	
	if menu != 0:
		#Items menu.
		#Move through items.
		if Input.is_action_just_pressed('up'):
			#There's no need to set the value to down_a or down_b as the player cannot proceed passed these values.
			menu -= 1
		
		if Input.is_action_just_pressed('left'):
			if m_pos > 0:
				m_pos -= 1
		
		if Input.is_action_just_pressed('right'):
			if m_pos < 4:
				m_pos += 1
		

# warning-ignore:unused_argument
func _physics_process(delta):
	#Reset the item menu position when in the weapons menu.
	if m_pos != 0 and menu == 0:
		m_pos = menu
		
	if menu != 0 and blink > 0:
		blink -= 1
	
	if menu != 0 and blink == 0:
		if m_pos == 0:
			if $e_tanks/icon.visible:
				$e_tanks/icon.hide()
			else:
				$e_tanks/icon.show()
		blink = 8
		
	
	print(global.player_weap[int(player.swap)],', ',menu,', ',m_pos,', ',blink)

func color():
	if new_plyr != global.player:
		#Set the appropriate colors for the menu.
		$background.tile_set = load('res://assets/tilesets/menu/option-stage_'+str(global.player)+'.tres')
		
		for i in icons:
			i.texture = load('res://assets/sprites/pause/icons_'+str(global.player)+'.png')
			
		new_plyr = global.player

func set_max():
	#Check weapons to see what the max menu value for each side is.
	#Left side.
	if global.rp_jet[0] and global.player != 2:
		down_a = 2
	if global.weapon1[0]:
		down_a = 3
	if global.weapon2[0]:
		down_a = 4
	if global.weapon3[0]:
		down_a = 5
	
	#Right side
	if global.weapon4[0]:
		down_b = 6
	if global.weapon5[0]:
		down_b = 7
	if global.weapon6[0]:
		down_b = 8
	if global.weapon7[0]:
		down_b = 9
	if global.weapon8[0]:
		down_b = 10
	if global.beat[0] and global.player == 0 or global.tango[0] and global.player == 1 or global.reggae[0] and global.player == 2:
		down_b = 11

func hide_icons():
	#Check global values and make unacquired weapons and items invisible.
	if !global.rp_jet[0] and global.player != 2 or global.player == 2:
		$weap_03.hide()
	if !global.weapon1[0]:
		$weap_04.hide()
	if !global.weapon2[0]:
		$weap_05.hide()
	if !global.weapon3[0]:
		$weap_06.hide()
	if !global.weapon4[0]:
		$weap_07.hide()
	if !global.weapon5[0]:
		$weap_08.hide()
	if !global.weapon6[0]:
		$weap_09.hide()
	if !global.weapon7[0]:
		$weap_10.hide()
	if !global.weapon8[0]:
		$weap_11.hide()
	if global.player == 0 and !global.beat[0]:
		$weap_12.hide()
	if global.player == 1 and !global.tango[0]:
		$weap_12.hide()
	if global.player == 2 and !global.reggae[0]:
		$weap_12.hide()

func set_names():
	#Set unique text and icons for the menu.
	if global.player == 0:
		$weap_01/icon.set_frame(0)
		$weap_01/text.set_text('M. BUSTER')
		$weap_02/icon.set_frame(2)
		$weap_02/text.set_text('RUSH COIL')
		$weap_03/icon.set_frame(3)
		$weap_03/text.set_text('RUSH JET')
		$weap_12/icon.set_frame(15)
		$weap_12/text.set_text('B. ATTACK')
	if global.player == 1:
		$weap_01/icon.set_frame(0)
		$weap_01/text.set_text('P. BUSTER')
		$weap_02/icon.set_frame(4)
		$weap_02/text.set_text('P. COIL')
		$weap_03/icon.set_frame(5)
		$weap_03/text.set_text('P. JET')
		$weap_12/icon.set_frame(16)
		$weap_12/text.set_text('T. BALL')
	if global.player == 2:
		$weap_01/icon.set_frame(1)
		$weap_01/text.set_text('B. BUSTER')
		$weap_02/icon.set_frame(6)
		$weap_02/text.set_text('T. BOOST')
		$weap_12/icon.set_frame(17)
		$weap_12/text.set_text('R. TURRET')
	
	#Set names and icons for the players.
	if global.player_id[0] == 0:
		$plyr_1/icon.set_frame(0)
		$plyr_1/text.set_text('MEGA MAN')
	if global.player_id[0] == 1:
		$plyr_1/icon.set_frame(1)
		$plyr_1/text.set_text('PROTO MAN')
	if global.player_id[0] == 2:
		$plyr_1/icon.set_frame(2)
		$plyr_1/text.set_text('BASS')
	
	if global.player_id[1] == 0:
		$plyr_2/icon.set_frame(0)
		$plyr_2/text.set_text('MEGA MAN')
	if global.player_id[1] == 1:
		$plyr_2/icon.set_frame(1)
		$plyr_2/text.set_text('PROTO MAN')
	if global.player_id[1] == 2:
		$plyr_2/icon.set_frame(2)
		$plyr_2/text.set_text('BASS')