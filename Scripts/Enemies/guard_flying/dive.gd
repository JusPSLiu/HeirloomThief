extends State


func enter():
	super.enter()

func physics_update(delta : float):
	super.physics_update(delta)
	var move_dir = (entity.global_position - entity.player.global_position).normalized()
	entity.velocity = -move_dir * entity.max_speed * 2 * delta
	
	if entity.is_on_floor():
		return entity.reset

func exit():
	super.exit()
	entity.player = null
