tool
extends Control

"""
The editor used to edit `InteractionTree`s in the Engine
"""

signal resource_edited(resource)

var undo_redo : UndoRedo
var interaction : InteractionTree setget set_interaction
var copied_nodes : Array
var copy_offset : Vector2
var connecting_from := -1
var from_position : Vector2
var from_port := -1
var selecting_back_target_for : JumpNode

var action_graph_node := preload("action_graph_node.tscn")
var option_graph_node := preload("option_graph_node.tscn")
var comment_graph_node := preload("comment_graph_node.tscn")
var start_graph_node := preload("start_graph_node.tscn")
var end_graph_node := preload("end_graph_node.tscn")
var condition_graph_node := preload("condition_graph_node.tscn")
var jump_graph_node := preload("jump_graph_node.tscn")

const ActionNode = preload("../nodes/action_node.gd")
const OptionsNode = preload("../nodes/options_node.gd")
const EndNode = preload("../nodes/end_node.gd")
const CommentNode = preload("../nodes/comment_node.gd")
const CommentGraphNode = preload("comment_graph_node.gd")
const StartNode = preload("../nodes/start_node.gd")
const JumpNode = preload("../nodes/jump_node.gd")
const ConditionNode = preload("../nodes/condition_node.gd")
const Message = preload("../resources/message.gd")
const Event = preload("../resources/event.gd")
const StateChange = preload("../resources/state_change.gd")

onready var graph_edit : GraphEdit = $GraphEdit
onready var add_node_menu : PopupMenu = $AddNodeMenu

func apply_changes():
	pass


func can_drop_data(_position : Vector2, data) -> bool:
	if data is Dictionary and "files" in data:
		var resource := load(data.files[0])
		return resource is Script and\
				(resource.new() is InteractionActionData or\
				resource.new() is InteractionOption)
	return false


func drop_data(position : Vector2, data) -> void:
	var node_data : Resource = load(data.files[0]).new()
	var node : InteractionNode
	if node_data is InteractionActionData:
		node = ActionNode.new()
		node.data = node_data
	elif node_data is InteractionOption:
		node = OptionsNode.new()
		node.add_option(node_data)
	undo_redo.create_action("Drop Node")
	var id := interaction.get_available_id()
	undo_redo.add_do_method(self, "add_node", node, id,
			position + graph_edit.scroll_offset)
	undo_redo.add_undo_method(self, "remove_node", id)
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func set_interaction(to):
	interaction = to
	update_graph()


func add_node(node : InteractionNode, id : int, position : Vector2) -> void:
	node.position = position
	interaction.nodes[id] = node


func remove_node(id : int) -> void:
	interaction.nodes.erase(id)


func add_comment(comment : CommentNode) -> void:
	interaction.comments.append(comment)


func remove_comment(comment : CommentNode) -> void:
	interaction.comments.erase(comment)


func move_node(node, to : Vector2) -> void:
	node.position = to


func connect_nodes(from : int, from_slot : int, to : int) -> void:
	interaction.nodes[from].paths[from_slot] = to


func disconnect_nodes(from : int, from_slot : int) -> void:
	interaction.nodes[from].paths[from_slot] = -1


# Add `GraphNode`s and connect them.
func update_graph() -> void:
	for node in graph_edit.get_children():
		if node is GraphNode:
			node.free()
	for comment in interaction.comments:
		var graph_node : GraphNode = comment_graph_node.instance()
		graph_edit.add_child(graph_node)
		graph_node.init(comment)
		graph_node.set_meta("comment", comment)
		graph_node.connect("comment_changed", self,
				"_on_CommentGraph_node_comment_changed", [comment])
		graph_node.connect("resize_request", self,
				"_on_CommentGraph_resize_request", [graph_node])
		graph_node.connect("dragged", self, "_on_GraphNode_dragged",
			[graph_node])
	for node_id in interaction.nodes:
		var node : InteractionNode = interaction.nodes[node_id]
		var graph_node : GraphNode
		if node is ActionNode:
			graph_node = action_graph_node.instance()
			graph_node.connect("message_edited", self,
					"_on_MessageGraphNode_message_edited", [node])
		elif node is OptionsNode:
			graph_node = option_graph_node.instance()
			graph_node.connect("option_edited", self,
					"_on_OptionGraphNode_option_edited", [node])
			graph_node.connect("option_added", self,
					"_on_OptionGraphNode_option_added", [node])
			graph_node.connect("option_removed", self,
					"_on_OptionGraphNode_option_removed", [node])
			graph_node.connect("option_moved", self,
					"_on_OptionGraphNode_option_moved", [node])
		elif node is StartNode:
			graph_node = start_graph_node.instance()
		elif node is EndNode:
			graph_node = end_graph_node.instance()
		elif node is ConditionNode:
			graph_node = condition_graph_node.instance()
			graph_node.connect("condition_edited", self,
					"_on_ConditionGraphNode_condition_edited", [node])
		elif node is JumpNode:
			graph_node = jump_graph_node.instance()
			graph_node.connect("target_clicked", self,
					"_on_BackGraphNode_target_clicked", [node])
		
		graph_node.offset = node.position
		graph_node.name = str(node_id)
		graph_edit.add_child(graph_node)
		if graph_node.get_script():
			graph_node.init(node)
		graph_node.connect("dragged", self, "_on_GraphNode_dragged",
			[graph_node])
	update_graph_connections()


