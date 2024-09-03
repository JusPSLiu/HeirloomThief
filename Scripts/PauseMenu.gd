extends CanvasLayer

#@onready var optionsMenu : Control = get_parent().get_node("OptionsMenu")
@onready var sound : AudioStreamPlayer = get_parent().get_node("ButtonSound")

@export var musicPlayer : AudioStreamPlayer
@export var screenCover : ColorRect
@export var screenCoverAnimation : AnimationPlayer

var pausable : bool = false

func _ready():
	#optionsMenu.connect("close_settings", close_sound_settings)
	pausable = true
	pass

func _on_start_button_pressed():
	#sound.play() #TODO: fix sound
	$ColorRect.visible = false
	get_tree().paused = false

func _on_settings_button_pressed() -> void:
	#sound.play() #TODO: fix sound
	#optionsMenu.visible = true #TODO: add options menu
	visible = false

func _on_quit_button_pressed():
	#sound.play() #TODO: fix sound
	musicPlayer.fadeOut()
	#screenCover.show()
	#screenCoverAnimation.play("FadeToBlack") #TODO: fix fade animation
	#await(screenCoverAnimation.animation_finished)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Screens/TitleScreen.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.is_echo():
		if event.keycode == KEY_ESCAPE and pausable:
			if event.pressed:
				#sound.play() #TODO: fix sound
				$ColorRect.visible = !$ColorRect.visible
				get_tree().paused = !get_tree().paused
				
				#if unpausing then close the optionsmenu and open this menu for the next time paused
				if (!get_tree().paused):
					visible = true
					#optionsMenu.visible = false

func close_sound_settings():
	#sound.play() #TODO: fix sound
	visible = true

func set_pausability(pause : bool):
	pausable = pause
