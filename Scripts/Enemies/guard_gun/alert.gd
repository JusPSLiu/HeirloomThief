extends State

# Functional variables
var done : bool

func enter() -> void:
	super.enter()
	
	# create timer and wait for it to timeout
	done = false
	await get_tree().create_timer(1).timeout
	# set variable to keep track of timer
	done = true

func physics_update(delta : float):
	entity.velocity.x = 0
	
	# When timer ends
	if done:
		# Check to see if player is still in range and change state accordingly
		if entity.player:
			return entity.attack
		else:
			return entity.pace

func exit() -> void:
	super.exit()
