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
var fire
var fire_tap
var prev
var next
var select
var start

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
	'0_4' : Vector2(16, 0),
	'0_5' : Vector2(16, 0),
	'0_6' : Vector2(16, 0),
	'0_7' : Vector2(14, 1),
	'0_8' : Vector2(14, 0),
	'0_9' : Vector2(14, 1),
	'0_10' : Vector2(12, -4),
	'0_11' : Vector2(12, -4),
	'0_12' : Vector2(12, -4),
	'0_13' : Vector2(12, -4),
	'1_4' : Vector2(10, 4),
	'1_5' : Vector2(10, 4),
	'1_6' : Vector2(10, 4),
	'1_7' : Vector2(10, 4),
	'1_8' : Vector2(10, 3),
	'1_9' : Vector2(10, 4),
	'1_10' : Vector2(10, 1),
	'1_11' : Vector2(13, 0),
	'1_12' : Vector2(13, 0),
	'1_13' : Vector2(13, 0),
	'2_4' : Vector2(17, 1),
	'2_5' : Vector2(17, 1),
	'2_6' : Vector2(17, 1),
	'2_7' : Vector2(15, 2),
	'2_8' : Vector2(15, 0),
	'2_9' : Vector2(15, 2),
	'2_10' : Vector2(13, -3),
	'2_11' : Vector2(14, -3),
	'2_12' : Vector2(14, -3),
	'2_13' : Vector2(14, -3),
	'2_4-up' : Vector2(4, -9),
	'2_5-up' : Vector2(4, -9),
	'2_6-up' : Vector2(4, -9),
	'2_10-up' : Vector2(5, -12),
	'2_11-up' : Vector2(6, -13),
	'2_12-up' : Vector2(6, -13),
	'2_13-up' : Vector2(6, -13),
	'2_4-d-up' : Vector2(14, -6),
	'2_5-d-up' : Vector2(14, -6),
	'2_6-d-up' : Vector2(14, -6),
	'2_10-d-up' : Vector2(11, -8),
	'2_11-d-up' : Vector2(12, -9),
	'2_12-d-up' : Vector2(12, -9),
	'2_13-d-up' : Vector2(12, -9),
	'2_4-d-down' : Vector2(14, 8),
	'2_5-d-down' : Vector2(14, 8),
	'2_6-d-down' : Vector2(14, 8),
	'2_10-d-down' : Vector2(11, 4),
	'2_11-d-down' : Vector2(12, 4),
	'2_12-d-down' : Vector2(12, 4),
	'2_13-d-down' : Vector2(12, 4)
	}

