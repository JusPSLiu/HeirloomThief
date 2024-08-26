class_name State extends Node2D

var entity
@export var auto_animate : bool 

# Called once when state is entered
func enter() -> void:
	# If the state manager's print states variable is true,
	# print the state name to console
	if get_parent().print_states:
		print(self.name)
	
	if auto_animate:
		entity.animator.play(str(self.name))

# Called eery frame of physics process
func physics_update(delta : float):
	pass

# Called once when state is exited
func exit() -> void:
	pass
