extends KinematicBody2D

signal teleport

#Use this to pull values from the World script.
onready var world = get_parent()
onready var wpn_layer = world.get_child(3)
onready var camera = self.get_child(9)
#Use this to get TileMap data.
onready var tiles = world.get_child(0).get_child(1)

#Set special effect animations to object layer.
onready var effect = world.get_child(3)

#Player velocity constants
const RUN_SPEED = 90
const JUMP_SPEED = -310
const GRAVITY = 900

#Player special effect constants.
const DMG_SPARK = preload('res://scenes/effects/dmg_spark.tscn')
const SLIDE_SMOKE = preload('res://scenes/effects/slide_smoke.tscn')

#Determines if the player can move or not.
var start_stage = false
var can_move = false
var lock_ctrl = false
var gate = false

#Handles the direction behing held on the D-Pad/Analog stick.
var x_dir = 0
var y_dir = 0
var left_tap
var right_tap
var jump
var jump_tap
var dash
var dash_tap
var fire = false

#Velocity and Position
var x_speed
var x_spd_mod = 1
var ice = false
var conveyor = 0
var grav_mod = 1
var velocity = Vector2()
var shot_dir = 1

#Animation and FSM
var play_anim = ''
var anim_st
var act_st
var shot_st
var player = ''
var texture = ''
var final_tex = ''

#Miscellaneous variables
var force_idle = true
var jumps = 1
var slide_timer = 0
var slide_act = 0
var slide_delay = 0
var slide_tap_dir
var slide_top = false
var wall = false
var slide = false
var shot_rapid = 0
var shot_delay = 0
var bass_dir = ''
var swap = false
var tile_pos = Vector2()
var stand_on
var overlap
var ladder_set
var ladder_top = 0
var ladder_dir = 0
var lad_top_detect
var lad_top_overlap
var hurt_timer = 0
var blink_timer = 0
var blink = 0
var hurt_swap = false
var charge = 0
var chrg_lvl = 0
var c_flash = 0
var w_icon = 0
var rush_coil = false
var rush_jet = false
var snap = Vector2()
var max_en = 0
var wpn_id
var wpn_lvl = []
var get_lvl = []

var key = ''

var s_frame = {
	'0-4' : Vector2(16, 0),
	'0-5' : Vector2(16, 0),
	'0-6' : Vector2(16, 0),
	'0-7' : Vector2(14, 1),
	'0-8' : Vector2(14, 0),
	'0-9' : Vector2(14, 1),
	'0-10' : Vector2(12, -4),
	'0-11' : Vector2(12, -4),
	'0-12' : Vector2(12, -4),
	'0-13' : Vector2(12, -4),
	'1-4' : Vector2(10, 4),
	'1-5' : Vector2(10, 4),
	'1-6' : Vector2(10, 4),
	'1-7' : Vector2(10, 4),
	'1-8' : Vector2(10, 3),
	'1-9' : Vector2(10, 4),
	'1-10' : Vector2(10, 1),
	'1-11' : Vector2(13, 0),
	'1-12' : Vector2(13, 0),
	'1-13' : Vector2(13, 0),
	'2-4' : Vector2(17, 1),
	'2-5' : Vector2(17, 1),
	'2-6' : Vector2(17, 1),
	'2-7' : Vector2(15, 2),
	'2-8' : Vector2(15, 0),
	'2-9' : Vector2(15, 2),
	'2-10' : Vector2(13, -3),
	'2-11' : Vector2(14, -3),
	'2-12' : Vector2(14, -3),
	'2-13' : Vector2(14, -3),
	'2-4-up' : Vector2(4, -9),
	'2-5-up' : Vector2(4, -9),
	'2-6-up' : Vector2(4, -9),
	'2-10-up' : Vector2(5, -12),
	'2-11-up' : Vector2(6, -13),
	'2-12-up' : Vector2(6, -13),
	'2-13-up' : Vector2(6, -13),
	'2-4-d-up' : Vector2(14, -6),
	'2-5-d-up' : Vector2(14, -6),
	'2-6-d-up' : Vector2(14, -6),
	'2-10-d-up' : Vector2(11, -8),
	'2-11-d-up' : Vector2(12, -9),
	'2-12-d-up' : Vector2(12, -9),
	'2-13-d-up' : Vector2(12, -9),
	'2-4-d-down' : Vector2(14, 8),
	'2-5-d-down' : Vector2(14, 8),
	'2-6-d-down' : Vector2(14, 8),
	'2-10-d-down' : Vector2(11, 4),
	'2-11-d-down' : Vector2(12, 4),
	'2-12-d-down' : Vector2(12, 4),
	'2-13-d-down' : Vector2(12, 4)
	}
	
#Weapon Data Table. This will show which weapon will be called and how.
#Key = Player ID + Weapon ID + Min Charge Level + Max Charge Level
#[0] = Shots per shot.
#[1] = Max shots on screen
#[2] = Max adaptors needed before can shoot
#[3] = Energy required to fire, if any, multiplied by 10
#[4] = Shot Sprite Style
#[5] = Adaptor Node to instance
#[6] = Weapon Node to instance
#[7] = Position that adaptor originates
#[8] = Position that shot originates

#[7] Keys:
#0 = shoot_pos position.
#1 = Above the current screen.
#2 = Left/Right sides of screen
#3 = Below the player.
#4 = Center of player.

