extends ColorRect


@export var musicFader : AnimationPlayer
@export var Fader : AnimationPlayer
@export var TitleAnimator : AnimationPlayer
@export var buttonSound : AudioStreamPlayer
@export var filename : LineEdit
@export var saveListContainer : VBoxContainer

var waiting : bool = false
var save_data = preload("res://Scenes/Screens/UIElements/game_1.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	#var save_files = SaveManager.menu_load_file_details()
	#for file in save_files:
		var new_save = save_data.instantiate()
		saveListContainer.add_child(new_save)
		#new_save.set_self(file, self)
		new_save.set_self({'save_name' : "bob", 'file_name' : 'bob'}, self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func playButtonPressed():
	if !waiting:
		waiting = true
		buttonSound.play()
		TitleAnimator.play("select")
		await TitleAnimator.animation_finished
		waiting = false


func _on_files_return_pressed():
	buttonSound.play()
	TitleAnimator.play("deselect")


func _on_files_pressed(arg):
	if !waiting:
		waiting = true
		buttonSound.play()
		musicFader.play("fadeMusicOut")
		Fader.play("FadeOut")
		await Fader.animation_finished
		get_tree().change_scene_to_file("res://Scenes/Levels/level_template.tscn")

func resumeGame():
	get_tree().change_scene_to_file("res://Scenes/Levels/level_template.tscn")
