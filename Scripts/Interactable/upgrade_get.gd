extends Area2D

# ability 1 is ring
# ability 2 is cape
# ability 3 is crown
# ability 4 is grappling hook
@export var my_ability_id = 1
@export var animationplayer : AnimationPlayer
@export var activatey_thing : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (SaveManager.powerstatus[my_ability_id]):
		get_parent().hide()
		if (activatey_thing):
			activatey_thing.skipToActivated()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		body.get_ability(my_ability_id)
		if (animationplayer):
			animationplayer.play("collected")
		$AbilityEffect.set_emitting(false)
		await animationplayer.animation_finished
		get_parent().hide()
