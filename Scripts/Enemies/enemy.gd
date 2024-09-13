class_name Enemy extends CharacterBody2D

# properties
@export var max_health : int
@export var max_speed : float
@export var gravity : float

@onready var startPos : Vector2 = position
@onready var healthBar : ColorRect = get_node("HealthBar/health")
@onready var soundGetHit : AudioStreamPlayer2D = get_node("hit")
@onready var soundDeath : AudioStreamPlayer2D = get_node("hit/die")

# functional variables
var current_health : int
var current_speed : int

const deathparticle = preload("res://Scenes/Enemies/enemy_death_effect.tscn")

func _ready() -> void:
	current_health = max_health
	
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
	respawn()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	set_physics_process(false)
	#soundPlayerNode.stop()
	

func damage(damage_val):
	current_health -= damage_val
	healthBar.size.x = max(0, (10*current_health/max_health))
	if (current_health <= 0):
		hide()
		$Timer.start()
		if (soundDeath):
			soundDeath.play()
		var deathy = deathparticle.instantiate()
		deathy.position = position + Vector2(0, -16)
		add_sibling(deathy)
	elif (soundGetHit):
		soundGetHit.play()

func respawn():
	position = startPos
	current_health = max_health
	healthBar.size.x = 10
	velocity = Vector2.ZERO
	show()
