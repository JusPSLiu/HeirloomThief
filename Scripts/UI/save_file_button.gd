extends TextureButton

var my_file_name = ""
var rootNode = null
var myData = {}

func set_self(data, rootParentNode):
	scale = Vector2(4, 4)
	$Label.text = data['save_name']
	my_file_name = data['file_name']
	#data['healthy']
	$Ring.visible = (data['progress'][1] > 0)
	$Cape.visible = (data['progress'][2] > 0)
	$Crown.visible = (data['progress'][3] > 0)
	
	rootNode = rootParentNode
	myData = data

func pressed():
	if (rootNode != null):
		rootNode._on_files_pressed(my_file_name)

func delete_pressed():
	if (rootNode != null):
		rootNode.delete_file(myData)


func _on_focus_entered() -> void:
	$DeleteButton.z_index = -1


func _on_focus_exited() -> void:
	$DeleteButton.z_index = 0
