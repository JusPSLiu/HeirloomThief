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
	entity.velocity = Vector2.ZERO
	
	if end:
		return entity.idle

func exit():
	super.exit()
