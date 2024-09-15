class_name Enemy extends CharacterBody2D

# properties
@export var max_health : int
@export var max_speed : float
@export var gravity : float
@export var damage_component : Area2D

@onready var startPos : Vector2 = position
@onready var healthBar : ColorRect = get_node("HealthBar/health")
@onready var soundGetHit : AudioStreamPlayer2D = get_node("hit")
@onready var soundDeath : AudioStreamPlayer2D = get_node("hit/die")

# functional variables
var current_health : int
var current_speed : int
var home_area : int = -1

const deathparticle = preload("res://Scenes/Enemies/enemy_death_effect.tscn")

func _ready() -> void:
	current_health = max_health


func _physics_process(delta: float) -> void:
	# Gravity
	velocity.y += gravity * delta
	
	
	# Collision
	move_and_slide()

func enable():
	set_physics_process(true)
	set_collision_layer_value(1, true)
	if (damage_component):
		damage_component.process_mode = Node.PROCESS_MODE_INHERIT
	respawn()


func disable():
	hide()
	set_physics_process(false)
	set_collision_layer_value(1, false)
	if (damage_component):
		damage_component.process_mode = Node.PROCESS_MODE_DISABLED

func damage(damage_val):
	current_health -= damage_val
	healthBar.size.x = max(0, (10*current_health/max_health))
	if (current_health <= 0):
		if (soundDeath):
			soundDeath.play()
		var deathy = deathparticle.instantiate()
		deathy.position = position + Vector2(0, -16)
		add_sibling(deathy)
		disable()
	elif (soundGetHit):
		soundGetHit.play()

func respawn():
	position = startPos
	current_health = max_health
	healthBar.size.x = 10
	velocity = Vector2.ZERO
	show()
