extends ColorRect


@export var musicFader : AnimationPlayer
@export var Fader : AnimationPlayer
@export var TitleAnimator : AnimationPlayer
@export var buttonSound : AudioStreamPlayer
@export var filename : LineEdit
@export var saveListContainer : VBoxContainer
@export var confirmDeleteFilename : Label

@onready var focusDummy = $dummy

var waiting : bool = false
var save_data = preload("res://Scenes/Screens/UIElements/game_1.tscn")
var deleteData = {}

# checks if anything is focused; for controller users
var unfocused : bool = true
var currentMenu : int = 0
enum menu {
	main=0,
	file=1,
	namefile=2,
	delete=3,
	settings=4
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var save_files = SaveManager.menu_load_file_details()
	for file in save_files:
		var new_save = save_data.instantiate()
		saveListContainer.add_child(new_save)
		new_save.set_self(file, self)
		new_save.set_focus_neighbor(SIDE_LEFT, NodePath("../../../Return"))

# controller inputs
func _input(event: InputEvent) -> void:
	if (unfocused and event is not InputEventMouse):
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			unfocused = false
			match currentMenu:
				menu.main:
					$maintitle/PlayButton.grab_focus()
				menu.file:
					$FileMenu/game1.grab_focus()
				menu.namefile:
					$nameFile/LineEdit.grab_focus()
				menu.delete:
					$DeletionConfirmation/goback.grab_focus()
				menu.settings:
					$Settings/MenuContainer/MusicSlider.grab_focus()

func playButtonPressed():
	if !waiting:
		focusDummy.grab_focus()
		waiting = true
		buttonSound.play()
		TitleAnimator.play("select")
		currentMenu = menu.file
		unfocused = true
		await TitleAnimator.animation_finished
		waiting = false


func _on_files_return_pressed():
	if !waiting:
		focusDummy.grab_focus()
		waiting = true
		buttonSound.play()
		currentMenu = menu.main
		unfocused = true
		TitleAnimator.play("deselect")
		await TitleAnimator.animation_finished
		waiting = false

# loading a prior file
func _on_files_pressed(arg):
	if !waiting:
		focusDummy.grab_focus()
		waiting = true
		buttonSound.play()
		musicFader.play("fadeMusicOut")
		Fader.play("FadeOut")
		SaveManager.load_game(arg)
		await Fader.animation_finished
		get_tree().change_scene_to_file("res://Scenes/Screens/loading_shaders.tscn")

func resumeGame():
	get_tree().change_scene_to_file("res://Scenes/Screens/loading_shaders.tscn")



# creating a new file
func _on_new_game_pressed() -> void:
	if !waiting:
		focusDummy.grab_focus()
		waiting = true
		buttonSound.play()
		currentMenu = menu.namefile
		unfocused = true
		if ($nameFile/LineEdit.text == ''):
			$nameFile/LineEdit.text = "Everild"
		TitleAnimator.play("makenewfile")
		await TitleAnimator.animation_finished
		waiting = false

func _on_newgame_return_pressed():
	if !waiting:
		focusDummy.grab_focus()
		waiting = true
		buttonSound.play()
		currentMenu = menu.file
		unfocused = true
		TitleAnimator.play("unmakenewfile")
		await TitleAnimator.animation_finished
		waiting = false

func make_new_file(_e=''):
	if !waiting:
		focusDummy.grab_focus()
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
		focusDummy.grab_focus()
		waiting = true
		buttonSound.play()
		currentMenu = menu.delete
		unfocused = true
		if (data['save_name']):
			confirmDeleteFilename.text = str(data['save_name'])+"?"
		deleteData = data
		TitleAnimator.play("are_you_sure")
		await TitleAnimator.animation_finished
		waiting = false

func dont_delete_file():
	if !waiting:
		focusDummy.grab_focus()
		waiting = true
		buttonSound.play()
		currentMenu = menu.file
		unfocused = true
		TitleAnimator.play("unsure")
		await TitleAnimator.animation_finished
		waiting = false


func YES_delete_file() -> void:
	if !waiting:
		focusDummy.grab_focus()
		waiting = true
		if (SaveManager.delete_file(deleteData['file_name'])):
			for button in saveListContainer.get_children():
				if (button.my_file_name == deleteData['file_name']):
					saveListContainer.remove_child(button)
					break
		buttonSound.play()
		currentMenu = menu.file
		unfocused = true
		TitleAnimator.play("unsure")
		await TitleAnimator.animation_finished
		waiting = false


func _toggle_settings():
	focusDummy.grab_focus()
	unfocused = true
	buttonSound.play()
	$maintitle.visible = !$maintitle.visible
	$Settings.visible = !$maintitle.visible
	if ($Settings.visible):
		currentMenu = menu.settings
	else: currentMenu = menu.main

func full_screen(on):
	if (on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
