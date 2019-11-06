extends KinematicBody2D

signal dead

#Most of these variables will be shared amongst all enemies.

#Get the player node.
onready var world = get_parent().get_parent()
onready var player = world.get_child(2)

#Starting X and Y coordinates. To allow the enemy to respawn when off screen.
var start_pos = Vector2()

#The distance between the player and enemy.
var dist

#Enemy HP.
const DEFAULT_HP = 10
var hp

#Damage enemy does to the player.
var touch = false
var damage = 40

#Other
var dead = false
var flash = false
var f_delay = 0

const RESET_MAX = 120

var state = 0
var immune = true
var shoot = false
var shot_delay = 15
var reset = 0

var repeat = 0
var bull_vel = 0
var fire = false

func _ready():
	start_pos = Vector2(global_position.x, global_position.y)
	
	hp = DEFAULT_HP
	
	dist = global_position.distance_to(player.global_position)
	
	if global_position.x > player.global_position.x:
		$sprite.flip_h = true
	else:
		$sprite.flip_h = false
	
	$anim.play("idle")

# warning-ignore:unused_argument
func _physics_process(delta):
	#get the distance to the player.
	dist = floor(global_position.distance_to(player.global_position))
	
	#Let the reset timer expire and charge direction to face the player.
	if state == 0 and reset > 0:
		reset -= 1
	
	if reset == 60:
		if global_position.x > player.global_position.x:
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
			
	#If the player is within range, trigger animation.
	if dist <= 96 and state == 0 and reset == 0:
		state = 1
		$anim.play("open")
		immune = false
	
	#If the met has shot, start timer.
	if shoot and shot_delay > 0:
		shot_delay -= 1
	
	#When timer expires, start animation.
	if shoot and shot_delay == 0:
		state = 2
		shoot = false
		shot_delay = 15
		$anim.play_backwards("open")
	
	if flash and f_delay > 0:
		f_delay -= 1
	
	if f_delay == 0 and flash:
		$sprite.show()
		flash = false
	
	if touch and player.hurt_timer == 0 and player.blink_timer == 0 and !player.hurt_swap:
		global.player_life[int(player.swap)] -= damage
		player.damage()
	
	if hp <= 0 and !dead:
		item_drop()
		$sprite.hide()
		$anim.play("idle")
		dead = true
		flash = false
		state = 0
		immune = true
		f_delay = 0
		reset = 0
		emit_signal("dead")
		#Spawn explosion sprite.
		var boom = load("res://scenes/effects/s_explode.tscn").instance()
		boom.global_position = global_position
		world.get_child(3).add_child(boom)
	
	#Play the throwing sound for the projectile.
	if $anim.is_playing() and $sprite.frame == 6:
		if repeat == 0:
			bull_vel = global_position.distance_to(Vector2(player.global_position.x - 16, player.global_position.y))*1.25
		if repeat == 1:
			bull_vel = global_position.distance_to(Vector2(player.global_position.x + 16, player.global_position.y))*1.25
		if repeat == 2:
			bull_vel = global_position.distance_to(Vector2(player.global_position.x, player.global_position.y))*1.25
		if !fire:
			$throw.play()
			var stick = load("res://scenes/enemies/rave_bullet.tscn").instance()
			stick.get_child(2).flip_h = $sprite.flip_h
			stick.x_spd = bull_vel
			stick.global_position = global_position
			world.get_child(1).add_child(stick)
			fire = true

func _on_anim_finished(anim_name):
	if anim_name == "open":
		if !dead:
			if state == 1:
				repeat = 0
				$anim.play("throw")
			if state == 2:
				$anim.play("idle")
				immune = true
				reset = RESET_MAX
				state = 0
				repeat = 0
		else:
			$anim.play("idle")
			fire = false
			immune = true
			reset = RESET_MAX
			state = 0
			repeat = 0
	
	if anim_name == 'throw':
		if !dead:
			if repeat < 2:
				$anim.play("throw")
				repeat += 1
			else:
				shoot = true
				$anim.play("idle2")
		fire = false

func _on_hit_box_body_entered(body):
	if body.is_in_group("weapons") or body.is_in_group("adaptor_dmg"):
		if !dead:
			if immune and !body.reflect:
				body.reflect = true
			else:
				if hp < body.damage:
					if body.name != "buster_f":
						body._on_screen_exited()
				else:
					body._on_screen_exited()
				hp -= body.damage
				$hit.play()
				flash = true
				f_delay = 2
	
	if body.name == "player" and !dead:
		touch = true

func _on_hit_box_body_exited(body):
	if body.name == "player":
		touch = false

func _on_screen_exited():
	if dead:
		dead = false
		$sprite.show()
		hp = DEFAULT_HP
		reset = RESET_MAX

func item_drop():
	#Move this to world script.
	var item = ''
	var type = 0
	var item_table = {
		0 : null,
		1 : "bolt_l",
		2 : "bolt_s",
		3 : "life_l",
		4 : "life_s",
		5 : "wpn_l",
		6 : "wpn_s",
		7 : "1up"
		}
	
	var rate = floor(rand_range(1, 128))
	
	#Drop rates are based on MM1/2 values
	if rate == 1:
		item = item_table.get(7)
		type = 8
	if rate >= 2 and rate <= 6:
		item = item_table.get(5)
		type = 5
	if rate >= 7 and rate <= 11:
		item = item_table.get(3)
		type = 3
	if rate >= 12 and rate <= 16:
		item = item_table.get(1)
		type = 1
	if rate >= 17 and rate <= 42:
		item = item_table.get(6)
		type = 4
	if rate >= 43 and rate <= 58:
		item = item_table.get(4)
		type = 2
	if rate >= 59 and rate <= 74:
		item = item_table.get(2)
		type = 0
	
	if item != '':
		var spawn = load("res://scenes/objects/"+item+".tscn").instance()
		spawn.global_position = global_position
		spawn.type = type
		spawn.velocity.y = spawn.JUMP_SPEED
		world.get_child(1).add_child(spawn)