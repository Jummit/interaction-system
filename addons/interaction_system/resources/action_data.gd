tool
extends Resource
class_name InteractionActionData

"""
The data of an `InteractionActionNode`

By default this only holds text, but can be extended to store more information.
It is editable in the editor by clicking on the text of a `ActionNode`.

ActionNodes have one input and one output port. They can have a condition and
only get executed when it is met.
"""

export var condition : InteractionCondition

# The name of the `MessageGraphNode` in the editor.
var node_name : String
var content_member : String

func get_name() -> String:
	var text : String = get_content_string()
	if text.length() > 15:
		return text.substr(0, 12) + "..."
	return text


func get_content_string() -> String:
	return get(content_member)


func condition_met(state : GlobalInteractionState) -> bool:
	return not condition or condition.is_met(state)
