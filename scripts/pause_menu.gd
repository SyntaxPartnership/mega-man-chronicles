extends Node2D

onready var icons = get_tree().get_nodes_in_group('item_icon')
onready var player = get_parent().get_parent().get_child(2)

var new_plyr

var menu = 0

var down_a = 1
var down_b = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_max()
	color()

func _input(event):
	#Set the weapon values.
	if menu == 0:
		if Input.is_action_just_pressed('up'):
			#Left Side
			if global.player_weap[int(player.swap)] > 0 and global.player_weap[int(player.swap)] <= 5:
				global.player_weap[int(player.swap)] -= 1
			#Right Side
			if global.player_weap[int(player.swap)] > 6 and global.player_weap[int(player.swap)] <= 11:
				global.player_weap[int(player.swap)] -= 1
		
		if Input.is_action_just_pressed('up'):
			#Skip unacquired weapons.
			if global.player_weap[int(player.swap)] == 5 and !global.weapon3[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 4 and !global.weapon2[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 3 and !global.weapon1[0]:
				global.player_weap[int(player.swap)] -= 1
			if global.player_weap[int(player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int(player.swap)] == 2 and global.player == 2:
				global.player_weap[int(player.swap)] -= 1
		
		if Input.is_action_just_pressed('down'):
			#Left Side
			if global.player_weap[int(player.swap)] >= 0 and global.player_weap[int(player.swap)] < 5:
				global.player_weap[int(player.swap)] += 1
			#Right Side
			if global.player_weap[int(player.swap)] >= 6 and global.player_weap[int(player.swap)] < 11:
				global.player_weap[int(player.swap)] += 1
		
		if Input.is_action_just_pressed('down'):
			#Skip unacquired weapons.
			if global.player_weap[int(player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int(player.swap)] == 2 and global.player == 2:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 3 and !global.weapon1[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 4 and !global.weapon2[0]:
				global.player_weap[int(player.swap)] += 1
			if global.player_weap[int(player.swap)] == 5 and !global.weapon3[0]:
				global.player_weap[int(player.swap)] += 1

		
		if Input.is_action_just_pressed('left'):
			pass
		
		if Input.is_action_just_pressed('right'):
			pass

func _process(delta):
	print(global.player_weap[int(player.swap)])

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