extends Node2D

onready var icons = get_tree().get_nodes_in_group('item_icon')
onready var world = get_parent().get_parent()
onready var player = get_parent().get_parent().get_child(2)

onready var wpn_lvl = [
				global.player_life[int(player.swap)],
				global.rp_coil[int(player.swap) + 1],
				global.rp_jet[int(player.swap) + 1],
				global.weapon1[int(player.swap) + 1],
				global.weapon2[int(player.swap) + 1],
				global.weapon3[int(player.swap) + 1],
				global.weapon4[int(player.swap) + 1],
				global.weapon5[int(player.swap) + 1],
				global.weapon6[int(player.swap) + 1],
				global.weapon7[int(player.swap) + 1], 
				global.weapon8[int(player.swap) + 1],
				global.beat[int(player.swap) + 1],
				global.tango[int(player.swap) + 1],
				global.reggae[int(player.swap) + 1]
				]

var start = false

var kill_wpn

var new_plyr
var new_wpn
var new_menu = 0

var menu = 0
var m_pos = 0

var blink = 8

var down_a = 1
var down_b = 0

var color_set
var get_meters
var get_plyr

var sel_color = [Color(), Color(), global.yellow0, global.white]
var desel_color = [global.grey3, global.grey2, global.grey1, global.grey0]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(wpn_lvl)
	
	color_set = get_tree().get_nodes_in_group('wpn_icons')
	get_meters = get_tree().get_nodes_in_group('meters')
	get_plyr = get_tree().get_nodes_in_group('plyr_icon')
	
	set_max()
	set_names()
	hide_icons()
	menu_color()
	
	for c in color_set:
		c.material.set_shader_param('black', global.black)
		c.material.set_shader_param('t_col1', global.t_color2)
		c.material.set_shader_param('t_col2', global.t_color3)
		c.material.set_shader_param('t_col3', global.yellow0)
		c.material.set_shader_param('t_col4', global.white)
	
	for g in get_meters:
		g.material.set_shader_param('black', global.black)
		g.material.set_shader_param('t_col1', global.t_color2)
		g.material.set_shader_param('t_col2', global.t_color3)
		g.material.set_shader_param('t_col3', global.yellow0)
		g.material.set_shader_param('t_col4', global.white)
	
	for p in get_plyr:
		p.material.set_shader_param('black', global.black)
		p.material.set_shader_param('t_col1', global.t_color2)
		p.material.set_shader_param('t_col2', global.t_color3)
		p.material.set_shader_param('t_col3', global.yellow0)
		p.material.set_shader_param('t_col4', global.white)

# warning-ignore:unused_argument
func _input(event):
	if !get_tree().paused or !start:
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
			if !$e_tanks/icon.visible:
				$e_tanks/icon.show()
			if !$m_tanks/icon.visible:
				$m_tanks/icon.show()
			if !$et_call/icon.visible:
				$et_call/icon.show()
			if !$half_dmg/icon.visible:
				$half_dmg/icon.show()
			if !$spk_prtct/icon.visible:
				$spk_prtct/icon.show()
		
		if Input.is_action_just_pressed('left'):
			if m_pos > 0:
				m_pos -= 1
		
		if Input.is_action_just_pressed('right'):
			if m_pos < 4:
				m_pos += 1
		

# warning-ignore:unused_argument
func _process(delta):
	
	if new_wpn != global.player_weap[int(player.swap)]:
		new_wpn = global.player_weap[int(player.swap)]
		wpn_menu()
	
	if new_menu != menu:
		new_wpn = menu
		wpn_menu()

	item_menu()

func menu_color():
	if new_plyr != global.player:
		#Set the appropriate colors for the menu.
		$background.tile_set = load('res://assets/tilesets/menu/option-stage_'+str(global.player)+'.tres')
		
		for i in icons:
			i.texture = load('res://assets/sprites/pause/icons_'+str(global.player)+'.png')
		
		#Set active characer's color.
		get_plyr[int(!player.swap)].material.set_shader_param('r_col1', desel_color[0])
		get_plyr[int(!player.swap)].material.set_shader_param('r_col2', desel_color[1])
		get_plyr[int(!player.swap)].material.set_shader_param('r_col3', desel_color[1])
		get_plyr[int(!player.swap)].material.set_shader_param('r_col4', desel_color[2])
		
		#Set active character's meter color
		get_meters[int(player.swap)+1].material.set_shader_param('r_col1', sel_color[2])
		get_meters[int(player.swap)+1].material.set_shader_param('r_col2', sel_color[3])
		
		get_meters[int(!player.swap)+1].material.set_shader_param('r_col1', desel_color[0])
		get_meters[int(!player.swap)+1].material.set_shader_param('r_col2', desel_color[1])
		
		if player.swap:
			$plyr_1/text.set('custom_colors/font_color', desel_color[2])
		else:
			$plyr_2/text.set('custom_colors/font_color', desel_color[2])
		
		#This section is also used to update the player's meter levels.
		for i in range(color_set.size()):
			for n in range(wpn_lvl.size()):
				if n < 11:
					if i == n:
						color_set[i].get_child(2).set('value', wpn_lvl[n])
				if n >= 11:
					color_set[11].get_child(2).set('value', wpn_lvl[11 + global.player])
				get_meters[1].set('value', global.player_life[0])
				get_meters[2].set('value', global.player_life[1])
		
		#Update how many items are in possession as well.
					
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

