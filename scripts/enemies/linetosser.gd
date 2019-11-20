extends KinematicBody2D

onready var world = get_parent().get_parent().get_parent()
onready var player = world.get_child(2)
onready var behind = world.get_child(1).get_child(1)
onready var front = world.get_child(1).get_child(2)

var start_pos = Vector2()

var dist

#Enemy HP.
const DEFAULT_HP = 40
var hp

#Damage enemy does to the player.
var touch = false
var damage = 40

#Other
var dead = false
var flash = false
var f_delay = 0

var begin = false
var state = 0
var toss = false

const JUMP_SPEED = -210
const GRAVITY = 900

var velocity = Vector2()

func _ready():
	pass

func _physics_process(delta):
	
	if dead:
		return
	
	#Begin movement.
	if !begin:
		if player.global_position > global_position and global_position.distance_to(player.global_position) < 128:
			$anim.play("shock")
			$shock.play()
			$sprite/shock.show()
			begin = true
	
	if begin:
		if velocity.y > 0 and state == 0:
			state = 1
			$anim.play("jump-front")
			behind.remove_child(self)
			front.add_child(self)
		
		if state == 1 and is_on_floor():
			$anim.play('throw')
			state = 2
		
		if $sprite.frame == 4 and !toss:
			$throw.play()
			toss = true
		
		if $sprite.frame != 4 and toss:
			toss = false
	
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_anim_finished(anim_name):
	
	if anim_name == "shock":
		$sprite/shock.hide()
		$anim.play("jump-back")
		velocity.y = JUMP_SPEED
	
	if anim_name == 'throw':
		if player.global_position < global_position:
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
		$anim.play("throw")
		
