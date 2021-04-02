tool
extends InteractionNode

"""

"""

# An array of node ids the options lead to.
export var option_paths : PoolIntArray
# An array of `InteractionOption` resources.
export var option_data : Array

func add_option(data : InteractionOption):
	option_paths.append(-1)
	option_data.append(data)


func remove_option():
	option_paths.remove(option_paths.size() - 1)
	option_data.pop_back()
