class_name Enemy extends CharacterBody2D

# properties
@export var max_health : int
@export var max_speed : float
@export var gravity : float

# functional variables
var current_health : int
var current_speed : int

func _ready() -> void:
	current_health = max_health


func _physics_process(delta: float) -> void:
	# Gravity
	velocity.y += gravity * delta
	
	
	# Collision
	move_and_slide()


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	set_physics_process(true)


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	set_physics_process(false)
