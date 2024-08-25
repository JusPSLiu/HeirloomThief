extends State

func enter() -> void:
	super.enter()
	
	while entity.player:
		await get_tree().create_timer(1).timeout
		entity.shoot(3)

func physics_update(delta : float):
	entity.velocity.x = entity.max_speed * entity.movement_direction * delta
	
	if entity.player == null:
		return entity.idle

func exit() -> void:
	super.exit()
