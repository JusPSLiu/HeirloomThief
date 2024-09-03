extends CanvasLayer

#@onready var optionsMenu : Control = get_parent().get_node("OptionsMenu")
@onready var sound : AudioStreamPlayer = get_node("ButtonSound")
@onready var main_menu : Control = get_node("BackColor/MainMenu")
@onready var settings_menu : Label = get_node("BackColor/Settings")
@onready var upgrade_menu : TextureRect = get_node("BackColor/Upgrades")
@onready var gem_number : Label = get_node("BackColor/heart_gem_display/display_gems/gems_num")
@onready var heart_number : Label = get_node("BackColor/heart_gem_display/display_hearts/hearts_num")
@onready var upgrade_available : TextureRect = get_node("BackColor/MainMenu/UpgradeAvailable")

@export var musicPlayer : AudioStreamPlayer
@export var Fader : AnimationPlayer
@export var soundSlider : HSlider
@export var musicSlider : HSlider

var pausable : bool = false

func _ready():
	pausable = true
	#make music and sound variables
	var musicVolume : float = AudioServer.get_bus_volume_db(2)
	var soundVolume : float = AudioServer.get_bus_volume_db(1)
	#set to music and sound variables iff not null
	if (musicVolume != null):
		musicSlider.value = (db_to_linear(musicVolume))
	if (soundVolume != null):
		soundSlider.value = (db_to_linear(soundVolume))
	#wait for opening transition to finish before allowing pausing
	await Fader.animation_finished
	pausable = true
	# make sure pause menu isnt visible
	$BackColor.visible = false

func _on_quit_button_pressed():
	sound.play() #TODO: fix sound
	#musicPlayer.fadeOut()
	Fader.play("FadeOut")
	await(Fader.animation_finished)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Screens/TitleScreen.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.is_echo():
		if event.keycode == KEY_ESCAPE and pausable:
			if event.pressed:
				togglePause()

func togglePause():
	sound.play()
	$BackColor.visible = !$BackColor.visible
	get_tree().paused = !get_tree().paused
	
	#if unpausing then close the optionsmenu and open this menu for the next time paused
	if (!get_tree().paused):
		main_menu.show()
		settings_menu.hide()
	else:
		#if pausing then make sure the display is right
		heart_number.text = str(int(SaveManager.max_health)>>1)
		gem_number.text = str(SaveManager.current_gems)
		upgrade_available.visible = (SaveManager.current_gems > 1)

func set_pausability(pause : bool):
	pausable = pause

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_sound_slider_value_changed(value):
	if (!sound.playing and value != (db_to_linear(AudioServer.get_bus_volume_db(1)))):
		sound.play()
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

#go to settings menu
func _to_settings_menu() -> void:
	sound.play()
	settings_menu.show()
	main_menu.hide()
	upgrade_menu.hide()

#go to upgrade menu
func _to_upgrade_menu() -> void:
	sound.play()
	upgrade_menu.show()
	settings_menu.hide()
	main_menu.hide()

#back to main pause menu
func _to_main_pause_menu():
	sound.play()
	main_menu.show()
	settings_menu.hide()
	upgrade_menu.hide()
