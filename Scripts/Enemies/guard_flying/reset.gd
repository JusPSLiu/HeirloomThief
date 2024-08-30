extends State


func enter() -> void:
	super.enter()

func physics_update(delta : float):
	super.physics_update(delta)
	 
	entity.velocity.y = lerpf(entity.velocity.y, -10000 * delta, 5.0 * delta)
	
	if abs(entity.global_position.y - entity.starting_height) < 10.0:
		return entity.pace