var wpn_data = {
	'0-0-0-31' : [1, 3, 0, 0, SHOOT, '', load('res://scenes/player/weapons/buster_a.tscn'), 0, 0],		#Mega Man - Level 0 Shot
	'0-0-32-95' : [3, 3, 0, 0, SHOOT, '', load('res://scenes/player/weapons/buster_c.tscn'), 0, 0],	#Mega Man - Level 1 Shot
	'0-0-96-99' : [3, 3, 0, 0, SHOOT, '', load('res://scenes/player/weapons/buster_e.tscn'), 0, 0],	#Mega Man - Level 2 Shot
	'1-0-0-31' : [1, 2, 0, 0, SHOOT, '', load('res://scenes/player/weapons/buster_a.tscn'), 0, 0],		#Proto Man - Level 0 Shot
	'1-0-32-95' : [2, 2, 0, 0, SHOOT, '', load('res://scenes/player/weapons/buster_d.tscn'), 0, 0],	#Proto Man - Level 1 Shot
	'1-0-96-99' : [2, 2, 0, 0, SHOOT, '', load('res://scenes/player/weapons/buster_f.tscn'), 0, 0],	#Proto Man - Level 2 Shot
	'2-0-0-31' : [1, 3, 0, 0, BASSSHOT, '', load('res://scenes/player/weapons/buster_b.tscn'), 0, 0]	#Bass - Normal Shot
	}

#Player States
enum {
	BEAM,
	APPEAR,
	IDLE,
	LILSTEP,
	RUN,
	JUMP,
	SLIDE,
	CLIMB,
	CLIMBTOP,
	HURT,
	FALL,
	DEAD,
	STANDING,
	CLIMBING,
	TBOOST,
	NORMAL,
	SHOOT,
	HAND,
	BASSSHOT,
	THROW
	}

#Set the appropriate states and values
func _ready():
	anim_state(BEAM)
	act_state(STANDING)
	shot_state(NORMAL)
	change_char()
	shot_pos()
	
	#Set appropriate palette
	#Get the colors to be replaced.
	$sprite.material.set_shader_param('t_col1', global.t_color1)
	$sprite.material.set_shader_param('t_col2', global.t_color2)
	$sprite.material.set_shader_param('t_col3', global.t_color3)
	$sprite.material.set_shader_param('t_col4', global.t_color4)
	#Set transparent pixels.
	$sprite.material.set_shader_param('trans', global.trans)
	#Set facial colors
	$sprite.material.set_shader_param('f_col1', global.black)
	$sprite.material.set_shader_param('f_col2', global.yellow0)
	$sprite.material.set_shader_param('f_col3', global.white)
	
	#Set colors
	world.palette_swap()
	
	#Ready Proto Man's whistle if he is the first player.
	if global.player == 1:
		$audio/whistle.play()

func _input(event):
	#Set input directions.
	x_dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	y_dir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	#Set player direction and shot positions.
	if act_st == STANDING:
		if x_dir < 0 and !rush_jet:
			shot_dir = 0
			$sprite.flip_h = true
			$slide_wall.position.x = -7
		elif x_dir > 0 and !rush_jet:
			shot_dir = 1
			$sprite.flip_h = false
			$slide_wall.position.x = 7
		
		if global.player == 2:
			if x_dir == 0 and y_dir == -1:
				bass_dir = '-up'
			elif x_dir != 0 and y_dir == -1:
				bass_dir = '-d-up'
			elif x_dir != 0 and y_dir == 1 or x_dir == 0 and y_dir == 1:
				bass_dir = '-d-down'
			elif x_dir != 0 and y_dir == 0 or x_dir == 0 and y_dir == 0:
				bass_dir = ''
		
		shot_pos()
	
	if act_st == CLIMBING:
		#Change the direction based on if the player is shooting or not.
		if x_dir != 0:
			ladder_dir = x_dir
		
		if ladder_dir == -1:
			shot_dir = 0
		elif ladder_dir == 1:
			shot_dir = 1
	
	if Input.is_action_just_pressed("fire"):
		fire = true
		weapons()
	
	if Input.is_action_just_released("fire"):
		fire = false

func _physics_process(delta):
	
	#Make the inputs easier to handle.
	left_tap = Input.is_action_just_pressed("left")
	right_tap = Input.is_action_just_pressed("right")
	jump = Input.is_action_pressed("jump")
	jump_tap = Input.is_action_just_pressed("jump")
	dash = Input.is_action_pressed("dash")
	dash_tap = Input.is_action_just_pressed("dash")	
	
	#TileMap Data function
	get_data()

	if w_icon > 0:
		if !$sprite/weap_icon_lr.visible:
			$sprite/weap_icon_lr.show()
		w_icon -= 1
	
	if w_icon == 0:
		$sprite/weap_icon_lr.hide()

	if !can_move:
		#Bring the sprite down after READY vanishes.
		#NOTE: This will have to be modified when character swapping is implemented.
		if start_stage and $sprite.offset.y < -1:
			$sprite.offset.y += 8
		elif start_stage and $sprite.offset.y == -1:
			anim_state(APPEAR)
			$audio/appear.play()
			start_stage = false

		if !start_stage and !$anim.is_playing() and anim_st == APPEAR:
			anim_state(IDLE)
			can_move = true
	else:
		if hurt_timer == 0:

			#Make the character blink after taking damage.
			if blink_timer > 0:

				blink += 1

				if blink == 2:
					hide()
				elif blink == 4:
					blink = 0
					show()

				blink_timer -= 1

				if blink_timer == 0:
					show()
					if hurt_swap:
						hurt_swap = false
						world.hurt_swap = false
		
