extends State

var end := false

func enter():
	super.enter()
	
	end = false
	await get_tree().create_timer(2).timeout
	end = true

func physics_update(delta : float):
	super.physics_update(delta)
	var move_dir = (entity.global_position - entity.player.global_position).normalized()
	entity.velocity = -move_dir * entity.max_speed * 3 * delta
	
	if end:
		return entity.reset

func exit():
	super.exit()
	entity.player = null


func _on_damage_component_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and entity.states.current_state == entity.dive:
		end = true
