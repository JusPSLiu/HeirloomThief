extends Enemy

@export var startFacingRight = true

# functional variables
var movement_direction : int

func _ready():
	# Run ready function from inhereted script
	super._ready()
	
	# Move left by default
	movement_direction = 1 if startFacingRight else -1

func _physics_process(delta: float) -> void:
	# Run physics process from inhereted script
	super._physics_process(delta)
	
	# Move in a direction on the x-axis
	velocity.x = max_speed * movement_direction * delta
	
	# Bounce off of walls
	if is_on_wall() and $RayCast2D.is_colliding():
		velocity.x = 0 # stop moving horizontally
		movement_direction *= -1 # reverse direction
	
	# Flip sprite based on movement direction
	$Sprite.scale.x = -movement_direction
	$RayCast2D.scale.x = -movement_direction

func enable():
	movement_direction = 1 if startFacingRight else -1
	super.enable()
