extends AnimatedSprite2D

@export var id : int = 0
@export var primaryTorch : AnimatedSprite2D

var lit = false

func _ready() -> void:
	if (SaveManager.already_interacted(id)):
		lit = true
		play('on')
		$torchlight.energy = 1
		if (primaryTorch):
			primaryTorch.check_if_all_lit()

func alight() -> bool:
	if (lit): return false
	lit = true
	play('on')
	$torchlight.energy = 1
	if (primaryTorch):
		primaryTorch.check_if_all_lit()
	return true
