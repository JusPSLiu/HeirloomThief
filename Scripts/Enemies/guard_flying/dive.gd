extends State


func enter():
	super.enter()

func physics_update(delta : float):
	super.physics_update(delta)
	
	entity.velocity.y = 50000 * delta
	
	if entity.is_on_floor():
		return entity.reset

func exit():
	super.exit()
	entity.player = null
