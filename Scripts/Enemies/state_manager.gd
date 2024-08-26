class_name StateManager extends Node2D

# Properties
@export var initial_state : State
@export var print_states : bool

# Functional variables
var entity
var current_state : State

# Call in ready function of parent entity
func init(parent_entity) -> void:
	# Set each state's entity variable to the parent entity
	for child in get_children():
		child.entity = parent_entity
	
	# Change state to initial state
	change_state(initial_state)

# Call in physics process of parent entity
func physics_update(delta : float) -> void:
	# When a state's physics update returns a state, change to that state
	var new_state = current_state.physics_update(delta)
	if new_state:
		change_state(new_state)

func change_state(new_state : State) -> void:
	# If a current state exists, call it's exit function, then reset the variable
	if current_state:
		current_state.exit()
		current_state = null
	
	# Set variable to the state passed in, then call it's enter function
	current_state = new_state
	current_state.enter()
