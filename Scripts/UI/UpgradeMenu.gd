extends TextureRect

@export var buttonSounds : AudioStreamPlayer
@export var description : RichTextLabel
@export var buttons : Array[TextureButton]

var currMode = 0

func _ready():
	_select(0)

func _set_up():
	for i in range(4):
		if (SaveManager.powerstatus[i]):
			buttons[i].set_focus_mode(Control.FocusMode.FOCUS_ALL)
			buttons[i].set_disabled(false)
			#buttons[i].get_child(0).play(i)
		else:
			buttons[i].set_focus_mode(Control.FocusMode.FOCUS_NONE)
			buttons[i].set_disabled(true)

func _select(item: int) -> void:
	buttonSounds.play()
	currMode = item
	
	match(item):
		0:
			description.text = "me beatin stick. curt a see o me mum. back wen she was aroun an kickin. a littl airloom of me own. ad it from afore the mountain filled the sky with smoke. afore the (house_name) took over. theres wisperins ya see. they say (house_name) is workin on sumthin to fell even more o the grate famlies. sumthin even more poweful. might as well take some o there earlier spoils afore they finish. an ere i am"
		1:
			description.text = "i remember last time i saw this ere ring. ome was gone. just me left. on me own. ran to the ports of (port_name). the frost started. thought i wouldn make it when the light showed up. a great big bonfire started by a smol ring. never can foget that. course the (port_name) famly took it back. its theirs after all. then they fell and the (house_name) took it"
		2:
			description.text = "cape"
		3:
			description.text = "crown"


func upgrade() -> void:
	if (currMode > -1 && currMode < 5):
		if (SaveManager.current_gems >= 2 and SaveManager.powerstatus[currMode] < 2):
			# upgrade
			if (get_parent().get_parent().player_update_powerstatus(currMode)):
				buttonSounds.play()
				# takey gems
				SaveManager.current_gems -= 2
				get_parent().get_parent().update_gui()
