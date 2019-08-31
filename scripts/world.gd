extends Node2D

signal scrolling
signal close_gate

onready var objects = $graphic/objects

#Object constants
const DEATH_BOOM = preload('res://scenes/effects/s_explode_loop.tscn')

# warning-ignore:unused_class_variable
var fade_state

#Determines player position in the game world.
var pos = Vector2()
var player_tilepos = Vector2()
var stand_on
var overlap
var ladder_set
var ladder_top
var player_room = Vector2(0, 0)
var spawn_pt
var boss = false
var dead = false
var dead_delay = 16
var restart = 360
var heal_delay
var swapping = false

#Camera values
var res = Vector2()
var center = Vector2()

var cam_move = 0
var cam_allow = []
var scroll = false
var scroll_len = 0
var scroll_spd = 4

#Replace with better functions later
var rooms = 0
var prev_room = Vector2(0, 0)
var endless = false
var endless_rms = []
var screens = 0

#Color Variables.
var palette = [Color('#000000'), Color('#000000'), Color('#000000')]

#Weapon Swapping variables.
var left = false
var right = false
var last_dir = 0
var last_weap = 0

var tele_timer = 60
var tele_dest

#Special effects
var spl_trigger = false
var bbl_count = 0

func _ready():
	res = get_viewport_rect().size
	
	#Hide Object Layer
	objects.hide()
	
	#Spawn stage objects.
	spawn_objects()
	
	#Add Continue and Spawn Scripts here
	cam_allow = [1, 1, 1, 1]
	
	#Set lives counter.
	$hud/hud/lives.set_text(str(global.lives))
	
	#Set player position and reset camera.
	for spawn in $coll_mask/spawn_pts.get_used_cells():
		var spawn_id = $coll_mask/spawn_pts.get_cellv(spawn)
		var spawn_type = $coll_mask/spawn_pts.tile_set.tile_get_name(spawn_id)
		if spawn_type in ['sp_'+str(global.level_id)+'_'+str(global.cont_id)]:
			var spawn_pos = $coll_mask/spawn_pts.map_to_world(spawn)
			$player.position.x = spawn_pos.x + $coll_mask/spawn_pts.cell_size.x
			$player.position.y = spawn_pos.y + $coll_mask/spawn_pts.cell_size.y / 2
			
	pos = $player.position
	player_room = Vector2(floor(pos.x / 256), floor(pos.y / 240))

	$player/camera.limit_top = (player_room.y*240)
	$player/camera.limit_bottom = (player_room.y*240)+240
	$player/camera.limit_left = (player_room.x*256)
	$player/camera.limit_right = (player_room.x*256)+256

