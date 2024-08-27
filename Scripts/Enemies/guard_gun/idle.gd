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
	
	# change state to alert if player enters range
	if entity.player:
		return entity.alert
	
	# change state to pace when timer ends
	if done:
		return entity.pace

func exit() -> void:
	super.exit()
