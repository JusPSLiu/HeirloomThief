extends State

# Functional variables
var done : bool

func enter() -> void:
	super.enter()
	
	# create timer and wait for it to timeout
	done = false
	await get_tree().create_timer(0.75).timeout
	# set variable to keep track of timer
	done = true

func physics_update(delta : float):
	super.physics_update(delta)
	entity.velocity.x = 0
	entity.velocity.y = 0
	
	# When timer ends
	if done:
		return entity.dive

func exit() -> void:
	super.exit()
