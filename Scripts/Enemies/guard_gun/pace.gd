extends State

# Functional variables
var frames : int

func enter() -> void:
	super.enter()
	
	frames = 0

func physics_update(delta : float):
	super.physics_update(delta)
	
	frames += 1
	
	entity.velocity.x = entity.max_speed * entity.movement_direction * delta
	
	# change state to alert if player enters range
	if entity.player:
		return entity.alert
	
	if frames == 60 * 3:
		entity.movement_direction *= -1

func exit() -> void:
	super.exit()
