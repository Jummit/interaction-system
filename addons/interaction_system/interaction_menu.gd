extends Panel
class_name InteractionMenu

"""
An abstract panel that shows an interaction

A simple implementation can be found here:
"simple_interaction_menu/simple_interaction_menu.gd"
"""

# Emitted when an `Event` is hit.
signal interaction_event(event)
signal state_changed
signal item_received(item)

export var initial_state : Dictionary

var interaction : InteractionTree setget set_interaction
var current_options : OptionsNode
var visited_options : Dictionary
var interaction_count : Dictionary
var state := GlobalInteractionState.new()

const OptionsNode = preload("nodes/options_node.gd")
const ActionNode = preload("nodes/action_node.gd")
const StartNode = preload("nodes/start_node.gd")
const EndNode = preload("nodes/end_node.gd")
const JumpNode = preload("nodes/jump_node.gd")
const ConditionNode = preload("nodes/condition_node.gd")
const ItemAquirement = preload("resources/item_aquirement.gd")
const Event = preload("resources/event.gd")
const Message = preload("resources/message.gd")
const StateChange = preload("resources/state_change.gd")

func _enter_tree() -> void:
	# Because this node might be added too late to be notified of all
	# `InteractionTrigger`s, all nodes in the `InteractionTriggers` group are
	# connected too.
	for trigger in get_tree().get_nodes_in_group("InteractionTriggers"):
		trigger.connect("triggered", self, "_on_InteractionNode_triggered",
				[trigger])
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")
	state.state = initial_state


# Setting the interaction tree effectively starts the interaction.
func set_interaction(to : InteractionTree) -> void:
	clear()
	if not to in interaction_count:
		interaction_count[to] = 0
	interaction = to
	if not interaction in visited_options:
		visited_options[interaction] = {}
	var start_nodes := interaction.get_start_nodes()
	show_node(start_nodes[min(interaction_count[interaction],
			start_nodes.size() - 1)])


# Shows the options of an `OptionsNode`.
func show_options(options : OptionsNode) -> void:
	current_options = options
	if not current_options in visited_options:
		visited_options[current_options] = []


# Note: the implementation has to show the next node with `show_node` to allow
# for confirmation or delay based continuation.
func show_action_node(node : ActionNode) -> void:
	if node.data is Event:
		emit_signal("interaction_event", node.data.event)
	if node.data is StateChange:
		var script := GDScript.new()
		script.source_code = """extends GlobalInteractionState
func execute():
	state.%s""" % node.data.expression
		script.reload()
		var instance : GlobalInteractionState = script.new()
		instance.state = state.state
		instance.execute()
		state.state = instance.state
		emit_signal("state_changed")
	elif node.data is ItemAquirement:
		emit_signal("item_received", node.data.item)


# End nodes have no special data by default. The interaction panel should
# pause on an `EndNode` to make it possible to read the previous message.
func show_end(end : EndNode) -> void:
	end_interaction()


# Shows the node after the start node by default.
func show_start(start : StartNode) -> void:
	show_node(start.paths[0])


# Calls the `show_x` function based on the node type.
func show_node(node_num : int) -> void:
	var node : InteractionNode = interaction.nodes[node_num]
	if node is StartNode:
		show_start(node)
	elif node is OptionsNode:
		show_options(node)
	elif node is ActionNode:
		if node.data.condition_met(state):
			show_action_node(node)
		else:
			show_node(node.paths[0])
	elif node is ConditionNode:
		show_node(node.paths[int(not node.condition.is_met(state))])
	elif node is JumpNode:
		show_node(node.target)
	elif node is EndNode:
		show_end(node)


# Use this to determine if already visited options should be usable or not.
func visited_option(option_node : OptionsNode, option : int) -> bool:
	return option_node in visited_options and option in visited_options[option_node]


# Call this when the user selects an option.
func option_selected(option : int) -> void:
	if not current_options.option_data[option].repeatable:
		visited_options[current_options].append(option)
	show_node(current_options.paths[option])


# Called when the interaction came to an end.
func end_interaction() -> void:
	interaction_count[interaction] += 1
	clear()


# Clears the interaction panel. Called when a new interaction starts or ends.
func clear() -> void:
	current_options = null
	interaction = null


func save_state(path : String) -> void:
	var file := File.new()
	file.open(path, File.WRITE)
	file.store_string(to_json({
		state = state.state,
		visited_options = visited_options,
		interaction_count = interaction_count,
	}))


func load_state(path : String) -> void:
	var file := File.new()
	file.open(path, File.READ)
	var data : Dictionary = parse_json(file.get_as_text())
	state.state = data.state
	visited_options = data.visited_options
	interaction_count = data.interaction_count


func _on_SceneTree_node_added(node : Node) -> void:
	if node is InteractionTrigger:
		node.connect("triggered", self, "_on_InteractionNode_triggered", [node])


func _on_InteractionNode_triggered(node : InteractionTrigger) -> void:
	if not interaction:
		set_interaction(node.interaction)
