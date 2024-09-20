extends State

# Functional variables
var frame : int
var turn_around_frame : int = 180
var bob_frame : int = 30
var bob_dir := -1

var end := false

func enter() -> void:
	super.enter()
	frame = 0
	
	# turn around
	entity.movement_direction *= -1
	
	end = false
	await get_tree().create_timer(2).timeout
	end = true

func physics_update(delta : float):
	super.physics_update(delta)
	
	frame += 1
	
	entity.velocity.x = lerpf(entity.velocity.x, 0, 5.0 * delta)
	#entity.velocity.x = lerpf(entity.velocity.x, entity.max_speed * entity.movement_direction * delta, 5.0 * delta) 
	entity.velocity.y = lerpf(entity.velocity.y, 10000 * bob_dir * delta, 5.0 * delta)
	
	
	if frame == turn_around_frame:
		entity.movement_direction *= -1
		frame = 0
	
	if frame % bob_frame == 0:
		bob_dir *= -1
	
	# change state to alert if player enters range
	if end:
		return entity.proj_attack

func exit() -> void:
	super.exit()