#			#Begin weapon functions.
#			#Busters
#			if slide_timer == 0:
#				if fire_tap and global.player != 2 and global.player_weap[int(swap)] == 0:# or fire_tap and global.player_weap[int(swap)] != 0:
#					if global.player == 0:
#						if world.shots < 3:
#							world.shots += 1
#							weapons()
#					if global.player == 1:
#						if world.shots < 2:
#							world.shots += 1
#							weapons()
#
#				if fire and global.player == 2 and global.player_weap[int(swap)] == 0:
#					shot_delay = 20
#					shot_state(BASSSHOT)
#					shot_pos()
#					shot_rapid += 1
#
#					if shot_rapid == 1:
#						if world.shots < 3:
#							world.shots += 1
#							weapons()
#
#					if shot_rapid >= 6:
#						shot_rapid = 0
#
#				if !fire and global.player == 2 and global.player_weap[int(swap)] == 0:
#					shot_rapid = 0
#
#			#Charge functions. Mega/Proto Man only.	
#			if fire and charge < 99 and global.player_weap[int(swap)] == 0 and global.player != 2:
#				charge += 1
#
#			#Start charge sound loop.
#			if charge == 32:
#				$audio/charge_start.play()
#
#			if charge >= 32:
#				c_flash += 1
#
#			if charge == 96 and !$audio/charge_loop.is_playing():
#				$audio/charge_loop.play()
#
#			if charge < 96 and c_flash > 3:
#				c_flash = 0
#			elif charge >= 96 and c_flash > 7:
#				c_flash = 0
#
#			if global.player_weap[int(swap)] == 0:
#				if charge > 32 and c_flash == 0 or c_flash == 2 or c_flash == 4 or c_flash == 6:
#					world.palette_swap()
#
#				if !fire and charge > 32 and global.player != 2 and global.player_weap[int(swap)] == 0:
#					weapons()
#
#			if !fire and charge > 0:
#				charge = 0
#
#			#Adaptors
#			#Rush Coil/Carry/Treble Boost
#			if global.player == 0 and global.rp_coil[int(swap) + 1] > 0:
#				if fire_tap and global.player_weap[int(swap)] == 1:
#					#Since the player doesn't actually fire Rush, there's no need to swap to the shooting sprites until AFTER he is on screen.
#					if world.shots < 3 and world.adaptors == 1:
#						world.shots += 1
#						weapons()
#					if world.adaptors < 1:
#						weapons()
#						world.adaptors += 1
#
#			#Rush Jet
#			if global.player == 0 and global.rp_jet[0] and global.rp_jet[int(swap) + 1] > 0:
#				if fire_tap and global.player_weap[int(swap)] == 2:
#					if world.shots < 3 and world.adaptors == 1:
#						world.shots += 1
#						weapons()
#					if world.adaptors < 1:
#						weapons()
#						world.adaptors += 1
#
#			#Carry
#			if global.player == 1 and global.rp_coil[int(swap) + 1] > 0:
#				if fire_tap and global.player_weap[int(swap)] == 1:
#					if world.shots < 2 and world.adaptors == 1:
#						world.shots += 1
#						weapons()
#					if world.adaptors < 1:
#						weapons()
#						world.adaptors += 1
#
#			#Treble Boost
#
#			#Beat
#
#			#Tango
#			if global.player == 1 and global.tango[0] and global.rp_jet[int(swap) + 1] > 0:
#				if fire_tap and global.player_weap[int(swap)] == 11:
#					if world.shots < 2 and world.adaptors == 1:
#						world.shots += 1
#						weapons()
#					if world.adaptors < 1:
#						weapons()
#						world.adaptors += 1
#
#			#Reggae
#
#			shot_pos()

			#Charge level.
			if fire and charge < 99:
				charge += 1
			
			if !fire and charge > 0:
				chrg_lvl = charge
				weapons()
				charge = 0

			#Code to revert back to normal sprites.
			if shot_delay > 0:
				#Fix the animations.
				if shot_st == THROW or shot_st == BASSSHOT:
					if is_on_floor() and anim_st != IDLE:
						anim_state(IDLE)

				shot_delay -= 1

			if shot_delay == 0:
				bass_dir = ''
				shot_state(NORMAL)

			#The player's actions are divided into 3 main sections. Standing, Climbing and Sliding.
			if act_st == STANDING:
				
				#Set velocity.x to 0 if not standing on ice.
				if !ice:
					x_speed = 0
				
				#Transition to the little step.
				if x_dir != 0 and shot_st != THROW and shot_st != BASSSHOT and anim_st == IDLE and is_on_floor() and !rush_jet:
					anim_state(LILSTEP)
					if !ice:
						x_speed = (x_dir * RUN_SPEED) / x_spd_mod
				
				#Transition to the running animation.
				if play_anim == 'lilstep' and !$anim.is_playing() and x_dir != 0:
					anim_state(RUN)
				
				#Set X Velocity.
				if !slide:
					if anim_st == RUN and !rush_jet:
						if shot_st != THROW and shot_st != BASSSHOT:
							if !ice:
								x_speed = (x_dir * RUN_SPEED) / x_spd_mod
							else:
								if x_dir == -1 and x_speed > -RUN_SPEED:
									x_speed -= 1
									if x_dir == -1 and x_speed > 0:
										x_speed -= 1
								elif x_dir == 1 and x_speed < RUN_SPEED:
									x_speed += 1
									if x_dir == 1 and x_speed < 0:
										x_speed += 1
					#Prevent the player from running while riding Rush
					if anim_st == RUN and rush_jet:
						anim_state(IDLE)
					if anim_st == IDLE or anim_st == LILSTEP:
						if ice:
							if x_dir == 0 and x_speed > 0:
								x_speed -= 1
							elif x_dir == 0 and x_speed < 0:
								x_speed += 1
					if anim_st == JUMP:
						x_speed = (x_dir * RUN_SPEED) / x_spd_mod
				else:
					if is_on_floor():
						if $sprite.flip_h == true:
							x_speed = (-RUN_SPEED * 2) / x_spd_mod
						else:
							x_speed = (RUN_SPEED * 2) / x_spd_mod
					elif !is_on_floor():
						x_speed = ((x_dir * RUN_SPEED) * 2) / x_spd_mod
						
				#Transition back to idle if no longer running.
				if x_dir == 0 and anim_st == RUN and is_on_floor():
					anim_state(LILSTEP)
				if play_anim == 'lilstep' and !$anim.is_playing() and x_dir == 0:
					anim_state(IDLE)
				
				#Reset the jumps counter. Cancel sliding.
				if !jump and is_on_floor() and jumps == 0 and !slide:
					jumps = 1
					slide = false
					slide_timer = 0
					x_speed = (x_dir * RUN_SPEED) / x_spd_mod
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)
					
				#When the slide timer reaches 0. Cancel slide.
				if slide_timer == 0 and slide and is_on_floor() and !slide_top:
					slide_timer = 0
					if anim_st == JUMP:
						$audio/land.play() #Move to world.gd
					if x_dir == 0:
						anim_state(IDLE)
					else:
						anim_state(RUN)
					if ice:
						if $sprite.flip_h == true:
							x_speed = -RUN_SPEED
						else:
							x_speed = RUN_SPEED
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)
					slide = false
				
				#When the player touches a wall. cancel sliding.
				if slide and is_on_wall() and !slide_top:
					anim_state(IDLE)
					slide_timer = 0
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)
					slide = false
				
				#When the player is no longer on the floor, cancel slide.
				if slide and !is_on_floor() and jumps > 0:
					slide_timer = 0
					anim_state(JUMP)
					jumps = 0
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)
					slide = false
				
				if global.player == 1 and slide and !is_on_floor():
					slide_timer = 0
					jumps = 0
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)
					slide = false
				
				#When the opposite direction is pressed on the ground, cancel slide.
				if slide:
					if !slide_top and $sprite.flip_h == true and x_dir == 1 or !slide_top and $sprite.flip_h == false and x_dir == -1:
						anim_state(IDLE)
						slide_timer = 0
						$standbox.set_disabled(false)
						$slidebox.set_disabled(true)
						slide = false
				
				#Failsafe in case the player gets stuck on the floor.
				if is_on_floor() and !slide and slide_timer <= 0 and anim_st == 6 and !slide_top:
					if x_dir == 0:
						anim_state(IDLE)
					else:
						anim_state(RUN)

				#Change the player's animation based on if they're on the floor or not.
				if !is_on_floor() and anim_st != JUMP and !force_idle:
					anim_state(JUMP)
					jumps = 0
				elif is_on_floor() and anim_st == JUMP and !slide:
					rush_coil = false
					if x_dir == 0:
						anim_state(IDLE)
					else:
						anim_state(RUN)
					$audio/land.play()

				#Make the player jump.
				if global.player == 0 and y_dir != 1 and jump_tap and is_on_floor() and jumps > 0 and !slide_top:
					anim_state(JUMP)
					jumps -= 1
					velocity.y = JUMP_SPEED
					slide = false
				elif global.player != 0 and jump_tap and is_on_floor() and jumps > 0:
					if slide_timer > 0:
						if global.player != 2:
							slide_timer = 0
							slide = false
						else:
							slide_timer = 0
					jumps -= 1
					velocity.y = JUMP_SPEED
				
				#Set gravity modifier
				if overlap == 6 or overlap == 7 or overlap == 12 or overlap == 13 or global.low_grav:
					grav_mod = 3
				else:
					grav_mod = 1
				
				#Set velocity.y to 0 when releasing the jump button before reaching the peak of a jump.;
				if !jump and velocity.y < 0 and !rush_coil:
					velocity.y = 0
				
				#This is a small fix to prevent the jumping sprite from appearing during some animations.
				if force_idle and is_on_floor():
					force_idle = false
				
				if slide:
					if global.player == 0:
						$slide_top/area.set_disabled(false)
					else:
						$slide_top/area.set_disabled(true)
				else:
					$slide_top/area.set_disabled(true)
					
				#Begin sliding functions.
				if global.player == 0:
					if y_dir == 1 and jump_tap and is_on_floor() and !wall and !slide:
						anim_state(SLIDE)
						#Add slide smoke.
						var smoke = SLIDE_SMOKE.instance()
						var smk_sprite = smoke.get_child(0)
						smk_sprite.flip_h = $sprite.flip_h
						smoke.position = position + Vector2(0, 7)
						effect.add_child(smoke)
						slide_timer = 15
						slide = true
						$standbox.set_disabled(true)
						$slidebox.set_disabled(false)
				else:
					if dash_tap and is_on_floor() and !wall and !slide and !fire:
						anim_state(SLIDE)
						var smoke = SLIDE_SMOKE.instance()
						var smk_sprite = smoke.get_child(0)
						smk_sprite.flip_h = $sprite.flip_h
						smoke.position = position + Vector2(0, 7)
						effect.add_child(smoke)
						slide_timer = 15
						slide = true
						shot_state(NORMAL)
						bass_dir = ''
					
					if is_on_floor() and y_dir == 0 and !wall:
						if slide_act == 0:
							if left_tap or right_tap:
								if global.player == 1:
									slide_delay = 16
									slide_tap_dir = x_dir
									slide_act += 1
								elif global.player == 2 and !fire:
									slide_delay = 16
									slide_tap_dir = x_dir
									slide_act += 1
						
						if slide_act == 1:
							if !left_tap and !right_tap:
								slide_act += 1
								
						if slide_act == 2:
							if left_tap and slide_tap_dir == -1 or right_tap and slide_tap_dir == 1 and !slide:
								if global.player == 1:
									slide = true
									slide_timer = 15
									anim_state(SLIDE)
									var smoke = SLIDE_SMOKE.instance()
									var smk_sprite = smoke.get_child(0)
									smk_sprite.flip_h = $sprite.flip_h
									smoke.position = position + Vector2(0, 7)
									effect.add_child(smoke)
									slide_delay = 0
									slide_act = 0
									slide_tap_dir = 0
									shot_state(NORMAL)
									bass_dir = ''
								elif global.player == 2 and !fire:
									slide = true
									slide_timer = 15
									anim_state(SLIDE)
									var smoke = SLIDE_SMOKE.instance()
									var smk_sprite = smoke.get_child(0)
									smk_sprite.flip_h = $sprite.flip_h
									smoke.position = position + Vector2(0, 7)
									effect.add_child(smoke)
									slide_delay = 0
									slide_act = 0
									slide_tap_dir = 0
									shot_state(NORMAL)
									bass_dir = ''
							elif left_tap and slide_tap_dir == 1 or right_tap and slide_tap_dir == -1:
								slide_delay = 0
								slide_act = 0
								slide_tap_dir = 0
						
						if slide_delay > 0:
							slide_delay -= 1
						
						if slide_delay == 0:
							slide_act = 0
							slide_tap_dir = 0
				
				if slide_timer > 0:
					slide_timer -= 1
				
				#Begin climbing functions.
				#When the player presses up while overlapping a ladder.
				if overlap == 3 or overlap == 4 or overlap == 12 or overlap == 13:
					if y_dir == -1:
						#Lock the direction the sprite was facing.
						if $sprite.flip_h == true:
							ladder_dir = -1
						else:
							ladder_dir = 1
						$sprite.flip_h = false
						anim_state(CLIMB)
						x_speed = 0
						position.x = ladder_set
						velocity = Vector2(0, 0)
						jumps = 1
						slide = false
						slide_timer = 0
						force_idle = true
						act_state(CLIMBING)
				
				#If the player presses down while on a ladder.
				if stand_on == 3 or stand_on == 12:
					if y_dir == 1 and is_on_floor() and !slide and !fire:
						shot_state(NORMAL)
						if $sprite.flip_h == true:
							ladder_dir = -1
						else:
							ladder_dir = 1
						$sprite.flip_h = false
						anim_state(CLIMB)
						x_speed = 0
						position.x = ladder_set
						position.y += 6
						ladder_top = (tile_pos.y * 16) + 9
						velocity = Vector2(0, 0)
						jumps = 1
						slide = false
						slide_timer = 0
						force_idle = true
						act_state(CLIMBING)

			elif act_st == CLIMBING:
				
				if $standbox.is_disabled():
					$standbox.set_disabled(false)
					$slidebox.set_disabled(true)

				if shot_st == NORMAL or shot_st != NORMAL and ladder_dir == 1:
					$sprite.flip_h = false
				elif shot_st != NORMAL and ladder_dir == -1:
					$sprite.flip_h = true

				#Set the appropriate animation.
				if lad_top_overlap != -1 and lad_top_overlap != 6 and lad_top_overlap != 7:
					if anim_st != CLIMB:
						anim_state(CLIMB)
				elif lad_top_overlap == -1 or lad_top_overlap == 6 or lad_top_overlap == 7:
					if anim_st != CLIMBTOP:
						anim_state(CLIMBTOP)
						if ladder_top == 0:
							ladder_top = (tile_pos.y * 16) - 7

				#Move the player.
				if y_dir != 0 and shot_st == NORMAL:
					$anim.play()
					velocity.y = (y_dir * RUN_SPEED) * 0.9
				else:
					$anim.stop(false)
					velocity.y = 0

				#End ladder functions.
				#When the player reaches the top of a ladder.
				if y_dir == -1 and floor(position.y) <= ladder_top:
					position.y -= 6
					velocity.y = 300
					kill_ladder()
					anim_state(IDLE)

				#When the player reaches the bottom of a ladder.
				if y_dir == 1 and lad_top_overlap == -1 and stand_on == -1:
					kill_ladder()
					anim_state(JUMP)

				#When the player touches the floor while climbing.
				if y_dir == 1 and is_on_floor():
					if overlap == 3 or overlap == 4 or overlap == 6 or overlap == 7:
						velocity.y = 300
						kill_ladder()
						anim_state(IDLE)

				#When the player presses jump.
				if jump_tap:
					kill_ladder()
					anim_state(JUMP)
				
		else:
			#Kick the player back to the Standing action state unless they are trapped under a low ceiling.
			if !slide_top:
				act_state(STANDING)
				slide_timer = 0
				slide = false

			#Move the player backwards, unless they are caught in the sliding animation.
			if slide_top:
				x_speed = 0
			else:
				if $sprite.flip_h == true:
					x_speed = (RUN_SPEED * 0.6) / x_spd_mod
				else:
					x_speed = (-RUN_SPEED * 0.6) / x_spd_mod

			hurt_timer -= 1
			#When hurt_timer reaches 0, start blinking functions.
			if hurt_timer == 0:
				blink_timer = 96
				if is_on_floor() and !slide_top:
					anim_state(IDLE)
				elif !is_on_floor():
					anim_state(JUMP)
				elif is_on_floor() and slide_top:
					anim_state(SLIDE)

		#Use GRAVITY to pull the player down.
		if act_st != CLIMBING:
			velocity.x = x_speed
			velocity.y += (GRAVITY / grav_mod) * delta

		#Set the maximum downward velocity.
		if velocity.y > 500:
			velocity.y = 500

		#Gravity/Conveyors affect the player so long as they are not climbing.
		if act_st != CLIMBING:
			#Move the player if on a conveyor.
			if conveyor == 1:
				# warning-ignore:integer_division
				velocity.x += RUN_SPEED / 2
			if conveyor == 2:
				# warning-ignore:integer_division
				velocity.x -= RUN_SPEED / 2
			if conveyor == 3:
				velocity.x += RUN_SPEED
			if conveyor == 4:
				velocity.x -= RUN_SPEED
		
		var snap
		
		if velocity.y <= 0:
			snap = Vector2()
		else:
			snap = Vector2(0, 4)
		
		rush_jet = false
		
		if velocity.y <= 0:
			snap = Vector2()
		else:
			snap = Vector2(0, 8)

		#Move the player
		velocity = move_and_slide_with_snap(velocity, snap, Vector2(0, -1))
		#Get what the player is standing on.
		for idx in range(get_slide_count()):
			var collision = get_slide_collision(idx)
			
			if !is_on_wall():
			
				if is_on_floor() and collision.collider.get_parent().name == 'rush_jet':
					rush_jet = true
	
				if is_on_floor() and collision.collider.name == 'tiles' or is_on_floor() and collision.collider.name == 'death':
					x_spd_mod = 1
					conveyor = 0
					ice = false
	
				if is_on_floor() and collision.collider.name == 'snow':
					x_spd_mod = 2
	
				if is_on_floor() and  collision.collider.name == 'slw_conv_r':
					conveyor = 1
				elif is_on_floor() and collision.collider.name == 'slw_conv_l':
					conveyor = 2
				elif is_on_floor() and collision.collider.name == 'fst_conv_r':
					conveyor = 3
				elif is_on_floor() and collision.collider.name == 'fst_conv_l':
					conveyor = 4
	
				if is_on_floor() and collision.collider.name == 'ice':
					ice = true
			
			if collision.collider.name == 'death' and blink_timer == 0 and hurt_timer == 0:
				#Spawn the death boom. Replace when HP bar is added.
				if !world.dead:
					global.player_life[0] = 0
					global.player_life[1] = 0
					world.dead = true
					can_move = false
					get_tree().paused = true
			

		#This is a small fix to handle the x speed modifier.
		if !is_on_floor():
			x_spd_mod = 1
			conveyor = 0
			ice = false

		#Print Shit
		var top = $slide_top.get_overlapping_bodies()
		if slide_top and top == []:
			slide_top = false

