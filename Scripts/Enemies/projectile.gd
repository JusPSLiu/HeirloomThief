extends Area2D

# Properties
@export var speed : float

# Functional variables
var movement_direction : Vector2

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# move horizontally each frame
	position += speed * movement_direction * delta


func die_me():
	# Delete self when exiting screen
	call_deferred("free")


func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("enemy")):
		body.damage(1)
		die_me()
	elif (body.is_in_group("torch")):
		if (body.get_parent().alight()): die_me()
