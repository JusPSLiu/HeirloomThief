extends Control

@export var splashscreenVideo : VideoStreamPlayer
@export var transitionToBlack : AnimationPlayer
@export var buttonSound : AudioStreamPlayer
@export var SkipButton : AnimationPlayer
@export var howLongSkipButtonVisible : float = 1.2

var skipTimer : float = 0;
var skipVisible : bool = false
var skipping : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if (skipTimer > 0):
		skipTimer -= delta
		if (skipTimer <= 0):
			skipTimer = 0
			SkipButton.play("skipDisappear")
			skipVisible = false

func _on_video_stream_player_finished():
	get_tree().change_scene_to_file("res://Scenes/Screens/TitleScreen.tscn")
	pass # Replace with function body.

func _input(event : InputEvent):
	if (event.is_action_pressed("pause")) or (event is InputEventMouseButton and event.is_double_click()):
		if (!skipping):
			skipping = true
			transitionToBlack.play("FadeOut")
			buttonSound.play()
			await transitionToBlack.animation_finished
			get_tree().change_scene_to_file("res://Scenes/Screens/TitleScreen.tscn")
	elif (event is InputEventMouseMotion):
		#play animation only if not already visible
		if (!skipVisible):
			SkipButton.play("skipAppear")
		#set timer for skip to disappear for howLongSkipButtonVisible seconds
		skipTimer = howLongSkipButtonVisible
		skipVisible = true