#There are 3 states that the player will call. Animation, Action, and Shot
#Pull the matching Animation State and set the animation accordingly.
func anim_state(new_anim_state):
	anim_st = new_anim_state
	match anim_st:
		BEAM:
			change_anim('beam')
		APPEAR:
			if global.player != 2:
				change_anim('appear1')
			else:
				change_anim('appear2')
		IDLE:
			if global.player != 1:
				change_anim('idle1')
			else:
				change_anim('idle2')
		LILSTEP:
			change_anim('lilstep')
		RUN:
			change_anim('run')
		JUMP:
			change_anim('jump')
		SLIDE:
			change_anim('slide')
		CLIMB:
			change_anim('climb')
		CLIMBTOP:
			change_anim('climbtop')
		HURT:
			change_anim('hurt')
			var spark = DMG_SPARK.instance()
			spark.position = position
			effect.add_child(spark)
		FALL:
			change_anim('fall')


func change_anim(new_anim):
	play_anim = new_anim
	$anim.play(play_anim)

#Pull the action state.
func act_state(new_act_state):
	act_st = new_act_state
	#Add things here as necessary, if at all.

#Pull the shooting/throwing state and set the appropriate texture.
func shot_state(new_shot_state):
	shot_st = new_shot_state
	match shot_st:
		NORMAL:
			texture = '-norm'
			change_char()
		SHOOT:
			texture = '-shoot'
			change_char()
		BASSSHOT:
			texture = '-shoot'
			change_char()
		THROW:
			texture = '-throw'
			change_char()

