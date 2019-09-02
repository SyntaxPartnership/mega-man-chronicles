extends KinematicBody2D

onready var world = get_parent().get_parent()
onready var player = world.get_child(2)
onready var p_sprite = player.get_child(3)

const SPEED = 300

var reflect = false

var velocity = Vector2()

func _ready():
	#Change the sound effect to whatever is needed.
	$audio/shoot.play()
	
	#Set direction if necessary
	if p_sprite.flip_h:
		$sprite.flip_h = true

func _physics_process(delta):
	
	if !reflect:
		if $sprite.flip_h:
			velocity.x = -SPEED
		else:
			velocity.x = SPEED
	else:
		if $sprite.flip_h:
			velocity.x = SPEED
		else:
			velocity.x = -SPEED
		
		velocity.y = -SPEED
	
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _on_screen_exited():
	world.shots -= 1
	queue_free()