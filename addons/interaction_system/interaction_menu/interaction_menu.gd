extends Panel
class_name InteractionMenu

"""
An abstract panel that shows an `InteractionTree`

A simple implementation can be found here:
"../simple_interaction_menu/simple_interaction_menu.gd"
"""

var interaction : InteractionTree setget set_interaction
# The options being show currently.
var current_options : OptionsNode

const OptionsNode = preload("../nodes/options_node.gd")
const MessageNode = preload("../nodes/message_node.gd")
const StartNode = preload("../nodes/start_node.gd")
const EndNode = preload("../nodes/end_node.gd")

func _enter_tree() -> void:
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")


func set_interaction(to : InteractionTree) -> void:
	interaction = to
	clear()
	show_node(0)


func show_options(options : OptionsNode) -> void:
	current_options = options


# The next message/option node has to be shown by the implementation with
# `show_node` to allow for confirmation or delay based continuation.
func show_message(message : MessageNode) -> void:
	pass


# End nodes have no special data by default, but the interaction panel should
# pause on an end node to make it possible to read the previous message.
# This is also the place to clean up after an interaction.
func show_end(end : EndNode) -> void:
	clear()


# This shows the node after the start node by default.
func show_start(start : StartNode) -> void:
	show_node(start.next)


# Call `show_options` or `show_message` based on the node type.
func show_node(node_num : int) -> void:
	var node : InteractionNode = interaction.nodes[node_num]
	if node is StartNode:
		show_start(node)
	elif node is OptionsNode:
		show_options(node)
	elif node is MessageNode:
		show_message(node)
	elif node is EndNode:
		show_end(node)


# Call this when the user selects an option.
func option_selected(option : int) -> void:
	show_node(current_options.option_paths[option])


# Clears the interaction panel. Called when a new interaction starts or ends.
func clear() -> void:
	current_options = null


func _on_SceneTree_node_added(node : Node) -> void:
	if node is InteractionTrigger:
		node.connect("triggered", self, "_on_InteractionNode_triggered", [node])


func _on_InteractionNode_triggered(node : InteractionTrigger) -> void:
	set_interaction(node.interaction)
