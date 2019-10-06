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
var atk_time = 60
var targets = []
var sleep = false
var bounce = 0
var hit = 120
var hit_reset = false
var velocity = Vector2()

func _ready():
	$anim.play("beam")
	$meow.play()

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
		for e in (get_tree().get_nodes_in_group("enemies")):
			if !e.dead:
				targets.append(Vector2(floor(e.global_position.x), floor(e.global_position.y)))
	
	if on_floor and !sleep:
		#Clear current targets array to update enemy locations.
		targets.clear()
		#Check for enemies.
		for e in (get_tree().get_nodes_in_group("enemies")):
			if !e.dead:
				targets.append(Vector2(floor(e.global_position.x), floor(e.global_position.y)))
		#If no enemies are available, go to sleep.
	
	if atk_time > -1:
		atk_time -= 1
		
	#Subtract from the hit timer.
	if hit > -1:
		hit -= 1
	
	#Set nearest target and begin attack.
	if atk_time == 0 and !attack and !targets.has(atk_pos):
		atk_pos = targets.min()
		attack = true
		$buzzsaw.play()
		$anim.play("attack")
	
	#If the target was destroyed, select next target.
	
	if attack:
		if global_position.x < atk_pos.x and x_spd < MAX_X:
			x_spd += 5
		elif global_position.x > atk_pos.x and x_spd > -MAX_X:
			x_spd -= 5
	
	if is_on_floor() and attack:
		bounce()
	
	if reflect:
		bounce()
	
	velocity.y += GRAVITY * delta
	velocity.x = x_spd
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if hit_reset:
		hit = 120
	
	print(hit)

func _on_anim_finished(anim_name):
	if anim_name == "appear":
		if !leave:
			$anim.play("idle1")
		else:
			$anim.play("beam")

func bounce():
	bounce = rand_range(1, 4)
	velocity.y = JUMP * bounce
	if reflect:
		$dink.play()
		reflect = false
	else:
		$buzzsaw.play()

func _on_screen_exited():
	pass

func _on_enemy_entered(body):
	hit_reset = true

func _on_enemy_exited(body):
	hit_reset = false