func _input(event):
	#Weapon Swapping.
	if $player.can_move:
		#L and R Button.
		if Input.is_action_just_pressed("prev"):
			global.player_weap[int($player.swap)] -= 1
			$player.w_icon = 64
		if Input.is_action_just_pressed("next"):
			global.player_weap[int($player.swap)] += 1
			$player.w_icon = 64
		
		#Skip Unacquired Weapons.
		if Input.is_action_just_pressed("next"):
			#Skip Rush/Proto Jet if if playing as Mega/Proto Man and hasn't been acquired. Skip altogether if playing as Bass.
			if global.player_weap[int($player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int($player.swap)] == 2 and global.player == 2:
				global.player_weap[int($player.swap)] += 1
			#Skip unacquired Master Weapons
			if global.player_weap[int($player.swap)] == 3 and !global.weapon1[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 4 and !global.weapon2[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 5 and !global.weapon3[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 6 and !global.weapon4[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 7 and !global.weapon5[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 8 and !global.weapon6[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 9 and !global.weapon7[0]:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 10 and !global.weapon8[0]:
				global.player_weap[int($player.swap)] += 1
			#Skip player specific adaptors.
			if global.player_weap[int($player.swap)] == 11 and !global.beat[0] and global.player == 0:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 11 and !global.tango[0] and global.player == 1:
				global.player_weap[int($player.swap)] += 1
			if global.player_weap[int($player.swap)] == 11 and !global.reggae[0] and global.player == 2:
				global.player_weap[int($player.swap)] += 1
		
		if Input.is_action_just_pressed("prev"):
			#These skips are done in reverse order to make them move to the next item seemlessly.
			if global.player_weap[int($player.swap)] == 11 and !global.beat[0] and global.player == 0:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 11 and !global.tango[0] and global.player == 1:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 11 and !global.reggae[0] and global.player == 2:
				global.player_weap[int($player.swap)] -= 1
			#Master Weapons
			if global.player_weap[int($player.swap)] == 10 and !global.weapon8[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 9 and !global.weapon7[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 8 and !global.weapon6[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 7 and !global.weapon5[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 6 and !global.weapon4[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 5 and !global.weapon3[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 4 and !global.weapon2[0]:
				global.player_weap[int($player.swap)] -= 1
			if global.player_weap[int($player.swap)] == 3 and !global.weapon1[0]:
				global.player_weap[int($player.swap)] -= 1
			#Rush/Proto Jet
			if global.player_weap[int($player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int($player.swap)] == 2 and global.player == 2:
				global.player_weap[int($player.swap)] -= 1
	
		#Loop the value.
		if global.player_weap[int($player.swap)] < 0:
			global.player_weap[int($player.swap)] = 11
		elif global.player_weap[int($player.swap)] > 11:
			global.player_weap[int($player.swap)] = 0
		
		#Start swap process.
		if Input.is_action_just_pressed('select') and !swapping:
			if $player.act_st != 13 and !$player.slide:
				if global.player_life[int(!$player.swap)] != 0:
					$player.w_icon = 0
					$player/sprite/weap_icon_lr.hide()
					$player.hide()
					swapping = true
					swap_out()
					if !$player.swap:
						$player.swap = true
					else:
						$player.swap = false
					swap()
					$pause/pause_menu.menu_color()
					$pause/pause_menu.set_names()
					$pause/pause_menu.wpn_menu()
					swap_in()
					get_tree().paused = true
				else:
					print('CANNOT SWAP. SECOND PLAYER DEAD.')
			
		palette_swap()
	
		#Pause menu
		if Input.is_action_just_pressed('start') and !$pause/pause_menu.start and !swapping:
			$fade/fade.state = 6
			$fade/fade.end = true
			$player.can_move = false
			get_tree().paused = true
	
	else:
		#Return to the game.
		if Input.is_action_just_pressed('start') and $pause/pause_menu.start:
			$fade/fade.state = 8
			$fade/fade.end = true
			$pause/pause_menu.start = false
		
	
func _camera():
	#Calculate player position.
	pos = $player.position
	pos = Vector2(floor(pos.x), floor(pos.y))
	
	#Get Center of the screen.
	center = $player/camera.get_camera_screen_center()
	center = Vector2(floor(center.x), floor(center.y))
	
	#Scroll up (Edge of screen)
	if pos.y < $player/camera.limit_top and cam_allow[0] == 1 and !scroll:
		scroll = true
		scroll_len = -res.y
		cam_move = 1
		kill_effects()
		emit_signal("scrolling")
	
	#Scroll down (Edge of screen)
	if pos.y > $player/camera.limit_bottom and cam_allow[1] == 1 and !scroll:
		scroll = true
		scroll_len = res.y
		cam_move = 2
		kill_effects()
		emit_signal("scrolling")
	
	#Scroll left (Edge of screen)
	if pos.x < $player/camera.limit_left + 8 and cam_allow[2] == 1 and !scroll:
		$player/camera.limit_left = center.x - (res.x / 2)
		$player/camera.limit_right = center.x + (res.x / 2)
		scroll = true
		scroll_len = -res.x
		cam_move = 3
		kill_effects()
		emit_signal("scrolling")
	
	#Scroll right (Edge of screen)
	if pos.x > $player/camera.limit_right - 8 and cam_allow[3] == 1 and !scroll:
		$player/camera.limit_left = center.x - (res.x / 2)
		$player/camera.limit_right = center.x + (res.x / 2)
		scroll = true
		scroll_len = res.x
		cam_move = 4
		kill_effects()
		emit_signal("scrolling")
	
	#Pan the camera
	if cam_move == 1 and scroll_len != 0:
		$player/camera.limit_top -= scroll_spd
		$player/camera.limit_bottom -= scroll_spd
		if !$player.gate:
			$player.position.y -= 0.125
		else:
			$player.position.y -= 0.9
		scroll_len += scroll_spd
	if cam_move == 2 and scroll_len != 0:
		$player/camera.limit_top += scroll_spd
		$player/camera.limit_bottom += scroll_spd
		if !$player.gate:
			$player.position.y += 0.125
		else:
			$player.position.y += 0.9
		scroll_len -= scroll_spd
	if cam_move == 3 and scroll_len != 0:
		$player/camera.limit_left -= scroll_spd
		$player/camera.limit_right -= scroll_spd
		if !$player.gate:
			$player.position.x -= 0.5
		else:
			$player.position.x -= 0.75
		scroll_len += scroll_spd
	if cam_move == 4 and scroll_len != 0:
		$player/camera.limit_left += scroll_spd
		$player/camera.limit_right += scroll_spd
		if !$player.gate:
			$player.position.x += 0.5
		else:
			$player.position.x += 0.75
		scroll_len -= scroll_spd
	
	#Resume Control
	if cam_move != 0 and scroll_len == 0:
		if !$player.gate:
			scroll = false
			cam_move = 0
			emit_signal("scrolling")
		else:
			emit_signal("close_gate")
	
	#Check room to see if camera value changes. This will only check rooms when the game is
	#not performing a screen transition.
	if prev_room != player_room and !scroll:
		prev_room = player_room
		_rooms()
		
#	Certain special conditions for allowing camera movement can be allowed as well. Such as player position within a room.
#	if $player.position.y < ($player/camera.limit_bottom - 120) and player_room == Vector2(7, 10) and !scroll:
#		_rooms()
#
#	if $player.position.y > ($player/camera.limit_bottom - 120) and player_room == Vector2(7, 10) and !scroll:
#		_rooms()

func _rooms():
	#This section handles the Left/Right camera limits and toggles which direction the screen
	#is allowed to scroll based on the player_room value.
	print(player_room)
	
	#This function also houses the counter for Endless Mode.
	if endless:
		if !endless_rms.has(player_room):
			endless_rms.insert(endless_rms.size(), player_room)
			screens += 1
	
	#Add function here to clear endless_rms to prevent lag. (Example: When the player reaches a teleporter, clear endless_rms)
	
	#Example
	#Water test area.
	if player_room == Vector2(8, 10):
		rooms = 5
		cam_allow[0] = 0
		cam_allow[1] = 0
		cam_allow[2] = 0		#Don't forget this snippet.
		$player/camera.limit_right = $player/camera.limit_left + (res.x * rooms)
	
	#Allow the player to fall after reaching a certain point.
	if player_room == Vector2(12, 10):
		cam_allow[1] = 1
	
	#Save for rooms with no horizontal scrolling.
	if player_room == Vector2(12, 11):
		rooms = 1
		$player/camera.limit_left = $player/camera.limit_right - (res.x * rooms)
	
	if player_room == Vector2(12, 15):
		rooms = 2
		$player/camera.limit_right = $player/camera.limit_left + (res.x * rooms)
	
	#Snow/Ice Test Area
	if player_room == Vector2(9, 6):
		rooms = 6
		cam_allow[1] = 0
		$player/camera.limit_right = $player/camera.limit_left + (res.x * rooms)
	
	if player_room == Vector2(14, 6):
		cam_allow[1] = 0
	
	if player_room == Vector2(14, 5) and cam_allow[1] != 1:
		rooms = 1
		cam_allow[1] = 1
		$player/camera.limit_left = $player/camera.limit_right - (res.x * rooms)
	
	if player_room == Vector2(14, 4):
		rooms = 6
		cam_allow[1] = 1
		$player/camera.limit_right = $player/camera.limit_left + (res.x * rooms)
	
	if player_room == Vector2(15, 4):
		cam_allow[1] = 0
	
	if player_room == Vector2(19, 3):
		rooms = 1
		cam_allow[1] = 1
		$player/camera.limit_left = $player/camera.limit_right - (res.x * rooms)
	
	if player_room == Vector2(19, 4):
		rooms = 6
		cam_allow[1] = 1
		$player/camera.limit_left = $player/camera.limit_right - (res.x * rooms)
	
	if player_room == Vector2(20, 0):
		cam_allow[2] = 0

	
	#Save for rooms that scroll to the left.
#	if player_room == Vector2(1, 8):
#		rooms = 1
#		$player/camera.limit_left = $player/camera.limit_right - (res.x * rooms)
	
	#Special camera condition. Will prevent horizontal scrolling while the player is on the top half of the screen at the beginning of this section.
#	if player_room == Vector2(7, 10):
#		cam_allow[1] = 0
#		if $player.position.y < ($player/camera.limit_bottom - 120):
#			rooms = 1
#			$player/camera.limit_left = player_room.x * 256
#			$player/camera.limit_right = (player_room.x + 1) * 256
#		else:
#			rooms = 8
#			$player/camera.limit_left = player_room.x * 256
#			$player/camera.limit_right = $player/camera.limit_left + (res.x * rooms)
#
#	if player_room == Vector2(15, 10) and cam_allow[2] != 0:
#		cam_allow[2] = 0
	
	#Eventually, this function will encompass every room in the game. But only triggers at certain
	#intervals as to not bog down RAM usage. IE: When the room value is different from the previous
	#value.
	
#warning-ignore:unused_argument
func _process(delta):
	_camera()
	#Print Shit
	
	
	#Get other player information.
	player_tilepos = $coll_mask/tiles.world_to_map(pos)
	stand_on = $coll_mask/tiles.get_cellv(Vector2(player_tilepos.x, player_tilepos.y + 1))
	overlap = $coll_mask/tiles.get_cellv(player_tilepos)
	ladder_set = (player_tilepos.x * 16) + 8
	ladder_top = $coll_mask/tiles.map_to_world(player_tilepos)
	player_room = Vector2(floor(pos.x / 256), floor(pos.y / 240))
	spawn_pt = $coll_mask/spawn_pts.get_cellv($coll_mask/spawn_pts.world_to_map(Vector2(pos.x - 4, pos.y)))
	
	#If the player is dead, run the kill script.
	if $player.position.y > $player/camera.limit_bottom + 24 and !dead:
		global.player_life[0] = 0
		global.player_life[1] = 0
		dead = true
		$player.can_move = false
		get_tree().paused = true
		$player.hide()
	
	if dead and dead_delay > 0:
		dead_delay -= 1
	
	if dead and dead_delay == 0:
		if $player.is_visible():
			$player.hide()
			for n in range(16):
				var boom = DEATH_BOOM.instance()
				boom.position = $player.position
				boom.id = n
				$overlap.add_child(boom)
		get_tree().paused = false
			
	if dead and dead_delay == 0 and restart > -1:
		restart -= 1
	
	if dead and dead_delay == 0 and restart == 0:
		if !$fade/fade.end:
			$fade/fade.state = 4
			$fade/fade.end = true
		
	#Skip Unacquired Weapons.
	if last_dir == 1:
		#Skip Rush/Proto Jet if if playing as Mega/Proto Man and hasn't been acquired. Skip altogether if playing as Bass.
		if global.player_weap[int($player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int($player.swap)] == 2 and global.player == 2:
			global.player_weap[int($player.swap)] += 1
		#Skip unacquired Master Weapons
		if global.player_weap[int($player.swap)] == 3 and !global.weapon1[0]:
			global.player_weap[int($player.swap)] += 1
		if global.player_weap[int($player.swap)] == 4 and !global.weapon2[0]:
			global.player_weap[int($player.swap)] += 1
		if global.player_weap[int($player.swap)] == 5 and !global.weapon3[0]:
			global.player_weap[int($player.swap)] += 1
		if global.player_weap[int($player.swap)] == 6 and !global.weapon4[0]:
			global.player_weap[int($player.swap)] += 1
		if global.player_weap[int($player.swap)] == 7 and !global.weapon5[0]:
			global.player_weap[int($player.swap)] += 1
		if global.player_weap[int($player.swap)] == 8 and !global.weapon6[0]:
			global.player_weap[int($player.swap)] += 1
		if global.player_weap[int($player.swap)] == 9 and !global.weapon7[0]:
			global.player_weap[int($player.swap)] += 1
		if global.player_weap[int($player.swap)] == 10 and !global.weapon8[0]:
			global.player_weap[int($player.swap)] += 1
		#Skip player specific adaptors.
		if global.player_weap[int($player.swap)] == 11 and !global.beat[0] and global.player == 0:
			global.player_weap[int($player.swap)] += 1
		if global.player_weap[int($player.swap)] == 11 and !global.tango[0] and global.player == 1:
			global.player_weap[int($player.swap)] += 1
		if global.player_weap[int($player.swap)] == 11 and !global.reggae[0] and global.player == 2:
			global.player_weap[int($player.swap)] += 1
	
	elif last_dir == -1:
		#These skips are done in reverse order to make them move to the next item seemlessly.
		if global.player_weap[int($player.swap)] == 11 and !global.beat[0] and global.player == 0:
			global.player_weap[int($player.swap)] -= 1
		if global.player_weap[int($player.swap)] == 11 and !global.tango[0] and global.player == 1:
			global.player_weap[int($player.swap)] -= 1
		if global.player_weap[int($player.swap)] == 11 and !global.reggae[0] and global.player == 2:
			global.player_weap[int($player.swap)] -= 1
		#Master Weapons
		if global.player_weap[int($player.swap)] == 10 and !global.weapon8[0]:
			global.player_weap[int($player.swap)] -= 1
		if global.player_weap[int($player.swap)] == 9 and !global.weapon7[0]:
			global.player_weap[int($player.swap)] -= 1
		if global.player_weap[int($player.swap)] == 8 and !global.weapon6[0]:
			global.player_weap[int($player.swap)] -= 1
		if global.player_weap[int($player.swap)] == 7 and !global.weapon5[0]:
			global.player_weap[int($player.swap)] -= 1
		if global.player_weap[int($player.swap)] == 6 and !global.weapon4[0]:
			global.player_weap[int($player.swap)] -= 1
		if global.player_weap[int($player.swap)] == 5 and !global.weapon3[0]:
			global.player_weap[int($player.swap)] -= 1
		if global.player_weap[int($player.swap)] == 4 and !global.weapon2[0]:
			global.player_weap[int($player.swap)] -= 1
		if global.player_weap[int($player.swap)] == 3 and !global.weapon1[0]:
			global.player_weap[int($player.swap)] -= 1
		#Rush/Proto Jet
		if global.player_weap[int($player.swap)] == 2 and !global.rp_jet[0] or global.player_weap[int($player.swap)] == 2 and global.player == 2:
			global.player_weap[int($player.swap)] -= 1

	#Loop the value.
	if global.player_weap[int($player.swap)] < 0:
		global.player_weap[int($player.swap)] = 11
	elif global.player_weap[int($player.swap)] > 11:
		global.player_weap[int($player.swap)] = 0
	
	if last_weap != global.player_weap[int($player.swap)]:
		last_weap = global.player_weap[int($player.swap)]
		palette_swap()
	
	#Right Analog Stick
	
	#Teleporters
	if spawn_pt != -1 and $player.is_on_floor():
		if spawn_pt >= 49 and spawn_pt <= 68 and !$player.lock_ctrl:
			$player.lock_ctrl = true
			$player.anim_state(2)
			$player.slide = false
			$player.slide_timer = 0
			tele_timer = 60
			tele_dest = spawn_pt + 20
	
	if $player.lock_ctrl and tele_timer > -1:
		tele_timer -= 1
	
	if tele_timer == 0:
		$player.can_move = false
		$player/anim.play('appear1')
			
	
	#Special Effects
	if overlap == 7 and !spl_trigger:
		splash()
		spl_trigger = true
	elif overlap != 7 and spl_trigger:
		spl_trigger = false
		
	if overlap == 6 or overlap == 12 or overlap == 13:
		if bbl_count == 0 and !scroll:
			bubble()
		
	
	#Debug Menus and Statistics.
	
	#Debug Menu
	if Input.is_key_pressed(KEY_F1) and global.debug_menu == 0:
		global.debug_menu += 1
		get_tree().paused = true
		$debug_menu/menu.show()
	if !Input.is_key_pressed(KEY_F1) and global.debug_menu == 1:
		global.debug_menu += 1
	if Input.is_key_pressed(KEY_F1) and global.debug_menu == 2:
		global.debug_menu += 1
		get_tree().paused = false
		$debug_menu/menu.hide()
	if !Input.is_key_pressed(KEY_F1) and global.debug_menu == 3:
		global.debug_menu = 0
	
	#Debug stats
	if Input.is_key_pressed(KEY_F2) and global.debug_stats == 0:
		global.debug_stats += 1
		get_tree().paused = true
		$debug_stats/debug.show()
	if !Input.is_key_pressed(KEY_F2) and global.debug_stats == 1:
		global.debug_stats += 1
	if Input.is_key_pressed(KEY_F2) and global.debug_stats == 2:
		global.debug_stats += 1
		get_tree().paused = false
		$debug_stats/debug.hide()
	if !Input.is_key_pressed(KEY_F2) and global.debug_stats == 3:
		global.debug_stats = 0
	
	#Debug Stats
	if global.debug_stats == 1:
#		#Debug Information.
#		$debug1/posx.set_text(str(pos.x))				#Player X Position
#		$debug1/posy.set_text(str(pos.y))				#Player Y Position
#		$debug1/tpos.set_text(str(player_tilepos))		#Tile that the player is occupying
#		$debug1/room.set_text(str(player_room))			#Room that the player is occupying
#		$debug1/cam_allow.set_text(str(cam_allow))		#Which way the camera can pan, if at all.
#		$debug1/state.set_text(str($player.state))		#Which state the player is in.
#		$debug1/anim.set_text(str($player.anim))		#Which animation is playing.
#		$debug1/anim.set_uppercase(true)				#Set anim text to uppercase.
#
#		if stand_on == -1:								#Tile ID that the player is standing on.
#			$debug1/stand_on.set_text('NULL')
#		if stand_on == 0:
#			$debug1/stand_on.set_text('FLOOR')
#		if stand_on == 1:
#			$debug1/stand_on.set_text('SNOW')
#		if stand_on == 2:
#			$debug1/stand_on.set_text('ICE')
#		if stand_on == 3:
#			$debug1/stand_on.set_text('LADDER')
#		if stand_on == 5:
#			$debug1/stand_on.set_text('DEATH')
#		if stand_on == 6 or stand_on == 7:
#			$debug1/stand_on.set_text('WATER')
#		if stand_on == 8:
#			$debug1/stand_on.set_text('SLW R CONV')
#		if stand_on == 9:
#			$debug1/stand_on.set_text('FST R CONV')
#		if stand_on == 10:
#			$debug1/stand_on.set_text('SLW L CONV')
#		if stand_on == 11:
#			$debug1/stand_on.set_text('FST L CONV')
#
#		if overlap == -1:								#Tile the player is overlapping. Add to for new tiles.
#			$debug1/overlap.set_text('NULL')
#		if overlap == 3:
#			$debug1/overlap.set_text('LADDER')
#		if overlap == 4:
#			$debug1/overlap.set_text('LADDER')
#		if overlap == 6 or overlap == 7:
#			$debug1/overlap.set_text('WATER')
#
#		$debug1/ladder_set.set_text(str(ladder_set))	#X coordinate of where the player will be snapped to when grabbing a ladder.
#		$debug1/xvelocity.set_text(str(floor($player.velocity.x)))
#		$debug1/yvelocity.set_text(str(floor($player.velocity.y)))
#		$debug1/act_state.set_text(str($player.act_state))
#		$debug1/act_state.set_uppercase(true)
#		$debug1/collide.set_text(str($player.tile_name))
#		$debug1/collide.set_uppercase(true)
		
		$debug_stats/debug/fps.set_text(str(Engine.get_frames_per_second()))#Display frames per second.


#These functions handle the states of the fade in node.
func _on_fade_fadein():
	
	if $fade/fade.state == 3 and $player.lock_ctrl:
		$player/anim.stop(true)
		$player.show()
		$player/anim.play('appear1')
		$player.lock_ctrl = false
	
	if $fade/fade.state == 7:
		$pause/pause_menu.start = true
	
	if $fade/fade.state == 9:
		get_tree().paused = false
		$player.can_move = true

func _on_fade_fadeout():
	if $fade/fade.state == 2:

		for teleport in $coll_mask/spawn_pts.get_used_cells():
			var tele_id = $coll_mask/spawn_pts.get_cellv(teleport)
			if tele_id == tele_dest:
				var tele_pos = $coll_mask/spawn_pts.map_to_world(teleport)
			
				$player.position.x = tele_pos.x + $coll_mask/spawn_pts.cell_size.x
				$player.position.y = tele_pos.y + $coll_mask/spawn_pts.cell_size.y / 2

		$player/camera.limit_top = ((floor($player.position.y/240))*240)
		$player/camera.limit_bottom = ((floor($player.position.y/240))*240)+240
		$player/camera.limit_left = ((floor($player.position.x/256))*256)
		$player/camera.limit_right = ((floor($player.position.x/256))*256)+256

		$fade/fade.begin = true
		$fade/fade.state = 3
	
	if $fade/fade.state == 4:
		if global.lives > 0:
			global.player_life[0] = 280
			global.player_life[1] = 280
			global.player_weap[0] = 0
			global.player_weap[1] = 0
			global.lives -= 1
			get_tree().reload_current_scene()
		else:
			get_tree().quit()
	
	if $fade/fade.state == 6:
		$pause/pause_menu.show()
		$fade/fade.begin = true
		$fade/fade.state = 7
	
	if $fade/fade.state == 8:
		$pause/pause_menu.hide()
		$fade/fade.begin = true
		$fade/fade.state = 9

func palette_swap():
	#Set palettes for the player.
	#Character specific palettes.
	#Mega Man
	if global.player == 0:
		#Default palette
		if global.player_weap[int($player.swap)] == 0 or global.player_weap[int($player.swap)] == 11:
			if $player.charge == 0:
				palette[0] = global.black
				palette[1] = global.blue2
				palette[2] = global.blue1
		
			#Charge 1
			if $player.charge >= 32 and $player.charge < 96 and $player.c_flash == 0:
				palette[0] = global.black
			if $player.charge >= 32 and $player.charge < 48 and $player.c_flash == 2:
				palette[0] = global.pink3
			if $player.charge >= 48 and $player.charge < 64 and $player.c_flash == 2:
				palette[0] = global.pink2
			if $player.charge >= 64 and $player.charge < 96 and $player.c_flash == 2:
				palette[0] = global.pink1
				
			#Charge 2
			if $player.charge >= 96 and $player.c_flash == 0:
				palette[0] = global.black
				palette[1] = global.blue2
				palette[2] = global.blue1
			if $player.charge >= 96 and $player.c_flash == 2:
				palette[0] = global.blue2
				palette[1] = global.blue1
				palette[2] = global.black
			if $player.charge >= 96 and $player.c_flash == 4:
				palette[0] = global.blue1
				palette[1] = global.black
				palette[2] = global.blue2
			if $player.charge >= 96 and $player.c_flash == 6:
				palette[1] = global.grey0
	
	#Proto Man
	if global.player == 1:
		if global.player_weap[int($player.swap)] == 0:
			if $player.charge == 0:
				palette[0] = global.black
				palette[1] = global.red3
				palette[2] = global.grey1
		
			#Charge 1
			if $player.charge >= 32 and $player.charge < 96 and $player.c_flash == 0:
				palette[0] = global.black
			if $player.charge >= 32 and $player.charge < 48 and $player.c_flash == 2:
				palette[0] = global.purple3
			if $player.charge >= 48 and $player.charge < 64 and $player.c_flash == 2:
				palette[0] = global.purple2
			if $player.charge >= 64 and $player.charge < 96 and $player.c_flash == 2:
				palette[0] = global.purple1
				
			#Charge 2
			if $player.charge >= 96 and $player.c_flash == 0:
				palette[0] = global.black
				palette[1] = global.red3
				palette[2] = global.grey1
			if $player.charge >= 96 and $player.c_flash == 2:
				palette[0] = global.red3
				palette[1] = global.grey1
				palette[2] = global.black
			if $player.charge >= 96 and $player.c_flash == 4:
				palette[0] = global.grey1
				palette[1] = global.black
				palette[2] = global.red3
			if $player.charge >= 96 and $player.c_flash == 6:
				palette[1] = global.yellow0
		
		if global.player_weap[int($player.swap)] == 11:
			palette[0] = global.black
			palette[1] = global.green1
			palette[2] = global.blue0
			
	#Bass
	if global.player == 2:
		if global.player_weap[int($player.swap)] == 0:
			palette[0] = global.black
			palette[1] = global.grey2
			palette[2] = global.brown1
		if global.player_weap[int($player.swap)] == 1:
			palette[0] = global.black
			palette[1] = global.grey2
			palette[2] = global.purple2
		if global.player_weap[int($player.swap)] == 11:
			palette[0] = global.black
			palette[1] = global.pink1
			palette[2] = global.yellow0
	
	#Shared Palettes.
	#Rush/Proto Jet.
	if global.player != 2:
		if global.player_weap[int($player.swap)] == 1 or global.player_weap[int($player.swap)] == 2:
			palette[0] = global.black
			palette[1] = global.red3
			palette[2] = global.white
	
	#Master Weapons.
	if global.player_weap[int($player.swap)] == 3:
		palette[0] = global.black
		palette[1] = global.red3
		palette[2] = global.yellow2
	if global.player_weap[int($player.swap)] == 4:
		palette[0] = global.black
		palette[1] = global.blue3
		palette[2] = global.grey2
	if global.player_weap[int($player.swap)] == 5:
		palette[0] = global.black
		palette[1] = global.green3
		palette[2] = global.lime1
	if global.player_weap[int($player.swap)] == 6:
		palette[0] = global.black
		palette[1] = global.grey3
		palette[2] = global.grey0
	if global.player_weap[int($player.swap)] == 7:
		palette[0] = global.black
		palette[1] = global.purple3
		palette[2] = global.purple1
	if global.player_weap[int($player.swap)] == 8:
		palette[0] = global.black
		palette[1] = global.grey2
		palette[2] = global.yellow1
	if global.player_weap[int($player.swap)] == 9:
		palette[0] = global.black
		palette[1] = global.pink2
		palette[2] = global.white
	if global.player_weap[int($player.swap)] == 10:
		palette[0] = global.black
		palette[1] = global.rblue2
		palette[2] = global.yellow0
	
	#Set weapon icon.
	if global.player_weap[int($player.swap)] == 0:
		if global.player != 2:
			$player/sprite/weap_icon_lr.set_frame(0)
		else:
			$player/sprite/weap_icon_lr.set_frame(1)
	if global.player_weap[int($player.swap)] == 1:
		if global.player == 0:
			$player/sprite/weap_icon_lr.set_frame(2)
		elif global.player == 1:
			$player/sprite/weap_icon_lr.set_frame(4)
		elif global.player == 2:
			$player/sprite/weap_icon_lr.set_frame(6)
	if global.player_weap[int($player.swap)] == 2:
		if global.player == 0:
			$player/sprite/weap_icon_lr.set_frame(3)
		elif global.player == 1:
			$player/sprite/weap_icon_lr.set_frame(5)
	if global.player_weap[int($player.swap)] == 3:
		$player/sprite/weap_icon_lr.set_frame(7)
	if global.player_weap[int($player.swap)] == 4:
		$player/sprite/weap_icon_lr.set_frame(8)
	if global.player_weap[int($player.swap)] == 5:
		$player/sprite/weap_icon_lr.set_frame(9)
	if global.player_weap[int($player.swap)] == 6:
		$player/sprite/weap_icon_lr.set_frame(10)
	if global.player_weap[int($player.swap)] == 7:
		$player/sprite/weap_icon_lr.set_frame(11)
	if global.player_weap[int($player.swap)] == 8:
		$player/sprite/weap_icon_lr.set_frame(12)
	if global.player_weap[int($player.swap)] == 9:
		$player/sprite/weap_icon_lr.set_frame(13)
	if global.player_weap[int($player.swap)] == 10:
		$player/sprite/weap_icon_lr.set_frame(14)
	if global.player_weap[int($player.swap)] == 11:
		if global.player == 0:
			$player/sprite/weap_icon_lr.set_frame(15)
		elif global.player == 1:
			$player/sprite/weap_icon_lr.set_frame(16)
		elif global.player == 2:
			$player/sprite/weap_icon_lr.set_frame(17)
	
			
	#Set Colors
	#Player Sprites
	$player/sprite.material.set_shader_param('r_col1', palette[0])
	$player/sprite.material.set_shader_param('r_col2', palette[1])
	$player/sprite.material.set_shader_param('r_col3', palette[2])
	
	#HUD
	$hud/hud/weap.material.set_shader_param('r_col2', palette[1])
	$hud/hud/weap.material.set_shader_param('r_col3', palette[2])
	
	#Items
	
func spawn_objects():
	#Scan tilemap for objects.
	for cell in objects.get_used_cells():
		var id = objects.get_cellv(cell)
		var type = objects.tile_set.tile_get_name(id)
		#Get object ID and load into the level.
		if type in ['vert_gate', 'horiz_gate']:
			var c = load('res://scenes/objects/'+type+'.tscn').instance()
			var pos = objects.map_to_world(cell)
			c.position = pos + (objects.cell_size / 2)
			$graphic.add_child(c)

func splash():
	if !dead:
		var splash = load('res://scenes/effects/splash.tscn').instance()
		$overlap.add_child(splash)
		splash.position.x = $player.position.x
		splash.position.y = $coll_mask/tiles.map_to_world(player_tilepos).y - 2

func bubble():
	if !dead:
		var bubble = load('res://scenes/effects/bubble.tscn').instance()
		$overlap.add_child(bubble)
		bubble.position = $player.position
		bbl_count += 1

func swap_out():
	#Spawn the leaving sprite.
	var out = load('res://scenes/player/other/plyr_out.tscn').instance()
	$overlap.add_child(out)
	out.position = $player.position

func swap_in():
	#Spawn the inbound sprite.
	var p_in = load('res://scenes/player/other/plyr_in.tscn').instance()
	$overlap.add_child(p_in)
	p_in.position.x = $player.position.x
	p_in.position.y = $player.position.y - 240

func kill_effects():
	#Use this to kill special effect sprites when scrolling.
	var effects = get_tree().get_nodes_in_group('effects')
	for bubble in effects:
		bubble.queue_free()
	for splash in effects:
		splash.queue_free()
	bbl_count = 0

func _on_teleport():
	if tele_timer <= 0:
		$player.hide()
		$fade/fade.state = 2
		$fade/fade.end = true

func swap():
	if global.player != global.player_id[int($player.swap)]:
		global.player = global.player_id[int($player.swap)]
		$player.change_char()
		palette_swap()