# Update only the connections between `GraphNode`s.
func update_graph_connections() -> void:
	graph_edit.clear_connections()
	for node_id in interaction.nodes:
		var node : InteractionNode = interaction.nodes[node_id]
		for port in node.paths.size():
			var to_node = node.paths[port]
			if to_node == -1:
				continue
			graph_edit.connect_node(str(node_id), port, str(to_node), 0)


func _on_GraphEdit_popup_request(position: Vector2) -> void:
	add_node_menu.popup()
	add_node_menu.rect_position = position


func _on_AddNodeMenu_id_pressed(id : int) -> void:
	if id == 2:
		var node := CommentNode.new()
		node.position = graph_edit.scroll_offset + get_local_mouse_position()
		undo_redo.create_action("Add Comment")
		undo_redo.add_do_method(self, "add_comment", node)
		undo_redo.add_undo_method(self, "remove_comment", node)
	else:
		var new_node : InteractionNode
		match id:
			0:
				new_node = ActionNode.new()
				new_node.data = Message.new()
			1:
				new_node = OptionsNode.new()
				new_node.add_option(InteractionOption.new("Option 1"))
			3:
				new_node = EndNode.new()
			4:
				new_node = ConditionNode.new()
				new_node.condition = InteractionCondition.new()
			5:
				new_node = ActionNode.new()
				new_node.data = Event.new()
			6:
				new_node = ActionNode.new()
				new_node.data = StateChange.new()
			7:
				new_node = JumpNode.new()
		
		var new_id := interaction.get_available_id()
		
		undo_redo.create_action("Add Node")
		undo_redo.add_do_method(self, "add_node", new_node, new_id,
				from_position)
		undo_redo.add_undo_method(self, "remove_node", new_node)
		if connecting_from != -1:
			undo_redo.add_do_method(self, "connect_nodes", connecting_from,
					from_port, new_id)
			undo_redo.add_undo_method(self, "disconnect_nodes", connecting_from,
					from_port)
			connecting_from = -1
			from_port = -1
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_GraphEdit_connection_request(from : String, from_slot : int,
		to : String, _to_slot : int) -> void:
	undo_redo.create_action("Connect Nodes")
	undo_redo.add_do_method(self, "connect_nodes", int(from), from_slot, int(to))
	undo_redo.add_undo_method(self, "disconnect_nodes", int(from), from_slot)
	undo_redo.add_do_method(self, "update_graph_connections")
	undo_redo.add_undo_method(self, "update_graph_connections")
	undo_redo.commit_action()


func _on_GraphEdit_delete_nodes_request() -> void:
	undo_redo.create_action("Remove Node")
	for graph_node in graph_edit.get_children():
		if not graph_node is GraphNode or not graph_node.selected:
			continue
		if graph_node is CommentGraphNode:
			var comment : CommentNode = graph_node.get_meta("comment")
			undo_redo.add_do_method(self, "remove_comment", comment)
			undo_redo.add_undo_method(self, "add_comment", comment)
		else:
			var id := int(graph_node.name)
			if id == 0:
				# Don't delete the start node.
				continue
			var node : InteractionNode = interaction.nodes[id]
			undo_redo.add_undo_method(self, "add_node", node, id, node.position)
			undo_redo.add_do_method(self, "remove_node", id)
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_GraphEdit_begin_node_move() -> void:
	undo_redo.create_action("Move Nodes")


func _on_GraphNode_dragged(from : Vector2, to : Vector2,
		node : GraphNode) -> void:
	var node_data
	if node is CommentGraphNode:
		node_data = node.get_meta("comment")
	else:
		node_data = interaction.nodes[int(node.name)]
	undo_redo.add_do_method(self, "move_node", node_data, to)
	undo_redo.add_undo_method(self, "move_node", node_data, from)
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")


func _on_GraphEdit_end_node_move() -> void:
	undo_redo.commit_action()


func _on_GraphEdit_connection_to_empty(from : String, from_slot : int,
		release_position : Vector2) -> void:
	connecting_from = int(from)
	from_port = from_slot
	from_position = release_position + graph_edit.scroll_offset
	add_node_menu.popup()
	add_node_menu.rect_position = rect_global_position + release_position


func _on_GraphEdit_disconnection_request(from : String, from_slot : int,
		to : String, _to_slot: int) -> void:
	undo_redo.create_action("Disconnect Node")
	undo_redo.add_do_method(self, "disconnect_nodes", int(from), from_slot)
	undo_redo.add_undo_method(self, "connect_nodes", int(from), from_slot,
			int(to))
	undo_redo.add_do_method(self, "update_graph_connections")
	undo_redo.add_undo_method(self, "update_graph_connections")
	undo_redo.commit_action()


