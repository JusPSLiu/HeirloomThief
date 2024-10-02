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
	
	# When timer ends
	if frames == 60:
		# Check to see if player is still in range and change state accordingly
		if entity.player:
			return entity.attack
		else:
			return entity.pace

func exit() -> void:
	super.exit()
