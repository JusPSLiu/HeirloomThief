extends State

# Functional variables
var done : bool

func enter() -> void:
	super.enter()
	
	# turn around
	entity.movement_direction *= -1
	
	# create timer and wait for it to timeout
	done = false
	await get_tree().create_timer(2).timeout
	# set variable to keep track of timer
	done = true

func physics_update(delta : float):
	entity.velocity.x = entity.max_speed * entity.movement_direction * delta
	
	# change state to alert if player enters range
	if entity.player:
		return entity.alert
	
	# change state to idle when timer ends
	if done:
		return entity.idle

func exit() -> void:
	super.exit()