func _on_GraphEdit_paste_nodes_request() -> void:
	undo_redo.create_action("Paste Nodes")
	var offset := -copy_offset + get_local_mouse_position() +\
			graph_edit.scroll_offset
	for node_num in copied_nodes.size():
		var id : int = interaction.get_available_id() + node_num
		undo_redo.add_do_method(self, "add_node", copied_nodes[node_num], id,
				copied_nodes[node_num].position + offset)
		undo_redo.add_undo_method(self, "remove_node", id)
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_GraphEdit_copy_nodes_request() -> void:
	copied_nodes.clear()
	copy_offset = Vector2.INF
	for node in graph_edit.get_children():
		if node is GraphNode and node.selected:
			copy_offset.x = min(copy_offset.x, node.offset.x)
			copy_offset.y = min(copy_offset.y, node.offset.y)
			copied_nodes.append(interaction.nodes[int(node.name)].duplicate())


func _on_GraphEdit_duplicate_nodes_request() -> void:
	undo_redo.create_action("Duplicate Nodes")
	var next_id := interaction.get_available_id()
	for node in graph_edit.get_children():
		if node is GraphNode and node.selected:
			var duplicated = interaction.nodes[int(node.name)].duplicate()
			undo_redo.add_do_method(self, "add_node", duplicated, next_id,
					duplicated.position + Vector2.ONE * 10)
			undo_redo.add_undo_method(self, "remove_node", next_id)
			next_id += 1
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_MessageGraphNode_message_edited(node : ActionNode) -> void:
	emit_signal("resource_edited", node.data)


func _on_CommentGraph_node_comment_changed(to : String,
		comment : CommentNode) -> void:
	yield(get_tree(), "idle_frame")
	undo_redo.create_action("Edit Comment")
	undo_redo.add_do_property(comment, "text", to)
	undo_redo.add_undo_property(comment, "text", comment.text)
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_CommentGraph_resize_request(new_min_size : Vector2,
		node : GraphNode) -> void:
	undo_redo.create_action("Resize Comment")
	var comment : CommentNode = node.get_meta("comment")
	undo_redo.add_do_property(comment, "size", new_min_size)
	undo_redo.add_undo_property(comment, "size", comment.size)
	node.rect_min_size = new_min_size
	node.rect_size = Vector2(1, 1)
	undo_redo.commit_action()


func _on_OptionGraphNode_option_added(option : InteractionOption,
		node : OptionsNode) -> void:
	yield(get_tree(), "idle_frame")
	option.text = "Option " + str(node.paths.size() + 1)
	undo_redo.create_action("Add Option")
	undo_redo.add_do_method(node, "add_option", option)
	undo_redo.add_undo_method(node, "remove_option", node.paths.size())
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_OptionGraphNode_option_edited(option_num : int,
		node : OptionsNode) -> void:
	emit_signal("resource_edited", node.option_data[option_num])


func _on_OptionGraphNode_option_removed(option : int,
		node : OptionsNode) -> void:
	yield(get_tree(), "idle_frame")
	undo_redo.create_action("Remove Option")
	undo_redo.add_do_method(node, "remove_option", option)
	undo_redo.add_undo_method(node, "add_option", node.option_data.back(),
			option)
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_OptionGraphNode_option_moved(option : int, to : int,
		node : OptionsNode) -> void:
	yield(get_tree(), "idle_frame")
	undo_redo.create_action("Move Option")
	undo_redo.add_do_method(node, "move_option", option, to)
	undo_redo.add_undo_method(node, "move_option", to, option)
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_ConditionGraphNode_condition_edited(node : ConditionNode) -> void:
	emit_signal("resource_edited", node.condition)


func _on_BackGraphNode_target_clicked(node : JumpNode) -> void:
	selecting_back_target_for = node


func get_graph_node_at_pos(position : Vector2) -> GraphNode:
	for node in graph_edit.get_children():
		if node is GraphNode and node.get_rect().has_point(position):
			return node
	return null


func _on_GraphEdit_draw() -> void:
	if selecting_back_target_for:
		var graph_node := get_graph_node_at_pos(get_local_mouse_position())
		if graph_node:
			graph_edit.draw_rect(graph_node.get_rect(), Color.white, false, 3)


func _input(event: InputEvent) -> void:
	if not selecting_back_target_for:
		return
	if event is InputEventMouseButton and\
			event.pressed and event.button_index == BUTTON_LEFT:
		var graph_node := get_graph_node_at_pos(get_local_mouse_position())
		if graph_node:
			undo_redo.create_action("Set Go Back Target")
			undo_redo.add_do_property(selecting_back_target_for, "target",
					int(graph_node.name))
			undo_redo.add_undo_property(selecting_back_target_for, "target",
					selecting_back_target_for.target)
			undo_redo.add_do_method(self, "update_graph")
			undo_redo.add_undo_method(self, "update_graph")
			undo_redo.commit_action()
		selecting_back_target_for = null
	graph_edit.update()
