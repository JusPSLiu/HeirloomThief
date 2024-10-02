extends State

var frames : int
var done : bool

func enter():
	super.enter()
	
	done = false
	frames = 0

func physics_update(delta : float):
	super.physics_update(delta)
	var move_dir = (entity.global_position - entity.player.global_position).normalized()
	entity.velocity = -move_dir * entity.max_speed * 3 * delta
	
	frames += 1
	
	if frames == 120 or done == true:
		return entity.reset

func exit():
	super.exit()
	entity.player = null


func _on_damage_component_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and entity.states.current_state == entity.dive:
		done = true
