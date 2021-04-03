extends Panel
class_name InteractionMenu

"""
An abstract panel that shows an `InteractionTree`

A simple implementation can be found here:
"../simple_interaction_menu/simple_interaction_menu.gd"
"""

# Emitted when an `EventMessage` is hit.
signal interaction_event(event)

var interaction : InteractionTree setget set_interaction
var current_options : OptionsNode
var visited_options : Dictionary

const OptionsNode = preload("../nodes/options_node.gd")
const MessageNode = preload("../nodes/message_node.gd")
const StartNode = preload("../nodes/start_node.gd")
const EndNode = preload("../nodes/end_node.gd")
const EventMessage = preload("../resources/event_message.gd")

func _enter_tree() -> void:
	# Because this node might be added too late to be notified of all
	# `InteractionTrigger`s, we also connect to all nodes in the
	# `InteractionTriggers` group.
	for trigger in get_tree().get_nodes_in_group("InteractionTriggers"):
		trigger.connect("triggered", self, "_on_InteractionNode_triggered",
				[trigger])
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")


func set_interaction(to : InteractionTree) -> void:
	interaction = to
	if not interaction in visited_options:
		visited_options[interaction] = {}
	clear()
	show_node(0)


# Show the options of an `OptionsNode`.
func show_options(options : OptionsNode) -> void:
	current_options = options
	if not current_options in visited_options:
		visited_options[current_options] = []


# The next message/option node has to be shown by the implementation with
# `show_node` to allow for confirmation or delay based continuation.
func show_message(message : MessageNode) -> void:
	if message.data is EventMessage:
		emit_signal("interaction_event", message.data.text)


# End nodes have no special data by default, but the interaction panel should
# pause on an end node to make it possible to read the previous message.
func show_end(end : EndNode) -> void:
	end_interaction()


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


# Use this to determine if already visited options should be usable or not.
func visited_option(option_node : OptionsNode, option : int) -> bool:
	return option_node in visited_options and option in visited_options[option_node]


# Call this when the user selects an option.
func option_selected(option : int) -> void:
	visited_options[current_options].append(option)
	show_node(current_options.option_paths[option])


# Called when the interaction came to an end.
func end_interaction() -> void:
	clear()


# Clears the interaction panel. Called when a new interaction starts or ends.
func clear() -> void:
	current_options = null


func _on_SceneTree_node_added(node : Node) -> void:
	if node is InteractionTrigger:
		node.connect("triggered", self, "_on_InteractionNode_triggered", [node])


func _on_InteractionNode_triggered(node : InteractionTrigger) -> void:
	set_interaction(node.interaction)
