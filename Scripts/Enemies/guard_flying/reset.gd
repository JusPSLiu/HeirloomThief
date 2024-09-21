extends State


func enter() -> void:
	super.enter()

func physics_update(delta : float):
	super.physics_update(delta)
	 
	entity.velocity.y = lerpf(entity.velocity.y, -15000 * delta, 5.0 * delta)
	entity.velocity.x = lerpf(entity.velocity.x, 0, 5.0 * delta)
	
	if abs(entity.global_position.y - entity.starting_height) < 2.0:
		return entity.pace

func exit():
	super.exit()
	entity.player = null