func item_menu():
	#Reset the item menu position when in the weapons menu.
	if m_pos != 0 and menu == 0:
		m_pos = menu
	
	#Make the selected icons blink.
	if menu != 0 and blink > 0:
		blink -= 1
	
	if menu != 0 and blink == 0:
		if m_pos == 0:
			if $e_tanks/icon.visible:
				$e_tanks/icon.hide()
			else:
				$e_tanks/icon.show()
		if m_pos == 1:
			if $m_tanks/icon.visible:
				$m_tanks/icon.hide()
			else:
				$m_tanks/icon.show()
		if m_pos == 2:
			if $et_call/icon.visible:
				$et_call/icon.hide()
			else:
				$et_call/icon.show()
		if m_pos == 3:
			if $half_dmg/icon.visible:
				$half_dmg/icon.hide()
			else:
				$half_dmg/icon.show()
		if m_pos == 4:
			if $spk_prtct/icon.visible:
				$spk_prtct/icon.hide()
			else:
				$spk_prtct/icon.show()
		
		blink = 8
	
	#Reset other icons to visible when not selected.
	if menu != 0:
		if m_pos == 0:
			if !$m_tanks/icon.visible:
				$m_tanks/icon.show()
			if !$et_call/icon.visible:
				$et_call/icon.show()
			if !$half_dmg/icon.visible:
				$half_dmg/icon.show()
			if !$spk_prtct/icon.visible:
				$spk_prtct/icon.show()
		if m_pos == 1:
			if !$e_tanks/icon.visible:
				$e_tanks/icon.show()
			if !$et_call/icon.visible:
				$et_call/icon.show()
			if !$half_dmg/icon.visible:
				$half_dmg/icon.show()
			if !$spk_prtct/icon.visible:
				$spk_prtct/icon.show()
		if m_pos == 2:
			if !$e_tanks/icon.visible:
				$e_tanks/icon.show()
			if !$m_tanks/icon.visible:
				$m_tanks/icon.show()
			if !$half_dmg/icon.visible:
				$half_dmg/icon.show()
			if !$spk_prtct/icon.visible:
				$spk_prtct/icon.show()
		if m_pos == 3:
			if !$e_tanks/icon.visible:
				$e_tanks/icon.show()
			if !$m_tanks/icon.visible:
				$m_tanks/icon.show()
			if !$et_call/icon.visible:
				$et_call/icon.show()
			if !$spk_prtct/icon.visible:
				$spk_prtct/icon.show()
		if m_pos == 4:
			if !$e_tanks/icon.visible:
				$e_tanks/icon.show()
			if !$m_tanks/icon.visible:
				$m_tanks/icon.show()
			if !$et_call/icon.visible:
				$et_call/icon.show()
			if !$half_dmg/icon.visible:
				$half_dmg/icon.show()

func wpn_menu():
	
	var get_nodes = get_tree().get_nodes_in_group('wpn_icons')
	
	world.palette_swap()
	sel_color[0] = world.palette[1]
	sel_color[1] = world.palette[2]

	if global.player_weap[int(player.swap)] == 0:
		$weap_01/meter.material.set_shader_param('r_col1', sel_color[2])
		$weap_01/meter.material.set_shader_param('r_col2', sel_color[3])
	else:
		$weap_01/meter.material.set_shader_param('r_col1', desel_color[0])
		$weap_01/meter.material.set_shader_param('r_col2', desel_color[1])
	
	for i in range(get_nodes.size()):
		if i == global.player_weap[int(player.swap)] and menu == 0:
			get_nodes[i].material.set_shader_param('r_col1', sel_color[0])
			get_nodes[i].material.set_shader_param('r_col2', sel_color[1])
			get_nodes[i].material.set_shader_param('r_col3', sel_color[2])
			
			get_nodes[i].get_child(1).set('custom_colors/font_color', sel_color[3])
			
			get_plyr[int(player.swap)].material.set_shader_param('r_col1', sel_color[0])
			get_plyr[int(player.swap)].material.set_shader_param('r_col2', sel_color[1])
			get_plyr[int(player.swap)].material.set_shader_param('r_col3', sel_color[2])
			get_plyr[int(player.swap)].material.set_shader_param('r_col4', sel_color[3])
			
			get_plyr[2].material.set_shader_param('r_col1', sel_color[0])
			get_plyr[2].material.set_shader_param('r_col2', sel_color[1])
			get_plyr[2].material.set_shader_param('r_col3', sel_color[2])
			get_plyr[2].material.set_shader_param('r_col4', sel_color[3])
		else:
			get_nodes[i].material.set_shader_param('r_col1', desel_color[0])
			get_nodes[i].material.set_shader_param('r_col2', desel_color[1])
			get_nodes[i].material.set_shader_param('r_col3', desel_color[2])
			
			get_nodes[i].get_child(1).set('custom_colors/font_color', desel_color[2])