#Pull the player's texture sheet.
func change_char():
	global.player = global.player_id[int(swap)]
	
	if global.player == 0:
		$slide_wall.position.y = 5
	else:
		$slide_wall.position.y = 0

#	if global.player == 2 and shot_st == BASSSHOT:
#		if global.player_weap[int(swap)] == 0:
#			if x_dir == 0 and y_dir == -1:
#				bass_dir = '-up'
#			elif x_dir != 0 and y_dir == -1:
#				bass_dir = '-d-up'
#			elif x_dir != 0 and y_dir == 1 or x_dir == 0 and y_dir == 1:
#				bass_dir = '-d-down'
#			elif x_dir != 0 and y_dir == 0 or x_dir == 0 and y_dir == 0:
#				bass_dir = ''

	if global.player == 0:
		player = 'mega'
	elif global.player == 1:
		player = 'proto'
	elif global.player == 2:
		player = 'bass'

	final_tex = str(player+texture+bass_dir)

	$sprite.texture = load('res://assets/sprites/player/'+final_tex+'.png')

#Disable player input during camera transitions.
func _on_world_scrolling():
	if !can_move:
		can_move = true
	else:
		can_move = false

#Begin stage start functions.
func _on_ready_start():
	start_stage = true

#Pull needed data
func get_data():
	#Get tile position
	tile_pos = tiles.world_to_map(position)

	#Get the tile that the player is standing on.
	stand_on = tiles.get_cellv(Vector2(tile_pos.x, tile_pos.y + 1))

	#Get the tile that the player is overlapping.
	overlap = tiles.get_cellv(tile_pos)

	#Get the X coordinate that the player will snap to when grabbing a ladder.
	ladder_set = (tile_pos.x * 16) + 8

	#Get the position and overlap of the ladder top detector
	lad_top_detect = tiles.world_to_map($lad_top_detect.global_position)
	lad_top_overlap = tiles.get_cellv(lad_top_detect)

