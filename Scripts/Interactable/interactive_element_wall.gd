extends Sprite2D

@export var activateyThing : Node2D
@export var id : int = 0
@export var sound : AudioStreamPlayer2D
@export var faceRight : bool

var lit = false
var otherTorches : Array[AnimatedSprite2D]
var particles = preload("res://Scenes/Interactable/breakable_particles.tscn")

func _ready() -> void:
	if (SaveManager.already_interacted(id)):
		lit = true
		$StaticBody2D.set_collision_layer_value(1, false)
		$breakySprite.visible = false
		if (activateyThing):
			activateyThing.skipToActivated()
	$breakySprite.flip_h = faceRight

func alight() -> bool:
	if (lit): return false
	lit = true
	$StaticBody2D.set_collision_layer_value(1, false)
	$breakySprite.visible = false
	check_if_all_lit()
	sound.play()
	
	var particly = particles.instantiate()
	particly.position = position
	add_sibling(particly)
	
	SaveManager.interact(id)
	return true

func check_if_all_lit():
	# if even one other torch isn't lit, return out of the function
	if (!lit): return
	for torch in otherTorches:
		if (!torch.lit): return
	
	# activate the door
	if (activateyThing):
		activateyThing.activate()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("break_wall")): alight()
