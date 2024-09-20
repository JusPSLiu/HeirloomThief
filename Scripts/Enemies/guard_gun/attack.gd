extends State

func enter() -> void:
	super.enter()
	
	while entity.player:
		await get_tree().create_timer(1.8).timeout
		entity.shoot(3)

func physics_update(delta : float):
	super.physics_update(delta)
	
	if abs(entity.player.global_position.x - entity.global_position.x) > 50:
		entity.velocity.x = entity.max_speed * 2 * entity.movement_direction * delta
	else:
		entity.velocity.x = 0
	
	if entity.player == null:
		return entity.idle

func exit() -> void:
	super.exit()
