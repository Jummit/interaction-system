tool
extends EditorPlugin

onready var interaction_tree_editor : Control = preload(\
		"interaction_tree_editor/interaction_tree_editor.tscn").instance()

func _ready() -> void:
	interaction_tree_editor.undo_redo = get_undo_redo()
	interaction_tree_editor.hide()
	interaction_tree_editor.connect("resource_edited", self,
			"_on_InteractionTreeEditor_resource_edited")
	add_control_to_bottom_panel(interaction_tree_editor, "Interaction Tree")
	get_editor_interface().get_inspector().connect("property_edited", self,
			"_on_Inspector_property_edited")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(interaction_tree_editor)
	interaction_tree_editor.queue_free()


func handles(object : Object) -> bool:
	return object is InteractionTree


func edit(object : Object) -> void:
	interaction_tree_editor.interaction = object
	make_bottom_panel_item_visible(interaction_tree_editor)


func apply_changes() -> void:
	interaction_tree_editor.apply_changes()


func clear() -> void:
	interaction_tree_editor.hide()


func _on_InteractionTreeEditor_resource_edited(resource : Resource) -> void:
	get_editor_interface().edit_resource(resource)


func _on_Inspector_property_edited(_property : String) -> void:
	if interaction_tree_editor.is_visible_in_tree():
		interaction_tree_editor.update_graph()
