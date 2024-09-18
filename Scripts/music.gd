extends AudioStreamPlayer

var currentMusic : String = ""
var musicLeftOff : Dictionary = {}

func transition_to_track(stringy):
	if (currentMusic != stringy):
		musicLeftOff[currentMusic] = get_playback_position()
		currentMusic = stringy
		if (volume_db > -70):
			$MusicAnimator.play("fadeOut")
		if ($MusicAnimator.is_playing()):
			await $MusicAnimator.animation_finished
		# make sure the player hasnt just passed through AGAIN since the audio started to fade out
		if (stringy != "|" and currentMusic == stringy):
			set_stream(load("res://Sounds/Music/"+stringy))
			if (musicLeftOff.has(stringy)):
				play(musicLeftOff[stringy])
			else: play()
			set_volume_db(0)
