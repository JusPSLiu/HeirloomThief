extends CanvasLayer

#@onready var optionsMenu : Control = get_parent().get_node("OptionsMenu")
@onready var sound : AudioStreamPlayer = $ButtonSound
@onready var main_menu : Control = $BackColor/MainMenu
@onready var settings_menu : Label = $BackColor/Settings
@onready var upgrade_menu : TextureRect = $BackColor/Upgrades
@onready var gem_number : Label = $BackColor/heart_gem_display/display_gems/gems_num
@onready var heart_number : Label = $BackColor/heart_gem_display/display_hearts/hearts_num
@onready var upgrade_available : TextureRect = $BackColor/MainMenu/UpgradeAvailable
@onready var map = $BackColor/MainMenu/Map
@onready var fullScreenButton = $BackColor/Settings/MenuContainer/fullscreenButton

@export var musicPlayer : AudioStreamPlayer
@export var Fader : AnimationPlayer
@export var soundSlider : HSlider
@export var musicSlider : HSlider
@export var player : CharacterBody2D

var pauseReload = 0.1 # only pause after 0.1 seconds because i made esc and ` both pause
var pausable : bool = false
var unfocused : bool = true # checks if anything is focused; for controller users
var currentMenu : int = 0
enum menu {
	pause=0,
	upgrades=1,
	settings=2
}

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
	if (Fader):
		await Fader.animation_finished
	pausable = true
	# make sure pause menu isnt visible
	$BackColor.visible = false
	#update all gui elements
	update_gui()
	
	# remove fullscreen button from web export
	if (OS.get_name() == "Web"):
		fullScreenButton.hide()
	else:
		fullScreenButton.set_pressed_no_signal(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

func _process(delta: float) -> void:
	if pauseReload > 0:
		pauseReload -= delta

func _on_quit_button_pressed():
	sound.play() #TODO: fix sound
	#musicPlayer.fadeOut()
	Fader.play("FadeOut")
	await(Fader.animation_finished)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Screens/TitleScreen.tscn")

func _input(event: InputEvent) -> void:
	if (event is not InputEventMouse):
		if !event.is_echo():
			if event.is_action_pressed("pause") and pauseReload < 0:
				if event.pressed:
					togglePause()
					pauseReload = 0.1
			elif event.is_action_pressed("go_back"):
				if currentMenu != menu.pause:
					_to_main_pause_menu()
		if (unfocused):
			if (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right")):
				unfocused = false
				match(currentMenu):
					menu.pause:
						$BackColor/MainMenu/VBoxContainer/Resume.grab_focus()
					menu.settings:
						$BackColor/Settings/MenuContainer/MusicSlider.grab_focus()

func togglePause():
	if (pausable || get_tree().paused):
		sound.play()
		$BackColor.visible = !$BackColor.visible
		get_tree().paused = !get_tree().paused
		
		#if unpausing then close the optionsmenu and open this menu for the next time paused
		if (!get_tree().paused):
			main_menu.show()
			settings_menu.hide()
			#tell the map that if its clicking to stop. plz
			map.clicking = false
		else:
			#if pausing then make sure the display is right
			update_gui()
			#tell the map to set up
			#also make sure you start up in the main pause menu
			map.set_up()
			_to_main_pause_menu()

func update_gui():
	heart_number.text = str(int(SaveManager.max_health)>>1)
	gem_number.text = str(SaveManager.current_gems)
	upgrade_available.visible = (SaveManager.current_gems > 1 and SaveManager.powerstatus.has(1))
	$PauseButton/UpgradeAvailable.visible = upgrade_available.visible

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
	currentMenu = menu.settings
	sound.play()
	settings_menu.show()
	main_menu.hide()
	upgrade_menu.hide()
	map.mapIsShown = false
	unfocused = true

#go to upgrade menu
func _to_upgrade_menu() -> void:
	currentMenu = menu.upgrades
	sound.play()
	upgrade_menu.show()
	settings_menu.hide()
	main_menu.hide()
	map.mapIsShown = false
	$BackColor/Upgrades/UpgradeSelectors/Stick.grab_focus()
	$BackColor/Upgrades._set_up()

#back to main pause menu
func _to_main_pause_menu():
	currentMenu = menu.pause
	sound.play()
	main_menu.show()
	settings_menu.hide()
	upgrade_menu.hide()
	map.mapIsShown = true
	unfocused = true

func player_update_powerstatus(currMode):
	if (player):
		player.update_powerstatus(currMode)
		return true
	return false

func full_screen(on):
	if (on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
