extends State

# Functional variables
var frames : int

func enter() -> void:
	super.enter()
	
	frames = 0

func physics_update(delta : float):
	super.physics_update(delta)
	
	frames += 1
	
	entity.velocity.x = 0
	
	# change state to alert if player enters range
	if entity.player:
		return entity.alert
	
	# change state to pace when timer ends
	if frames == 60:
		return entity.pace

func exit() -> void:
	super.exit()
