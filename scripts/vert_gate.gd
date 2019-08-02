extends Node2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var camera = player.get_child(7)
onready var player_anim = player.get_child(4)

var open = false
var left = false
var right = false

func _ready():
	world.connect('close_gate', self, 'on_close_gate')

func _on_act_left_body_entered(body):
	#Stop player animation
	player_anim.stop()
	player.can_move = false
	open = true
	right = true
	player.gate = true
	
	#Open the gate.
	$anim.play('opening')

func _on_act_left_body_exited(body):
	right = false

func _on_anim_animation_finished(opening):
	if open and right:
		player_anim.play()
		camera.limit_left = world.center.x - (world.res.x / 2)
		camera.limit_right = world.center.x + (world.res.x / 2)
		world.scroll = true
		world.scroll_len = world.res.x
		world.cam_move = 4
		right = false
	
	if !open:
		world.scroll = false
		world.cam_move = 0
		world.emit_signal("scrolling")

func on_close_gate():
	if open:
		open = false
		player_anim.stop()
		$anim.play_backwards("opening")