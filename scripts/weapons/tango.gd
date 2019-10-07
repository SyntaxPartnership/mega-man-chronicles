extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = world.get_child(2).get_child(8)

const BEAM_SPD = 400
const MAX_X = 90
const JUMP = -100
const GRAVITY = 900

var damage = 20

var reflect = false

var time = 240
var on_floor = false
var leave = false
var x_spd = 0
var attack = false
var atk_pos = Vector2()
var atk_time = 120
var targets = []
var dead_targs = []
var sleep = false
var slp_anim = 0
var bounce = 0
var move = false
var sleep_anim = false
var velocity = Vector2()

func _ready():
	$anim.play("beam")
	
	dead_targs = get_tree().get_nodes_in_group("enemies")
	
	for d in dead_targs:
		d.connect("dead", self, "on_dead")

func _physics_process(delta):
	
	#Check to see if Tango has room to land.
	if position.y > player.position.y - 32 and $block_det.get_overlapping_bodies() == []:
		if !leave:
			$box.set_disabled(false)
	
	if !on_floor:
			velocity.y = BEAM_SPD
	else:
		if leave:
			velocity.y = -BEAM_SPD

	#Begin functions.
	if is_on_floor() and !on_floor:
		$anim.play("appear")
		on_floor = true
		
	if atk_time > 0 and on_floor:
		atk_time -=1
	
	#Get target and distance data.
	if on_floor and !attack:
		#Always clear the table before getting enemy position data.
		targets.clear()
		#Get coordinates.
		for e in (get_tree().get_nodes_in_group("enemies")):
			if !e.dead:
				var dist = e.global_position
				if !targets.has(dist):
					targets.append(dist)
		
		#Lock the attack position and proceed to attack.
		for atk in targets:
			atk = targets[atk].distance_to(global_position)
		
		print(targets.min(),', ',targets)
		
		attack = true
	
	#Begin attack if enemies are in an area.
	if attack and atk_time == 0 and !move:
		if targets != []:
			$anim.play("attack")
			$buzzsaw.play()
			move = true
			bounce()
	
	if move:
		if global_position.x < atk_pos and x_spd < MAX_X:
			x_spd += 7.5
			$sprite.flip_h = false
		if global_position.x > atk_pos and x_spd > -MAX_X:
			x_spd -= 7.5
			$sprite.flip_h = true
#	if is_on_floor() and move and sleep and !sleep_anim:
#		$anim.play("sleep_1")
#		x_spd = 0
#		sleep_anim = true
#
#	if on_floor and !attack:
#		get_targets()
#		#If no enemies are available, go to sleep.
#		if targets == []:
#			attack = false
#			sleep = true
#		if targets != [] and sleep:
#			sleep = false
#
#
#	if atk_time > 0:
#		atk_time -= 1
#
#	#Set nearest target and begin attack.
#	if atk_time == 0 and !sleep and !attack and !targets.has(atk_pos):
#		atk_pos = targets.min()
#		print(targets)
#		attack = true
#		$buzzsaw.play()
#		$anim.play("attack")
#
#	if attack:
#		if floor(global_position.x) < floor(global_position.x) + atk_pos.x and x_spd < MAX_X:
#			x_spd += 5
#		elif floor(global_position.x) > floor(global_position.x) + atk_pos.x and x_spd > -MAX_X:
#			x_spd -= 5
#
	if is_on_floor() and move:
		attack = false
		bounce()

	if reflect:
		attack = false
		bounce()

	velocity.y += GRAVITY * delta
	velocity.x = x_spd

	velocity = move_and_slide(velocity, Vector2(0, -1))

func bounce():
	bounce = rand_range(1, 4)
	velocity.y = JUMP * bounce
	if reflect:
		$dink.play()
		reflect = false
	else:
		$buzzsaw.play()

func _on_screen_exited():
	if leave:
		world.adaptors = 0
		queue_free()

#func on_dead():
#	targets.clear()
#	attack = false
#
#func get_targets():
#	#Clear current targets array to update enemy locations.
#	targets.clear()
#	#Check for enemies.
#	for e in (get_tree().get_nodes_in_group("enemies")):
#		if !e.dead:
#			var dist = Vector2(floor(e.global_position.x - global_position.x), floor(global_position.y - e.global_position.y))
#			targets.append(dist)


func _on_anim_finished(anim_name):
	match anim_name:
		"appear":
			if !leave:
				$meow.play()
				$anim.play("idle1")
			else:
				$anim.play("beam")
