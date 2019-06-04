extends Node2D

signal scrolling

var fade_state

#Determines player position in the game world.
var pos = Vector2()
var player_tilepos = Vector2()
var stand_on
var overlap
var ladder_set
var ladder_top
var player_room = Vector2()

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

#Color Variables.
var palette = [Color('#000000'), Color('#000000'), Color('#000000')]

#Weapon Swapping variables.
var left = false
var right = false
var last_dir = 0
var last_weap = 0

func _ready():
	res = get_viewport_rect().size
	#Add Continue and Spawn Scripts here
	cam_allow = [1, 1, 1, 1]
	
	#Based on where the playr spawns, set position and change camera.
	if global.level_id == 0 and global.cont_id == 0:
		$player.position = Vector2(72, 148)
		
	if global.level_id == 0 and global.cont_id == 1:
		$player.position = Vector2(632, 196)

	pos = $player.position
	player_room = Vector2(floor((pos.x / 256)+1), floor((pos.y / 240))+1)

	$player/camera.limit_top = (player_room.y*240)-240
	$player/camera.limit_right = (player_room.y*240)
	$player/camera.limit_left = (player_room.x*256)-256
	$player/camera.limit_right = (player_room.x*256)
	
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
		emit_signal("scrolling")
	
	#Scroll down (Edge of screen)
	if pos.y > $player/camera.limit_bottom and cam_allow[1] == 1 and !scroll:
		scroll = true
		scroll_len = res.y
		cam_move = 2
		emit_signal("scrolling")
	
	#Scroll left (Edge of screen)
	if pos.x < $player/camera.limit_left + 8 and cam_allow[2] == 1 and !scroll:
		$player/camera.limit_left = center.x - (res.x / 2)
		$player/camera.limit_right = center.x + (res.x / 2)
		scroll = true
		scroll_len = -res.x
		cam_move = 3
		emit_signal("scrolling")
	
	#Scroll right (Edge of screen)
	if pos.x > $player/camera.limit_right - 8 and cam_allow[3] == 1 and !scroll:
		$player/camera.limit_left = center.x - (res.x / 2)
		$player/camera.limit_right = center.x + (res.x / 2)
		scroll = true
		scroll_len = res.x
		cam_move = 4
		emit_signal("scrolling")
	
	#Scroll up (Boss Gate)
	#Scroll down (Boss Gate)
	#Scroll left (Boss Gate)
	#Scroll right (Boss Gate)
	
	#Pan the camera
	if cam_move == 1 and scroll_len != 0:
		$player/camera.limit_top -= scroll_spd
		$player/camera.limit_bottom -= scroll_spd
		$player.position.y -= 0.25
		scroll_len += scroll_spd
	if cam_move == 2 and scroll_len != 0:
		$player/camera.limit_top += scroll_spd
		$player/camera.limit_bottom += scroll_spd
		$player.position.y += 0.25
		scroll_len -= scroll_spd
	if cam_move == 3 and scroll_len != 0:
		$player/camera.limit_left -= scroll_spd
		$player/camera.limit_right -= scroll_spd
		$player.position.x -= 0.5
		scroll_len += scroll_spd
	if cam_move == 4 and scroll_len != 0:
		$player/camera.limit_left += scroll_spd
		$player/camera.limit_right += scroll_spd
		$player.position.x += 0.5
		scroll_len -= scroll_spd
	
	#Resume Control
	if cam_move != 0 and scroll_len == 0:
		scroll = false
		cam_move = 0
		emit_signal("scrolling")
	
	#Check room to see if camera value changes. This will only check rooms when the game is
	#not performing a screen transition.
	if prev_room != player_room and !scroll:
		_rooms()
		prev_room = player_room

func _rooms():
	#This section handles the Left/Right camera limits and toggles which direction the screen
	#is allowed to scroll based on the player_room value.
	
	#Example
	if player_room == Vector2(2, 0):
		rooms = 4
#		cam_allow[0] = 1		#Commented out so that it's not forgotten.
		$player/camera.limit_right = $player/camera.limit_left + (res.x * rooms)
	
	if player_room == Vector2(1, 3):
		rooms = 3
		$player/camera.limit_right = $player/camera.limit_left + (res.x * rooms)
	
	#Eventually, this function will encompass every room in the game. But only triggers at certain
	#intervals as to not bog down RAM usage. IE: When the room value is different from the previous
	#value.
	
#warning-ignore:unused_argument
func _process(delta):
	_camera()
	
	#Get other player information.
	player_tilepos = $tiles.world_to_map(pos)
	stand_on = $tiles.get_cellv(Vector2(player_tilepos.x, player_tilepos.y + 1))
	overlap = $tiles.get_cellv(player_tilepos)
	ladder_set = (player_tilepos.x * 16) + 8
	ladder_top = $tiles.map_to_world(player_tilepos)
	player_room = Vector2(floor(pos.x / 256), floor(pos.y / 240))
	
	#Weapon Swapping.
	if $player.can_move:
		left = Input.is_action_just_pressed("prev")
		right = Input.is_action_just_pressed("next")
		if left or right:
			last_dir = int(right)-int(left)
	
	#L and R Button.
	if left:
		global.player_weap[int($player.swap)] -= 1
		$player.w_icon = 64
	elif right:
		global.player_weap[int($player.swap)] += 1
		$player.w_icon = 64
		
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
	if $fade/fade.state == 0:
		print("Stage Start!")

func _on_fade_fadeout():
	pass # Replace with function body.

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
		palette[1] = global.turq3
		palette[2] = global.blue0
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
	
	#Items