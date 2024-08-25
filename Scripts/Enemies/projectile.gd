extends Area2D

# Properties
@export var speed : float

# Functional variables
var movement_direction

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# move horizontally each frame
	position.x += speed * movement_direction * delta


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	# Delete self when exiting screen
	call_deferred("free")
