tool
extends GraphNode

"""
The `GraphNode` representation of a `OptionNode`
"""

signal option_edited(option)
signal option_added(option)
signal option_moved(option, to)
signal option_removed(option)

const OptionsNode = preload("../nodes/options_node.gd")

var node : OptionsNode

onready var remove_option_button : Button = $Buttons/RemoveOptionButton
onready var options : Tree = $OptionsAnchor/Options

func init(_node : OptionsNode) -> void:
	node = _node
	options.clear()
	var root := options.create_item()
	for option_num in node.option_data.size():
		var item := options.create_item(root)
		item.set_text(0, node.option_data[option_num].get_name())
		item.set_metadata(0, option_num)
		if option_num:
			var spacer := Control.new()
			spacer.rect_min_size.y = 28
			spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(spacer)
			move_child(spacer, option_num)
		set_slot(option_num, option_num == 0, 0, Color.white, true, 0,
				Color.white)
	if node.option_data.empty():
		set_slot(0, true, 0, Color.white, false, 0, Color.white)
	var spacer_height := node.option_data.size() * 30
	options.get_scroll()
	options.rect_size.y = spacer_height
	remove_option_button.disabled = node.option_data.empty()


func _ready() -> void:
	options.set_drag_forwarding(self)


func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == BUTTON_WHEEL_UP\
			or event.button_index == BUTTON_WHEEL_DOWN):
		options.scroll_to_item(options.get_root())


func can_drop_data_fw(_position : Vector2, data, _control : Control) -> bool:
	if data is Dictionary and data.get("type") == "files":
		var file : String = data.files[0]
		return ResourceLoader.exists(file) and\
				load(file).new() is InteractionOption
	return data is Dictionary and data.get("type") == "option" and\
			data.from == name


func drop_data_fw(position : Vector2, data : Dictionary,
		_control : Control) -> void:
	if data.type == "option":
		var option_size := node.option_data.size()
		var to := 0
		if position.y > 5:
			to = option_size
		var item := options.get_item_at_position(position)
		if item:
			to = item.get_metadata(0)
			if options.get_drop_section_at_position(position) == 1:
				to = to + 1
		emit_signal("option_moved", data.option, clamp(to, 0, option_size))
	elif data.type == "files":
		emit_signal("option_added", load(data.files[0]).new())


func get_drag_data_fw(position : Vector2, _control : Container):
	return {
		type = "option",
		option = options.get_item_at_position(position).get_metadata(0),
		from = name
	}


func _on_AddOptionButton_pressed() -> void:
	emit_signal("option_added", InteractionOption.new())


func _on_RemoveOptionButton_pressed() -> void:
	if options.get_selected():
		emit_signal("option_removed", options.get_selected().get_metadata(0))


func _on_Options_item_selected() -> void:
	emit_signal("option_edited", options.get_selected().get_metadata(0))
