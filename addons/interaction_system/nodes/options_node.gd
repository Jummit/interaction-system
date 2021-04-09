tool
extends InteractionNode

"""
A node that shows a list of options
"""

# An array of `InteractionOption` resources.
export var option_data : Array

func add_option(data : InteractionOption, pos := option_data.size()):
	paths.insert(pos, -1)
	option_data.insert(pos, data)


func remove_option(option : int):
	paths.remove(option)
	option_data.remove(option)


func move_option(option : int, to : int) -> void:
	var old_data := option_data.duplicate()
	var old_paths := Array(paths)
	paths = []
	option_data.clear()
	for i in old_paths.size():
		if i == to:
			option_data.append(old_data[option])
			paths.append(old_paths[option])
		if i != option:
			option_data.append(old_data[i])
			paths.append(old_paths[i])
	if to >= old_paths.size():
		option_data.append(old_data[option])
		paths.append(old_paths[option])
