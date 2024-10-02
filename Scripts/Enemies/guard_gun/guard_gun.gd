extends Enemy

# Properties
@export var fire_rate : float
#@export var number_of_shots : int

# Funtional variables
var movement_direction : int
var player : CharacterBody2D

# State machine variables and references
@onready var states = $StateManager
@onready var idle = $StateManager/Idle
@onready var pace = $StateManager/Pace
@onready var alert = $StateManager/Alert
@onready var attack = $StateManager/Attack

# Scene references
@onready var animator = $Animator
@onready var sounds = $sounds
@onready var projectile_scene = preload("res://Scenes/Enemies/projectile.tscn")

var on_screen := false

func _ready() -> void:
	# Run ready function from inhereted script
	super._ready()
	
	# Initialize state manager, passing in self as parent entity
	states.init(self)
	
	# Face left by default
	movement_direction = -1

func _physics_process(delta: float) -> void:
	# Run physics process from inhereted script
	super._physics_process(delta)
	
	# Run state machine physics update
	states.physics_update(delta)
	
	# Calculate direction when player in range
	if player:
		if player.global_position.x - global_position.x > 0:
			movement_direction = 1
		else:
			movement_direction = -1
	
	# Flip sprite based on movement direction
	$Sprite.scale.x = -movement_direction
	$Range.scale.x = -movement_direction
	# Move spawn position to the correct side of the enemy
	$Spawn.position.x = -scale.x * -movement_direction

func shoot() -> void:
	if current_health > 0 and on_screen:
		# play sound
		sounds.play()
				
		# create instance of projectile
		var projectile = projectile_scene.instantiate()
				
		# set projectile properties
		projectile.movement_direction = Vector2(movement_direction, 0)
		projectile.speed = 750
		projectile.scale = Vector2(6, 6) # scaled to size of enemy [temporary]
		projectile.global_position = $Spawn.global_position
	
		# add to scene
		get_parent().add_child(projectile)

func _on_range_body_entered(body: Node2D) -> void:
	# If entering body is player, set variable true
	if body.is_in_group("Player"):
		player = body

func enable():
	states.reset()
	player = null
	super.enable()

func disable():
	states.reset()
	player = null
	super.disable()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	on_screen = false
