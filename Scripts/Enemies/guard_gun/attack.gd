extends State

var frames := 0

func enter() -> void:
	super.enter()
	
	frames = 0

func physics_update(delta : float):
	super.physics_update(delta)
	
	frames += 1
	
	if frames == 45:
			entity.shoot()
			frames = 0
	
	if abs(entity.player.global_position.x - entity.global_position.x) > 50:
		entity.velocity.x = entity.max_speed * 2 * entity.movement_direction * delta
	else:
		entity.velocity.x = 0
	
	if entity.player == null:
		return entity.idle

func exit() -> void:
	super.exit()
