extends Enemy

# Funtional variables
var movement_direction : int
var player : CharacterBody2D
var starting_height : float

# State machine variables and references
@onready var states = $StateManager
@onready var pace = $StateManager/Pace
@onready var alert = $StateManager/Alert
@onready var dive = $StateManager/Dive
@onready var reset = $StateManager/Reset

# Scene references
@onready var animator = $Animator

func _ready() -> void:
	# Run ready function from inhereted script
	super._ready()
	
	# Initialize state manager, passing in self as parent entity
	states.init(self)
	
	# Face left by default
	movement_direction = -1
	
	starting_height = global_position.y

func _physics_process(delta: float) -> void:
	# Run physics process from inhereted script
	super._physics_process(delta)
	
	# Run state machine physics update
	states.physics_update(delta)
	
	# Flip sprite based on movement direction
	$Sprite.scale.x = -movement_direction


func _on_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

func disable():
	states.reset()
	super.disable()
