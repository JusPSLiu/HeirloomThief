extends State

# Functional variables
var frames : int

func enter() -> void:
	super.enter()
	
	frames = 0

func physics_update(delta : float):
	super.physics_update(delta)
	entity.velocity.x = 0
	entity.velocity.y = 0
	
	frames += 1
	
	# When timer ends
	if frames == 30:
		return entity.dive

func exit() -> void:
	super.exit()
