extends State

var end := false

func enter():
	super.enter()
	end = false
	entity.telegraph_shoot()
	await get_tree().create_timer(1).timeout
	entity.shoot(5)
	await get_tree().create_timer(2).timeout
	end = true

func physics_update(delta: float):
	super.physics_update(delta)
	entity.velocity.x = 0
	if abs(entity.global_position.y - entity.starting_height) > 32:
		entity.velocity.y = lerpf(entity.velocity.y, 150, 5.0 * delta)
	else:
		entity.velocity.y = lerpf(entity.velocity.y, 0, 5.0 * delta)
	
	
	if end:
		return entity.idle

func exit():
	super.exit()
