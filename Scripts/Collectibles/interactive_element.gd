extends AnimatedSprite2D

@export var activateyThing : Area2D
@export var id : int = 0
var lit = false

func _ready() -> void:
	if (SaveManager.already_interacted(id)):
		lit = true
		play('on')
		$torchlight.energy = 1
		activateyThing.skipToActivated()

func alight() -> bool:
	if (lit): return false
	lit = true
	play('on')
	$torchlight.energy = 1
	if (activateyThing):
		activateyThing.activate()
	return true
