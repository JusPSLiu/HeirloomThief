class_name Enemy extends CharacterBody2D

# properties
@export var max_health : int
@export var max_speed : float
@export var gravity : float

@onready var soundPlayerNode : AudioStreamPlayer2D = get_node("sounds")
@onready var startPos : Vector2 = position

# functional variables
var current_health : int
var current_speed : int
var soundEffects : AudioStreamPlaybackPolyphonic

const hit_sound = preload("res://Sounds/player/hitty.wav")
const death_sound = preload("res://Sounds/enemy/boom.wav")
const deathparticle = preload("res://Scenes/Enemies/enemy_death_effect.tscn")

func _ready() -> void:
	current_health = max_health
	## DEBUG
	# TODO: DELETE THIS. ITS JUST FOR TESTING PURPOSES
	# ITS PROBABLY FINE IF WE KEEP IT THO
	soundPlayerNode.stream = AudioStreamPolyphonic.new()
	soundPlayerNode.play()
	soundEffects = soundPlayerNode.get_stream_playback()
	
	# OKAY ACTUALLY DO DELETE THIS WHEN LEVELS ARE IMPLEMENTED.
	# ITS JUST TO TEST RESPAWNING
	$Timer.wait_time = 15.0  # Set the timer to 20 seconds
	$Timer.connect("timeout", respawn)


func _physics_process(delta: float) -> void:
	# Gravity
	velocity.y += gravity * delta
	
	
	# Collision
	move_and_slide()


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	set_physics_process(true)
	soundPlayerNode.stream = AudioStreamPolyphonic.new()
	soundPlayerNode.play()
	soundEffects = soundPlayerNode.get_stream_playback()
	respawn()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	set_physics_process(false)
	soundEffects.is_stream_playing(0)
	#soundPlayerNode.stop()
	

func damage(damage_val):
	current_health -= damage_val
	if (current_health < 0):
		hide()
		$Timer.start()
		if (soundEffects):
			soundEffects.play_stream(death_sound)
		var deathy = deathparticle.instantiate()
		deathy.position = position + Vector2(0, -16)
		add_sibling(deathy)
	elif (soundEffects):
		soundEffects.play_stream(hit_sound)

func respawn():
	position = startPos
	velocity = Vector2.ZERO
	show()
