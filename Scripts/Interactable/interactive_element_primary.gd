extends AnimatedSprite2D

@export var activateyThing : Area2D
@export var id : int = 0

var lit = false
var otherTorches : Array[AnimatedSprite2D]

func _ready() -> void:
	for child in get_children():
		if child is AnimatedSprite2D and "primaryTorch" in child:
			child.primaryTorch = self
			otherTorches.append(child)
	if (SaveManager.already_interacted(id)):
		lit = true
		play('on')
		animation = 'on'
		set_animation('on')
		set_autoplay('on')
		
		$torchlight.energy = 1
		activateyThing.skipToActivated()
		for torch in otherTorches:
			torch.set_animation('on')
			torch.set_autoplay('on')

func alight() -> bool:
	if (lit): return false
	lit = true
	play('on')
	$torchlight.energy = 1
	check_if_all_lit()
	return true

func check_if_all_lit():
	# if even one other torch isn't lit, return out of the function
	if (!lit): return
	for torch in otherTorches:
		if (!torch.lit): return
	
	# activate the door
	if (activateyThing):
		activateyThing.activate()
		SaveManager.interact(id)
