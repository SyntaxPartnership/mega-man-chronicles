extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = world.get_child(2).get_child(8)

const BEAM_SPD = 400
const MAX_X = 100
const JUMP = -100
const GRAVITY = 900

var damage = 20

var reflect = false

var time = 240
var on_floor = false
var leave = false
var x_spd = 0
var dir = 0
var attack = false
var atk_pos = Vector2()
var atk_time = 120
var nearest
var dead_targs = []
var sleep = false
var bounce = 0
var move = false
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
	
	#Move Tango
	if !on_floor:
			velocity.y = BEAM_SPD
	else:
		if leave:
			velocity.y = -BEAM_SPD
	
	if attack:
		if x_spd != MAX_X * dir:
			x_spd += 10 * dir
	
	velocity.x = x_spd
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

	#Begin functions.
	if is_on_floor() and !on_floor:
		$anim.play("appear")
		on_floor = true
	
	#Subtract from the atk_time counter.
	if !sleep:
		if on_floor and atk_time > 0:
			atk_time -= 1
		
		if atk_time == 0 and !attack:
			get_target()
			if !sleep:
				attack = true
				$anim.play("attack")
				$buzzsaw.play()
				if is_on_floor():
					bounce()
					
		#Update atk_pos value for moving enemies.
		if attack:
			atk_pos = nearest.global_position
		
		if is_on_floor() and attack:
			bounce()
		
		if is_on_wall() and attack:
			x_spd *= -1
			dir *= -1
		
		if reflect and attack:
			bounce()
			reflect = false
		
func _on_screen_exited():
	pass

func bounce():
	
	bounce = rand_range(1, 4)
	
	velocity.y = JUMP * bounce
	
	#Only allow Tango to change directions during a bounce. Unless he comes into contact with a wall.
	if global_position.x > atk_pos.x:
		$sprite.flip_h = true
		dir = -1
	else:
		$sprite.flip_h = false
		dir = 1
	
	if !reflect:
		$buzzsaw.play()
	else:
		$dink.play()

func get_target():
	#Get enemy nodes
	var targets = get_tree().get_nodes_in_group("enemies")
	
	if targets != []:
	#Assume the first entry is the closest
		nearest = targets[0]
		
		#Check to see if the enemies are closer to the player, and if they are dead.
		for target in targets:
			if !target.dead:
				if target.global_position.distance_to(global_position) < nearest.global_position.distance_to(global_position):
					nearest = target
	else:
		print('No Moar Enemies')
		sleep = true
	
	print(nearest)

func on_dead():
	attack = false

func _on_anim_finished(anim_name):
	match anim_name:
		"appear":
			if !leave:
				$anim.play("idle1")
			else:
				$anim.play("beam")
