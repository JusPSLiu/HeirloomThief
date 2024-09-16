extends ColorRect


@export var musicFader : AnimationPlayer
@export var Fader : AnimationPlayer
@export var TitleAnimator : AnimationPlayer
@export var buttonSound : AudioStreamPlayer
@export var filename : LineEdit
@export var saveListContainer : VBoxContainer
@export var confirmDeleteFilename : Label

var waiting : bool = false
var save_data = preload("res://Scenes/Screens/UIElements/game_1.tscn")
var deleteData = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var save_files = SaveManager.menu_load_file_details()
	for file in save_files:
		var new_save = save_data.instantiate()
		saveListContainer.add_child(new_save)
		new_save.set_self(file, self)


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
	if !waiting:
		waiting = true
		buttonSound.play()
		TitleAnimator.play("deselect")
		await TitleAnimator.animation_finished
		waiting = false

# loading a prior file
func _on_files_pressed(arg):
	if !waiting:
		waiting = true
		buttonSound.play()
		musicFader.play("fadeMusicOut")
		Fader.play("FadeOut")
		await Fader.animation_finished
		SaveManager.load_game(arg)
		get_tree().change_scene_to_file("res://Scenes/Screens/loading_shaders.tscn")

func resumeGame():
	get_tree().change_scene_to_file("res://Scenes/Screens/loading_shaders.tscn")



# creating a new file
func _on_new_game_pressed() -> void:
	if !waiting:
		waiting = true
		buttonSound.play()
		TitleAnimator.play("makenewfile")
		await TitleAnimator.animation_finished
		waiting = false

func _on_newgame_return_pressed():
	if !waiting:
		waiting = true
		buttonSound.play()
		TitleAnimator.play("unmakenewfile")
		await TitleAnimator.animation_finished
		waiting = false

func make_new_file():
	if !waiting:
		if (filename.text != ""):
			waiting = true
			buttonSound.play()
			musicFader.play("fadeMusicOut")
			Fader.play("FadeOut")
			SaveManager.make_new_file(filename.text)
			await Fader.animation_finished
			get_tree().change_scene_to_file("res://Scenes/Screens/loading_shaders.tscn")

# save file deletion
func delete_file(data):
	if !waiting:
		waiting = true
		buttonSound.play()
		if (data['save_name']):
			confirmDeleteFilename.text = str(data['save_name'])+"?"
		deleteData = data
		TitleAnimator.play("are_you_sure")
		await TitleAnimator.animation_finished
		waiting = false

func dont_delete_file():
	if !waiting:
		waiting = true
		buttonSound.play()
		TitleAnimator.play("unsure")
		await TitleAnimator.animation_finished
		waiting = false


func YES_delete_file() -> void:
	if !waiting:
		waiting = true
		if (SaveManager.delete_file(deleteData['file_name'])):
			for button in saveListContainer.get_children():
				if (button.my_file_name == deleteData['file_name']):
					saveListContainer.remove_child(button)
					break
		buttonSound.play()
		TitleAnimator.play("unsure")
		await TitleAnimator.animation_finished
		waiting = false


func _toggle_settings():
	buttonSound.play()
	$maintitle.visible = !$maintitle.visible
	$Settings.visible = !$maintitle.visible
