extends Label

@export var sound : AudioStreamPlayer
@export var soundSlider : HSlider
@export var musicSlider : HSlider

func _ready():
	#make music and sound variables
	var musicVolume : float = AudioServer.get_bus_volume_db(2)
	var soundVolume : float = AudioServer.get_bus_volume_db(1)
	#set to music and sound variables iff not null
	if (musicVolume != null):
		musicSlider.value = (db_to_linear(musicVolume))
	if (soundVolume != null):
		soundSlider.value = (db_to_linear(soundVolume))

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_sound_slider_value_changed(value):
	if (!sound.playing and value != (db_to_linear(AudioServer.get_bus_volume_db(1)))):
		sound.play()
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
