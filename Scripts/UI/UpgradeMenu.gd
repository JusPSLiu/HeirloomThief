extends TextureRect

@export var buttonSounds : AudioStreamPlayer
@export var description : RichTextLabel
@export var buttons : Array[TextureButton]
@export var upgradeButton : TextureButton

var currMode = 0

func _ready():
	_select(0)

func _set_up():
	for i in range(4):
		# set the selection background to only show up for the selected one
		if (i == currMode):
			buttons[i].get_child(1).show()
		else: buttons[i].get_child(1).hide()
		
		# disable uncollected item buttons
		if (SaveManager.powerstatus[i]):
			buttons[i].set_focus_mode(Control.FocusMode.FOCUS_ALL)
			buttons[i].set_disabled(false)
			buttons[i].get_child(0).show()
			buttons[i].get_child(0).play(str(clamp(SaveManager.powerstatus[i], 1, 2)))
		else:
			buttons[i].set_focus_mode(Control.FocusMode.FOCUS_NONE)
			buttons[i].set_disabled(true)
			buttons[i].get_child(0).hide()
	if (SaveManager.current_gems >= 2):
		upgradeButton.set_focus_mode(Control.FocusMode.FOCUS_ALL)
		upgradeButton.set_disabled(false)
		upgradeButton.set_focus_neighbor(SIDE_TOP, buttons[currMode].get_path())
	else:
		upgradeButton.set_focus_mode(Control.FocusMode.FOCUS_NONE)
		upgradeButton.set_disabled(true)

func _select(item: int) -> void:
	buttons[currMode].get_child(1).hide() # hide the outline of previous
	buttons[item].get_child(1).show() # show outline of next
	upgradeButton.set_focus_neighbor(SIDE_TOP, buttons[item].get_path()) # make the upgrade button let you select from there lol
	buttonSounds.play()
	currMode = item
	
	match(item):
		0:
			description.text = "me trusty beatin stick. curt a see o me mum. back wen she was aroun an kickin. a littl airloom of me own. ad it from afore the mountain filled the sky with smoke. afore the (house_name) took over. theres wisperins ya see. they say (house_name) is workin on sumthin to fell even more o the grate famlies. sumthin even more poweful. might as well take some o there earlier spoils afore they finish. an ere i am"
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
				# set the button icon
				buttons[currMode].get_child(0).play(str(clamp(SaveManager.powerstatus[currMode], 1, 2)))
				get_parent().get_parent().update_gui()
