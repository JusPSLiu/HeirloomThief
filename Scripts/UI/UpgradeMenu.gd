extends TextureRect

const upgradePreviews = [
	preload("res://Art/UI/Pause/upgrades/items/imagetobetter_stick.png"),
	preload("res://Art/UI/Pause/upgrades/items/imagetobetter_ring.png"),
	preload("res://Art/UI/Pause/upgrades/items/imagetobetter_cape.png"),
	preload("res://Art/UI/Pause/upgrades/items/imagetobetter_crown.png")
]
const MAX_LVL = 2

@export var buttonSounds : AudioStreamPlayer
@export var description : RichTextLabel
@export var upgradePreview : TextureRect
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
	update_upgrade_button()

func update_upgrade_button():
	if (SaveManager.current_gems >= 2 and SaveManager.powerstatus[currMode] < MAX_LVL):
		upgradeButton.set_focus_mode(Control.FocusMode.FOCUS_ALL)
		upgradeButton.set_disabled(false)
		upgradeButton.modulate = Color(1, 1, 1, 1)
		upgradeButton.set_focus_neighbor(SIDE_TOP, buttons[currMode].get_path())
	else:
		upgradeButton.set_focus_mode(Control.FocusMode.FOCUS_NONE)
		upgradeButton.modulate = Color(1, 1, 1, 0.5)
		upgradeButton.set_disabled(true)

func _select(item: int) -> void:
	buttons[currMode].get_child(1).hide() # hide the outline of previous
	buttons[item].get_child(1).show() # show outline of next
	upgradeButton.set_focus_neighbor(SIDE_TOP, buttons[item].get_path()) # make the upgrade button let you select from there lol
	if (get_tree().paused && currMode != item): buttonSounds.play()
	currMode = item
	match(item):
		0:
			description.text = "me trusty beatin stick. curt a see o me mum. back wen she was aroun an kickin. a littl airloom of me own. ad it from afore the mountain filled the sky with smoke. afore the the beasleye famly took over. theres wisperins ya see. they say the beasleye famly is workin on sumfin to fell even more o the grate famlies. sumfin even more poweful. might as well take some o there earlier spoils afore they finish\n\nan ere i am"
		1:
			description.text = "i remember last time i saw this ere ring. ome was gone. just me left. on me own. ran to the ports of trowton. the frost started. thought i woodn make it when the light showed up. a great big bonfire started by a smol ring. never can foget that. course the trowton famly took it back. its theirs after all. didn think theyd take the time fo that but maby they was just continuin som tradishin\n\nthen they fell and the the beasleye famly took it\nwich then mustve dropt it an fogot about it"
		2:
			description.text = "this cape olways lookt comfy wen the pertwy famly took it aroun an showd it off. on me own an just left the broken ports of trowton i was. course the pertwy famly fell an i didn think i wood find out. now i hav it i see it reely is. it was ol the way out past the flaiming rocks. gues the flaiming mounten took the beasleye famly by suprise too. evrywon sed they was behind it wot wif the smoke in the sky but nay\n\nbut i do wonder wot those bars in the cave walls was for"
		3:
			description.text = "this right ere crown wot wif the fansy joowuls was wot i came ere for. "
	show_preview()


func upgrade() -> void:
	if (currMode > -1 && currMode < 5):
		if (SaveManager.current_gems >= 2 and SaveManager.powerstatus[currMode] < MAX_LVL):
			# upgrade
			if (get_parent().get_parent().player_update_powerstatus(currMode)):
				buttonSounds.play()
				# takey gems
				SaveManager.current_gems -= 2
				# set the button icon
				buttons[currMode].get_child(0).play(str(clamp(SaveManager.powerstatus[currMode], 1, 2)))
				get_parent().get_parent().update_gui()
				update_upgrade_button()
				show_preview()

func show_preview():
	if (SaveManager.powerstatus[currMode] < MAX_LVL):
		upgradePreview.show()
		upgradePreview.texture = upgradePreviews[currMode]
	else:
		upgradePreview.hide()
