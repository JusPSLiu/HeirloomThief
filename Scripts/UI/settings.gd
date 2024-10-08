extends Label

@export var sound : AudioStreamPlayer
@export var soundSlider : HSlider
@export var musicSlider : HSlider
@onready var fullScreenButton = $MenuContainer/fullscreenButton

func _ready():
	#make music and sound variables
	var musicVolume : float = AudioServer.get_bus_volume_db(2)
	var soundVolume : float = AudioServer.get_bus_volume_db(1)
	#set to music and sound variables iff not null
	if (musicVolume != null):
		musicSlider.value = (db_to_linear(musicVolume))
	if (soundVolume != null):
		soundSlider.value = (db_to_linear(soundVolume))
	
	# remove fullscreen button from web export
	if (OS.get_name() == "Web"):
		fullScreenButton.hide()
	else:
		fullScreenButton.set_pressed_no_signal(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_sound_slider_value_changed(value):
	if (!sound.playing and int(value) != int(db_to_linear(AudioServer.get_bus_volume_db(1)))):
		sound.play()
	AudioServer.set_bus_volume_db(1, linear_to_db(value))


func full_screen(on) -> void:
	if (on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