#Determine whether the slide_top detector is overlapping an obstacle.
# warning-ignore:unused_argument
func _on_slide_top_body_entered(body):
	slide_top = true

# warning-ignore:unused_argument
func _on_slide_wall_body_entered(body):
	wall = true

# warning-ignore:unused_argument
func _on_slide_wall_body_exited(body):
	wall = false

func weapons():
	#Set timer for the shooting/throwing sprites.
	shot_delay = 20
	
	if !slide:
		if chrg_lvl == 0:
			#Fire normal shots.
			var wkey = str(global.player)+'-'+str(global.player_weap[int(swap)])+'-'+str(0)+'-'+str(31)
			
			if wpn_data.has(wkey):
				
				#Check and see if any adaptors need spawning.
				if wpn_data.get(wkey)[3] < world.adaptors:
					var adaptor = wpn_data.get(wkey)[5].instance()
					
				
				shot_state(wpn_data.get(wkey)[4])
				var weap = wpn_data.get(wkey)[6].instance()
				
				if wpn_data.get(wkey)[8] == 0: #Fires from shoot_pos
					weap.position = $sprite/shoot_pos.global_position
					
				effect.add_child(weap)
			
		elif chrg_lvl > 0:
			chrg_lvl = 0
	
#	#NOTE: Edit this section as weapons become usable.
#	if global.player_weap[int(swap)] == 0:
#		if global.player != 2:
#			$audio/charge_start.stop()
#			$audio/charge_loop.stop()
#			if !slide:
#				shot_state(SHOOT)
#				#Mega Buster/Proto Strike
#				if global.player_weap[int(swap)] == 0 and charge < 32:
#					var buster_a = load('res://scenes/player/weapons/buster_a.tscn').instance()
#					wpn_layer.add_child(buster_a)
#					buster_a.position = $sprite/shoot_pos.global_position
#				elif global.player_weap[int(swap)] == 0 and charge >= 32 and charge < 96:
#					if global.player == 0:
#						var buster_c = load('res://scenes/player/weapons/buster_c.tscn').instance()
#						wpn_layer.add_child(buster_c)
#						buster_c.position = $sprite/shoot_pos.global_position
#					else:
#						var buster_d = load('res://scenes/player/weapons/buster_d.tscn').instance()
#						wpn_layer.add_child(buster_d)
#						buster_d.position = $sprite/shoot_pos.global_position
#				elif global.player_weap[int(swap)] == 0 and charge >= 96:
#					if global.player == 0:
#						var buster_e = load('res://scenes/player/weapons/buster_e.tscn').instance()
#						wpn_layer.add_child(buster_e)
#						buster_e.position = $sprite/shoot_pos.global_position
#					else:
#						var buster_f = load('res://scenes/player/weapons/buster_f.tscn').instance()
#						wpn_layer.add_child(buster_f)
#						buster_f.position = $sprite/shoot_pos.global_position
#			charge = 0
#			c_flash = 0
#			world.palette_swap()
#
#		#Bass Only
#		if global.player == 2:
#			#Bass Buster
#			if !slide:
#				var buster_b = load('res://scenes/player/weapons/buster_b.tscn').instance()
#				wpn_layer.add_child(buster_b)
#				buster_b.position = $sprite/shoot_pos.global_position
#
#	#Movement Adaptors
#	if global.player_weap[int(swap)] == 1:
#		#Mega Man
#		if global.player == 0:
#			#Fire standard buster shots if Rush is on screen.
#			if world.adaptors == 0:
#				var r_coil = load('res://scenes/player/weapons/rush_coil.tscn').instance()
#				wpn_layer.add_child(r_coil)
#				if !$sprite.flip_h:
#					r_coil.position.x = position.x + 32
#				else:
#					r_coil.position.x = position.x - 32
#				r_coil.position.y = camera.limit_top - 16
#			else:
#				shot_state(SHOOT)
#				var buster_a = load('res://scenes/player/weapons/buster_a.tscn').instance()
#				wpn_layer.add_child(buster_a)
#				buster_a.position = $sprite/shoot_pos.global_position
#
#		#Proto Man
#		if global.player == 1:
#			#Summon Carry.
#			if world.adaptors == 0:
#				shot_state(THROW)
#				global.rp_coil[int(swap) + 1] -= 20
#				var carry = load('res://scenes/player/weapons/carry.tscn').instance()
#				wpn_layer.add_child(carry)
#				if !is_on_floor():
#					if !$sprite.flip_h:
#						carry.position.x = position.x + 8
#					else:
#						carry.position.x = position.x - 8
#					carry.position.y = position.y + 24
#				else:
#					if !$sprite.flip_h:
#						carry.position.x = position.x + 16
#					else:
#						carry.position.x = position.x - 16
#					carry.position.y = position.y + 8
#			else:
#				#Allow the player to shoot is Carry is active.
#				shot_state(SHOOT)
#				var buster_a = load('res://scenes/player/weapons/buster_a.tscn').instance()
#				wpn_layer.add_child(buster_a)
#				buster_a.position = $sprite/shoot_pos.global_position
#
#	#Helper Adaptors
#	if global.player_weap[int(swap)] == 11:
#		#Mega Man
#		#Proto Man
#		if global.player == 1:
#			#Fire standard buster shots if Rush is on screen.
#			if world.adaptors == 0:
#				var tango = load('res://scenes/player/weapons/tango.tscn').instance()
#				wpn_layer.add_child(tango)
#				if !$sprite.flip_h:
#					tango.position.x = position.x + 32
#				else:
#					tango.position.x = position.x - 32
#				tango.position.y = camera.limit_top - 16
#			else:
#				shot_state(SHOOT)
#				var buster_a = load('res://scenes/player/weapons/buster_a.tscn').instance()
#				wpn_layer.add_child(buster_a)
#				buster_a.position = $sprite/shoot_pos.global_position
#
#	if global.player_weap[int(swap)] == 2:
#		#Mega Man
#		if global.player == 0:
#			if world.adaptors == 0:
#				var r_jet = load('res://scenes/player/weapons/rush_jet.tscn').instance()
#				wpn_layer.add_child(r_jet)
#				if !$sprite.flip_h:
#					r_jet.position.x = position.x + 32
#				else:
#					r_jet.position.x = position.x - 32
#				r_jet.position.y = camera.limit_top - 16
#			else:
#				shot_state(SHOOT)
#				var buster_a = load('res://scenes/player/weapons/buster_a.tscn').instance()
#				wpn_layer.add_child(buster_a)
#				buster_a.position = $sprite/shoot_pos.global_position
	
	

