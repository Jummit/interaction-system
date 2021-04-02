tool
extends Control

"""
The editor used to edit `InteractionTree`s in the Engine
"""

signal resource_edited(resource)

var undo_redo : UndoRedo
var interaction : InteractionTree setget set_interaction
var copied_nodes : Array
var connecting_from := -1
var from_port := -1

var message_graph_node := preload("message_graph_node.tscn")
var option_graph_node := preload("option_graph_node.tscn")
var comment_graph_node := preload("comment_graph_node.tscn")
var start_graph_node := preload("start_graph_node.tscn")
var end_graph_node := preload("end_graph_node.tscn")

const MessageNode = preload("../nodes/message_node.gd")
const OptionsNode = preload("../nodes/options_node.gd")
const EndNode = preload("../nodes/end_node.gd")
const CommentNode = preload("../nodes/comment_node.gd")
const CommentGraphNode = preload("comment_graph_node.gd")
const StartNode = preload("../nodes/start_node.gd")

onready var graph_edit : GraphEdit = $GraphEdit
onready var add_node_menu : PopupMenu = $AddNodeMenu

func apply_changes():
	pass


func set_interaction(to):
	interaction = to
	update_graph()


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
				new_node = MessageNode.new()
				new_node.data = InteractionMessage.new("Message")
			1:
				new_node = OptionsNode.new()
				new_node.add_option(InteractionOption.new("Option 1"))
			3:
				new_node = EndNode.new()
		
		var new_id := interaction.get_available_id()
		
		undo_redo.create_action("Add Node")
		undo_redo.add_do_method(self, "add_node", new_node, new_id,
				graph_edit.scroll_offset + get_local_mouse_position())
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
	for id in interaction.nodes:
		var node : InteractionNode = interaction.nodes[id]
		var connected : bool = "next" in node and node.next == int(to)
		var slot := -1
		if node is OptionsNode:
			for path_num in node.option_paths.size():
				if node.option_paths[path_num] == int(to):
					connected = true
					slot = path_num
					break
		if connected:
			undo_redo.add_do_method(self, "disconnect_nodes", id, slot)
			undo_redo.add_undo_method(self, "connect_nodes", id, slot, int(to))
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


func add_node(node : InteractionNode, id : int, position : Vector2) -> void:
	node.position = position
	interaction.nodes[id] = node


func add_comment(comment : CommentNode) -> void:
	interaction.comments.append(comment)


func remove_comment(comment : CommentNode) -> void:
	interaction.comments.erase(comment)


func remove_node(id : int) -> void:
	interaction.nodes.erase(id)


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


func move_node(node, to : Vector2) -> void:
	node.position = to


func _on_GraphEdit_end_node_move() -> void:
	undo_redo.commit_action()


func connect_nodes(from : int, from_slot : int, to : int) -> void:
	var from_node : InteractionNode = interaction.nodes[from]
	if "next" in from_node:
		# Could be an `EndNode` or a `MessageNode`
		from_node.next = to
	elif from_node is OptionsNode:
		from_node.option_paths[from_slot] = to


func disconnect_nodes(from : int, from_slot : int) -> void:
	print("disconnect ", from)
	var from_node : InteractionNode = interaction.nodes[from]
	if "next" in from_node:
		# Could be an `EndNode` or a `MessageNode`
		from_node.next = -1
	elif from_node is OptionsNode:
		from_node.option_paths[from_slot] = -1


func _on_GraphEdit_connection_to_empty(from : String, from_slot : int,
		release_position : Vector2) -> void:
	connecting_from = int(from)
	from_port = from_slot
	add_node_menu.popup()
	add_node_menu.rect_position = rect_global_position + release_position


func _on_GraphEdit_disconnection_request(from : String, from_slot : int,
		to : String, to_slot: int) -> void:
	var interaction_node : InteractionNode = graph_edit.get_node(
			from).get_meta("node")
	undo_redo.create_action("Disconnect Node")
	undo_redo.add_do_method(self, "disconnect_nodes", int(from), from_slot)
	undo_redo.add_undo_method(self, "connect_nodes", int(from), from_slot, int(to))
	undo_redo.add_do_method(self, "update_graph_connections")
	undo_redo.add_undo_method(self, "update_graph_connections")
	undo_redo.commit_action()


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
		if node is MessageNode:
			graph_node = message_graph_node.instance()
			graph_node.connect("message_edited", self,
					"_on_MessageGraphNode_message_edited", [node])
		elif node is OptionsNode:
			graph_node = option_graph_node.instance()
			graph_node.connect("option_edited", self,
					"_on_OptionGraphNode_message_edited", [node])
			graph_node.connect("option_added", self,
					"_on_OptionGraphNode_option_added", [node])
			graph_node.connect("option_removed", self,
					"_on_OptionGraphNode_option_removed", [node])
		elif node is StartNode:
			graph_node = start_graph_node.instance()
		elif node is EndNode:
			graph_node = end_graph_node.instance()
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
		if node is OptionsNode:
			for option_num in node.option_data.size():
				var to_node = node.option_paths[option_num]
				if to_node != -1:
					graph_edit.connect_node(str(node_id), option_num,
							str(to_node), 0)
		elif "next" in node:
			if node.next != -1:
				graph_edit.connect_node(str(node_id), 0, str(node.next), 0)


func _on_GraphEdit_paste_nodes_request() -> void:
	undo_redo.create_action("Paste Nodes")
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_GraphEdit_copy_nodes_request() -> void:
	copied_nodes.clear()
	for node in graph_edit.get_children():
		if node is GraphNode and node.selected:
			copied_nodes.append(interaction.nodes[int(node.name)].duplicate())


func _on_GraphEdit_duplicate_nodes_request() -> void:
	undo_redo.create_action("Duplicate Nodes")
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_MessageGraphNode_message_edited(node : MessageNode) -> void:
	emit_signal("resource_edited", node.data)


func _on_OptionGraphNode_message_edited(option_num : int,
		node : OptionsNode) -> void:
	emit_signal("resource_edited", node.option_data[option_num])


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


func _on_OptionGraphNode_option_added(node : OptionsNode) -> void:
	yield(get_tree(), "idle_frame")
	undo_redo.create_action("Add Option")
	undo_redo.add_do_method(node, "add_option",
			InteractionOption.new("Option 1"))
	undo_redo.add_undo_method(node, "remove_option")
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()


func _on_OptionGraphNode_option_removed(node : OptionsNode) -> void:
	yield(get_tree(), "idle_frame")
	undo_redo.create_action("Remove Option")
	undo_redo.add_do_method(node, "remove_option")
	undo_redo.add_undo_method(node, "add_option", node.option_data.back())
	undo_redo.add_do_method(self, "update_graph")
	undo_redo.add_undo_method(self, "update_graph")
	undo_redo.commit_action()
