extends Node2D

# CONSTS
const particles = preload("res://Scenes/Player/particle_poof.tscn")
const hit_particles = preload("res://Scenes/Player/particle_poof_hit.tscn")

# Properties
@export var speed : float

# Functional variables
var movement_direction : Vector2 = Vector2(0, 4)
var hitSomething = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# move horizontally each frame
	position += speed * movement_direction * delta


func die_me():
	# puff
	var newpuff : CPUParticles2D
	if (hitSomething):
		newpuff = hit_particles.instantiate()
	else:
		newpuff = particles.instantiate()
	newpuff.set_direction(movement_direction)
	newpuff.position = position
	newpuff.emitting = true
	add_sibling(newpuff)
	
	# Delete self
	call_deferred("free")


func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("enemy")):
		body.damage(1)
		hitSomething = true
		die_me()
	elif (body.is_in_group("torch")):
		if (body.get_parent().alight()):
			hitSomething = true
			die_me()