func _on_anim_animation_finished(anim_name):
	if anim_name == 'appear1':
		if lock_ctrl:
			emit_signal('teleport')
		elif !lock_ctrl:
			anim_state(IDLE)
			can_move = true
			
func shot_pos():
	
	if global.player != 2 or global.player == 2 and global.player_weap[int(swap)] != 0:
		key = str(global.player)+'-'+str($sprite.frame)
	else:
		key = str(global.player)+'-'+str($sprite.frame)+str(bass_dir)
	
	if s_frame.has(key):
		if shot_dir == 0:
			$sprite/shoot_pos.position.x = -s_frame.get(key).x
		else:
			$sprite/shoot_pos.position.x = s_frame.get(key).x
		$sprite/shoot_pos.position.y = s_frame.get(key).y

func damage():
	if !hurt_swap:
		if hurt_timer == 0 and blink_timer == 0 and global.player_life[int(swap)] > 0:
			$audio/hurt.play()
			velocity.y = 0
			anim_state(HURT)
			hurt_timer = 16


func _on_item_entered(body):
	if body.is_in_group('items'):
		
		#Bolts
		if global.bolts < 999:
			if body.type == 0 or body.type == 1:
				$audio/bolt.play()
				if body.type == 0:
					global.bolts += 2
				if body.type == 1:
					global.bolts += 20
			#Keep the bolts counter lower than 1000
			if global.bolts > 999:
				global.bolts = 999
		
		#Energy Pellet/Capsule
		if global.player_life[int(swap)] < 280:
			if body.type == 2:
				var diff = 280 - global.player_life[int(swap)]
				max_en = 20
				if diff < max_en:
					world.life_en = max_en + (global.player_life[int(swap)] - 280)
				else:
					world.life_en = max_en
			
			if body.type == 3:
				var diff = 280 - global.player_life[int(swap)]
				max_en = 80
				if diff < max_en:
					world.life_en = max_en + (global.player_life[int(swap)] - 280)
				else:
					world.life_en = max_en
		
		#Weapon Pellete/Capsule
		if body.type == 4 or body.type == 5:
			
			if body.type == 4:
				max_en = 20
			else:
				max_en = 80
			
			wpn_lvl = {
				0 : [true, 280, 280], #Set higher than the max meter values so it doesn't get picked.
				1 : global.rp_coil,
				2 : global.rp_jet,
				3 : global.weapon1,
				4 : global.weapon2,
				5 : global.weapon3,
				6 : global.weapon4,
				7 : global.weapon5,
				8 : global.weapon6,
				9 : global.weapon7,
				10 : global.weapon8,
				11 : global.beat,
				12 : global.tango,
				13 : global.reggae
				}
			
			#Get the weapon's ID
			if global.player_weap[int(swap)] == 0:
				wpn_id = 0
			elif global.player_weap[int(swap)] > 0 and global.player_weap[int(swap)] < 11:
				wpn_id = global.player_weap[int(swap)]
			else:
				wpn_id = global.player_weap[int(swap)] + global.player
			
			#Refill energy if theh player has no energy balancer
			if !global.perma_items['ebalancer'] and wpn_id != 0 and wpn_lvl[wpn_id][int(swap) + 1] < 280 or global.perma_items['ebalancer'] and wpn_id != 0 and wpn_lvl[wpn_id][int(swap) + 1] < 280:
				#Set ID for the world script.
				world.id = wpn_id
				#Set the value of the energy recovery
				var diff = 280 - wpn_lvl[wpn_id][int(swap) + 1]
				if diff < max_en:
					world.wpn_en = max_en + (wpn_lvl[wpn_id][int(swap) + 1] - 280)
				else:
					world.wpn_en = max_en
			elif !global.perma_items['ebalancer'] and wpn_id == 0:
				#Skip this function if the player doesn't have the energy balancer and no special weapon equipped.
				pass
			else:
				#Clear the array so new info can be added
				get_lvl.clear()
				for g in range(wpn_lvl.size()):
					get_lvl.append(wpn_lvl[g][int(swap) + 1])

				var w_id

				if global.player_weap[int(swap)] == 0:
					w_id = 0
				elif global.player_weap[int(swap)] > 0 and global.player_weap[int(swap)] < 11:
					w_id = global.player_weap[int(swap)]
				else:
					w_id = global.player_weap[int(swap)] + global.player

				#Get the weapon ID if the levels are below max.
				if w_id == 0 and get_lvl.min() < 280 or w_id != 0 and wpn_lvl[w_id][int(swap) + 1] == 280 and get_lvl.min() < 280:
					for l in range(get_lvl.size()):
						if wpn_lvl[l][int(swap) + 1] == get_lvl.min():
							wpn_id = l
							
							if global.player == 0 and wpn_id > 11:
								wpn_id = 11
							if global.player == 1 and wpn_id > 12:
								wpn_id = 12
					
					#Set the weapon's ID in the world script.
					world.id = wpn_id
					#Set the value of the energy recovery
					var diff = 280 - wpn_lvl[wpn_id][int(swap) + 1]
					if diff < max_en:
						world.wpn_en = max_en + (wpn_lvl[wpn_id][int(swap) + 1] - 280)
					else:
						world.wpn_en = max_en
				else:
					max_en = 0
			
			print(wpn_id)
			
		#E-Tanks
		if global.etanks < 4:
			if body.type == 6:
				$audio/oneup.play()
				global.etanks += 1
		
		if global.mtanks < 1:
			if body.type == 7:
				$audio/oneup.play()
				global.mtanks += 1
			
		#Extra Lives
		if global.lives < 9:
			if body.type == 8:
				$audio/oneup.play()
				global.lives += 1
				
		#Set the entry to true if the item has been collected. This will prevent items from respawning when the stage resets.
		#Check to see if the item has an ID.
		if body.id != 0:
			if global.temp_items.has(body.id):
				global.temp_items.erase(body.id)
				global.temp_items[body.id] = true
		
		body.pickup()
			
func kill_slide():
	pass

func kill_ladder():
	ladder_top = 0
	act_state(STANDING)
	if ladder_dir == -1:
		$sprite.flip_h = true
	else:
		$sprite.flip_h = false