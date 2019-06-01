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