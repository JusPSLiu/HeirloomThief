extends Node

var current_health  = 4
var max_health = 4
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
	var deer = DirAccess.open("res://saves/")
	var saveList : Array[Dictionary] = []
	if deer:
		deer.list_dir_begin()
		var file_name = deer.get_next()
		
		# loop through every file in the directory
		while file_name != "":
			# Check if the file is .save
			if not deer.current_is_dir() and file_name.get_file().ends_with(".save"):
				var save_file = FileAccess.open("user://saves/"+file_name, FileAccess.READ)
				if (save_file != null):
					var data = save_file.get_var()
					
					# get data for title screen menu
					var save_name = data['savename']
					var healthy = data['max_health']
					var progress = data["powerstatus"]
					
					# reformat it like this. because i said so.
					saveList.push_back({
						'file_name' : file_name,
						'save_name' : save_name,
						'health' : healthy,
						'progress' : progress
					})
	return saveList
