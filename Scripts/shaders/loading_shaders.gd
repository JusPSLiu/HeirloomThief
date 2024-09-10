extends ColorRect

@export var particles : Array[CPUParticles2D]
var loadingTime = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadingTime = 0.5
	for particle in particles:
		particle.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	loadingTime -= delta
	if (loadingTime < 0):
		get_tree().change_scene_to_file("res://Scenes/Levels/new_level.tscn")
