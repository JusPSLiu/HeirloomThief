extends Button

var my_file_name = ""
var rootNode = null

func set_self(data, rootParentNode):
	text = data['save_name']
	my_file_name = data['file_name']
	#data['healthy']
	#data['progress']
	
	rootNode = rootParentNode

func pressed():
	if (rootNode != null):
		rootNode._on_files_pressed(my_file_name)
