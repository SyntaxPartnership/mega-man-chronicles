extends Node2D

onready var player = get_parent().get_parent().get_child(2)
onready var anim = player.get_child(4)
onready var fade = get_parent().get_parent().get_child(7).get_child(0)

var timer = 60

var active = true
var entered = false
var distance = 0

func _ready():
	player.connect('teleport', self, 'on_teleport')

func _physics_process(delta):
	if entered:
		distance = (floor(position.x) - floor(player.position.x)) + 8
		
		if player.is_on_floor() and distance < 3 and distance > -3 and !player.lock_ctrl:
			player.x_dir = 0
			player.lock_ctrl = true
			
		if player.lock_ctrl and timer > -1:
			timer -= 1
		
		if timer == 0:
			player.can_move = false
			anim.play('appear1')
			
func on_teleport():
	if timer <= 0:
		player.hide()
		fade.state = 2
		fade.end = true
		
func _on_area_body_entered(body):
	if !entered:
		entered = true

func _on_area_body_exited(body):
	if entered:
		entered = false