#Weapons are spawned based off this dictionary. The key number corresponds to the weapon ID in global.gd. The following array is as follows:
#[0] = Max Shots on screen.
#[1] = Max adaptors on screen before the plahyer can shoot.
#[2] = Energy to fire the shot in multiples of 10 if any.
#[3] = Node to instance
var wpns = {
	'0a' : [3, 0, 0, load('res://scenes/player/weapons/buster_a.tscn').instance()],#Mega Man - Default shot
	'0b' : [3, 0, 0, load('res://scenes/player/weapons/buster_c.tscn').instance()],#'' - Level 1 Shot
	'0c' : [3, 0, 0, load('res://scenes/player/weapons/buster_e.tscn').instance()],#'' - Level 2 Shot
	'0d' : [2, 0, 0, load('res://scenes/player/weapons/buster_a.tscn').instance()],#Proto Man - Default shot
	'0e' : [2, 0, 0, load('res://scenes/player/weapons/buster_d.tscn').instance()],#'' - Level 1 Shot
	'0f' : [2, 0, 0, load('res://scenes/player/weapons/buster_f.tscn').instance()],#'' - Level 2 Shot
	'0g' : [3, 0, 0, load('res://scenes/player/weapons/buster_b.tscn').instance()],#Bass - Default shot
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
	if can_move:
		#Set direction
		x_dir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		y_dir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		
		if x_dir < 0 and !rush_jet:
			shot_dir = 0
			$sprite.flip_h = true
			$slide_wall.position.x = -7
			shot_pos()
		elif x_dir > 0 and !rush_jet:
			shot_dir = 0
			$sprite.flip_h = false
			$slide_wall.position.x = 7
			shot_pos()
		
		#Jump
		if Input.is_action_just_pressed("jump"):
			if global.player == 0 and y_dir != 1 and is_on_floor() and jumps > 0 and !slide_top:
				slide = false
			elif global.player != 0 and is_on_floor() and jumps > 0:
				if global.player != 2:
					slide_timer = 0
					slide = false
				else:
					slide_timer = 0
			anim_state(JUMP)
			velocity.y = JUMP_SPEED
			jumps -= 1
			jump = true
		
		if Input.is_action_just_released("jump"):
			jump = false
		
		#Shoot
		if Input.is_action_just_pressed("fire"):
			fire = true
		
		if Input.is_action_just_released("fire"):
			fire = false
		
		#Ladder
		#If pressed up while overlapping a ladder
		if y_dir == -1:
			var get_ovrlap = [3, 4, 12, 13]
			if get_ovrlap.has(overlap):
				#Lock the direction the sprite was facing.
				if $sprite.flip_h:
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
		
		#If pressed down while on top of a ladder.
		if y_dir == 1 and is_on_floor() and !slide and !fire:
			var get_stnd = [3, 12]
			shot_state(NORMAL)
			if $sprite.flip_h:
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
			
		#Slide/Dash
		if y_dir == 1 and Input.is_action_just_pressed("jump") and is_on_floor() and !wall and !slide:
			if global.player == 0:
				anim_state(SLIDE)
				var smoke = SLIDE_SMOKE.instance()
				var smk_sprite = smoke.get_child(0)
				smk_sprite.flip_h = $sprite.flip_h
				smoke.position = position + Vector2(0, 7)
				effect.add_child(smoke)
				slide_timer = 15
				slide = true
				$standbox.set_disabled(true)
				$slidebox.set_disabled(false)
		
		if Input.is_action_just_pressed("dash") and is_on_floor() and !wall and !slide and !fire:
			if global.player != 0:
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
		
		if is_on_floor() and y_dir == 0:
			if x_dir != 0 and !wall:
				if slide_act == 0:
					if global.player == 1 or global.player == 2 and !fire:
						slide_delay = 16
						slide_tap_dir = x_dir
						slide_act += 1
				
				if slide_act == 2:
					if x_dir == slide_tap_dir:
						if global.player == 1 or global.player == 2 and !fire:
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
					else:
						slide_delay = 0
						slide_act = 0
						slide_tap_dir = 0
			
			if x_dir == 0:
				if slide_act == 1:
					slide_act += 2
		
	
func _physics_process(delta):	
	#Get tilemap data
	get_data()
	
	#Set gravity modifier
	var get_ovrlap = [6, 7, 12, 13]
	if get_ovrlap.has(overlap) or global.low_grav:
		grav_mod = 3
	else:
		grav_mod = 1
	
	#Place weapon icon functions here.
	
	#NOTE: This section ONLY brings the player into view at the beginning of a stage.
	if !can_move:
		#Bring the character sprite down after READY is gone.
		if start_stage:
			if $sprite.offset.y < -1:
				$sprite.offset.y += 8
			
			if $sprite.offset.y == -1:
				anim_state(APPEAR)
				$audio/appear.play() #Move to world script.
				start_stage = false
	#Other functions.
	else:
		#Make the player blink after taking damage.
		if hurt_timer == 0:
			if blink_timer > 0:
				blink += 1
				if blink == 2:
					hide()
				elif blink == 4:
					show()
				blink_timer -= 1
				#Reset the player to normal.
				if blink_timer == 0:
					show()
					if hurt_swap:
						hurt_swap = false
						world.hurt_swap = false
		
	#Revert player sprites if in the shooting phase.
	if shot_delay > 0:
		#Fix idle animations.
		if shot_st == THROW or shot_st == BASSSHOT:
			if is_on_floor() and anim_st != IDLE:
				anim_state(IDLE)
	
	if act_st == STANDING:
		standing(delta)
	elif act_st == CLIMBING:
		climbing()
	elif act_st == TBOOST:
		t_boost()
	
	
	
	#Move the player.
	velocity = move_and_slide_with_snap(velocity, Vector2(0, 0), Vector2(0, -1))
		
func standing(delta):
	#Subtract from the slide timer.
	if slide_timer > 0:
		slide_timer -= 1
	#Set velocity.x to 0 if not standing on ice.
	if !ice:
		x_speed = 0
	#Transition to the little step.
	if is_on_floor() and x_dir != 0 and shot_st != THROW and shot_st != BASSSHOT and anim_st == IDLE and !rush_jet:
		anim_state(LILSTEP)
		if !ice:
			x_speed = (x_dir * RUN_SPEED) / x_spd_mod
	#Set X velocity.
	if !slide:
		if anim_st == RUN and !rush_jet:
			if shot_st != THROW and shot_st != BASSSHOT:
				if !ice:
					x_speed = (x_dir * RUN_SPEED) / x_spd_mod
				else:
					if !is_on_wall() and x_dir == -1 and x_speed > -RUN_SPEED:
						x_speed -= 1
						if x_dir == -1 and x_speed > 0:
							x_speed -= 1
					elif !is_on_wall() and x_dir == 1 and x_speed < RUN_SPEED:
						x_speed += 1
						if x_dir == 1 and x_speed < 0:
							x_speed += 1
			#Prevent the player from moving while riding Rush.
			if anim_st != IDLE and rush_jet:
				anim_state(IDLE)
			#Slow the player to a stop on ice if idle, throwing, or shooting as Bass.
			#DOUBLE CHECK AREA
			if anim_st == IDLE or anim_st == LILSTEP or shot_st == THROW or shot_st == BASSSHOT:
				if ice:
					if x_speed > 0:
						x_speed -= 1
					elif x_speed < 0:
						x_speed += 1
			#Set veloxity.x while jumping.
			#DOUBLE CHECK - Add other functions as new puzzles and obstacles are developed.
			if anim_st == JUMP:
				x_speed = x_dir * RUN_SPEED / x_spd_mod
	else:
		#Set velocity.x for sliding/dashing.
		if is_on_floor():
			if $sprite.flip_h:
				x_speed = (-RUN_SPEED * 2) / x_spd_mod
			else:
				x_speed = (RUN_SPEED * 2) / x_spd_mod
		else:
			x_speed = ((x_dir * RUN_SPEED) * 2) / x_spd_mod
	if is_on_floor():
		#Transition back to idle if no longer running.
		if x_dir == 0 and anim_st == RUN:
			anim_state(LILSTEP)
			if !ice:
				if $sprite.flip_h:
					x_speed = -RUN_SPEED / x_spd_mod
				else:
					x_speed = RUN_SPEED / x_spd_mod
		#Reset jumps counter and cancel sliding.
		if !jump and jumps == 0 and !slide:
			jumps = 1
			x_speed = (x_dir * RUN_SPEED) / x_spd_mod
			kill_slide()
		#Change the player's animation based if they are on the floor or not.
		if anim_st == JUMP:
			rush_coil = false
			if x_dir == 0:
				anim_state(IDLE)
			else:
				anim_state(RUN)
			$audio/land.play() #Move to world.gd
			
		#SLIDE FUNCTIONS
		if slide:
			if global.player == 0:
				$slide_top/area.set_disabled(false)
			else:
				$slide_top/area.set_disabled(true)
		else:
			$slide_top/area.set_disabled(true)
		#When the slide timer reaches 0, cancel sliding.
		if slide and slide_timer == 0 and !slide_top:
			if x_dir == 0:
				anim_state(IDLE)
			else:
				anim_state(RUN)
			if ice:
				if $sprite.flip_h:
					x_speed = -RUN_SPEED
				else:
					x_speed = RUN_SPEED
			kill_slide()
		#When the player touches a wall, cancel sliding.
		if is_on_wall() and slide and !slide_top:
			anim_state(IDLE)
			kill_slide()
		#When the opposite direction is pressed and the player is not under a low ceiling, cancel slide.
		if slide and !slide_top:
			if !$sprite.flip_h and x_dir == 1 or !$sprite.flip_h and x_dir == -1:
				anim_state(IDLE)
				kill_slide()
		#Failsafe in case the player gets stuck in the floor.
		if !slide and slide_timer <= 0 and anim_st == SLIDE and !slide_top:
			if x_dir == 0:
				anim_state(IDLE)
			else:
				anim_state(RUN)
		
		#Begin slide functions.
		
		#Small fix to prevent the jumping sprite from showing after a teleport or reaching the top of a ladder.
		if force_idle:
			force_idle = false
		
	else:
		#When the player is no longer on the floor, cancel slide.
		if slide and jumps > 0:
			anim_state(JUMP)
			jumps = 0
			kill_slide()
		
		if slide and global.player == 1:
			jumps = 0
			kill_slide()
			
		#See line 367 DOUBLE CHECK
		if anim_st != JUMP and !force_idle:
			anim_state(JUMP)
			jumps = 0
		
		#If the player releases the jump button before reaching the peak of their jump, set velocity.y to 0.
		if !jump and velocity.y < 0 and !rush_coil:
			velocity.y = 0
		
	velocity.x = x_speed
	velocity.y += (GRAVITY / grav_mod) *delta
	
	if velocity.y > 500:
		velocity.y = 500
	
	

func climbing():
	pass

func t_boost():
	pass

func anim_state(name):
	anim_st = name
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

#Pull the action state. Replace as it's unnecessary.
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

	if global.player == 2 and shot_st == BASSSHOT:
		if global.player_weap[int(swap)] == 0:
			if x_dir == 0 and y_dir == -1:
				bass_dir = '-up'
			elif x_dir != 0 and y_dir == -1:
				bass_dir = '-d-up'
			elif x_dir != 0 and y_dir == 1 or x_dir == 0 and y_dir == 1:
				bass_dir = '-d-down'
			elif x_dir != 0 and y_dir == 0 or x_dir == 0 and y_dir == 0:
				bass_dir = ''

	if global.player == 0:
		player = 'mega'
	elif global.player == 1:
		player = 'proto'
	elif global.player == 2:
		player = 'bass'

	final_tex = str(player+texture+bass_dir)

	$sprite.texture = load('res://assets/sprites/player/'+final_tex+'.png')

func kill_slide():
	slide_timer = 0
	$standbox.set_disabled(false)
	$slidebox.set_disabled(true)
	slide = false

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

func weapons():
	pass

func _on_anim_finished(anim_name):
	if anim_name == 'appear1' or anim_name == 'appear2':
			anim_state(IDLE)
			can_move = true
	
	if anim_name == "lilstep":
		if x_dir != 0:
			anim_state(RUN)
		else:
			anim_state(IDLE)
			
func shot_pos():
	
	if global.player != 2:
		key = str(global.player)+'_'+str($sprite.frame)
	else:
		key = str(global.player)+'_'+str($sprite.frame)+str(bass_dir)
	
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