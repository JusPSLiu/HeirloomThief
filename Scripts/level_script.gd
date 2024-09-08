extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if already collected health upgrade or gem upgrade, then DELETE FROM map
	if ($upgrades != null):
		for child in $upgrades.get_children():
			if child.is_in_group("health_upgrade"):
				if (SaveManager.already_collected(SaveManager.Item.health, child.id)):
					child.queue_free()
			elif child.is_in_group("gem_upgrade"):
				if (SaveManager.already_collected(SaveManager.Item.gem, child.id)):
					child.queue_free()
