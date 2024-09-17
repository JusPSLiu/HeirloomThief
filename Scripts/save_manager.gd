extends Node

var current_health = 2
var current_gems = 0
var max_health = 4
var current_room = 0
var visited_rooms : PackedByteArray = [false,false,false,false,false,false,false,false,false,false]
var currfile = "" # the default name given to the file in the system
var currsavename = "" # the custom name by the user, less restrictive than windows
var powerstatus = [1, 0, 0, 0, 0]
var collectedGems : Dictionary = {}
var collectedHealth : Dictionary = {}
var interactedElements : Dictionary = {}
var respawn_point : Vector2 = Vector2(0,0)

enum Item {
	health = 0,
	gem = 1
}

## UPGRADE STUFF
func already_collected(type, id):
	if (type == Item.health):
		return (collectedHealth.has(id) && collectedHealth[id])
	else:
		return (collectedGems.has(id) && collectedGems[id])

func collect_item(type, id):
	if (type == Item.health):
		collectedHealth[id] = true
	else:
		collectedGems[id] = true
	save_game()
## INTERACTIVE STUFF
func already_interacted(id):
	return (interactedElements.has(id) && interactedElements[id])

func interact(type, id):
	interactedElements[id] = true
	save_game()


## FILE STUFF

func save_game():
	if (currfile != ""):
		var save_file = FileAccess.open("user://saves/"+currfile, FileAccess.WRITE)
		save_file.store_var({
			"savename" : currsavename,
			"respawn_point" : respawn_point,
			"current_health" : current_health,
			"current_gems" : current_gems,
			"max_health" : max_health,
			"powerstatus" : powerstatus,
			"collectedHealth" : collectedHealth,
			"collectedGems" : collectedGems,
			"interactedElements" : interactedElements,
			"visited_rooms" : visited_rooms
		})
		save_file.close()

func load_game(file):
	currfile = file
	var save_file = FileAccess.open("user://saves/"+currfile, FileAccess.READ)
	if (save_file != null):
		var data = save_file.get_var()
		currsavename = data['savename']
		powerstatus = data["powerstatus"] if data.has("powerstatus") else [1, 0, 0, 0, 0]
		respawn_point = data['respawn_point'] if (data.has("respawn_point")) else Vector2.ZERO
		visited_rooms = data['visited_rooms'] if (data.has("visited_rooms")) else [false]
		
		# Health and Gems in Inventory
		max_health = data["max_health"] if (data.has("max_health")) else 4
		current_health = data["current_health"] if (data.has("current_health")) else 2
		current_gems = data["current_gems"] if (data.has("current_gems")) else 0
		
		# Collected Items in World
		collectedHealth = data["collectedHealth"] if (data.has("collectedHealth")) else {}
		collectedGems = data["collectedGems"] if (data.has("collectedGems")) else {}
		interactedElements = data["interactedElements"] if (data.has("interactedElements")) else {}

func menu_load_file_details() -> Array[Dictionary]:
	var deer = DirAccess.open("user://saves/")
	var saveList : Array[Dictionary] = []
	if deer:
		deer.list_dir_begin()
		var file_name = deer.list_dir_begin()
		file_name = deer.get_next()
		
		# loop through every file in the directory
		while file_name != "":
			# Check if the file is .save
			if not deer.current_is_dir() and file_name.get_file().ends_with(".save"):
				var save_file = FileAccess.open("user://saves/"+file_name, FileAccess.READ)
				if (save_file != null):
					var data = save_file.get_var()
					if (data != null and data.has("savename")):
						# get data for title screen menu
						var save_name = data.savename
						var healthy = data.max_health
						var progress = data.powerstatus
						
						# search for where to put it
						var time = FileAccess.get_modified_time("user://saves/"+file_name)
						# using BINARY INSERTION SORT
						var a = 0
						var b = saveList.size()-1
						var m = a+((b-a)>>1)
						while (a <= b):
							if (time > saveList[m].time):
								b = m-1
								m = a+((b-a)>>1)
							elif (time < saveList[m].time):
								a = m+1
								m = a+((b-a)>>1)
							else: break
						m += 1 # make sure its inserted JUST AFTER that index 
						# reformat save data like this. because i said so.
						var newdict = {
							'file_name' : file_name,
							'save_name' : save_name,
							'health' : healthy,
							'progress' : progress,
							'time' : time
						}
						# insert if in middle, otherwise push_back
						if m >= saveList.size():
							saveList.push_back(newdict)
						else: saveList.insert(m, newdict)
			file_name = deer.get_next() # get next file name in the deerectory
	return saveList

func make_new_file(newname):
	# assign name
	currsavename = newname
	# reset to default values
	respawn_point = Vector2.ZERO
	current_gems = 0
	current_health = 4
	max_health = 4
	current_room = 0
	visited_rooms = [false, false, false]
	powerstatus = [1, 0, 0, 0, 0]
	collectedGems = {}
	collectedHealth = {}
	interactedElements = {}
	# make new file name so you dont overwrite a previous file
	currfile = "HeirloomSave-"
	var number = 0
	while (FileAccess.file_exists("user://saves/"+currfile+str(number)+".save")):
		number += 1
	currfile += str(number)+".save"
	
	# make sure the saves folder exists
	if (!DirAccess.open("user://saves")):
		DirAccess.open("user://").make_dir("saves")
	
	save_game()


func delete_file(deleteName):
	if (FileAccess.file_exists("user://saves/"+deleteName)):
		DirAccess.remove_absolute("user://saves/"+deleteName)
		return true
	return false
