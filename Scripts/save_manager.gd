extends Node

var current_health = 3
var current_gems = 2
var max_health = 8
var current_room = 0
var currfile = "" # the default name given to the file in the system
var currsavename = "" # the custom name by the user, less restrictive than windows
var powerstatus = [false, false, false, false]


func save_game():
	var save_file = FileAccess.open("user://saves/"+currfile, FileAccess.WRITE)
	save_file.store_var({
		"savename" : currsavename,
		"current_health" : current_health,
		"max_health" : max_health,
		"powerstatus" : powerstatus
	})
	save_file.close()

func load_game(file):
	currfile = file
	var save_file = FileAccess.open("user://saves/"+currfile, FileAccess.READ)
	if (save_file != null):
		var data = save_file.get_var()
		currsavename = data['savename']

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
	# reset to default valuess
	current_health  = 4
	max_health = 4
	current_room = 0
	powerstatus = [false, false, false, false]
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