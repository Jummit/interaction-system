tool
extends Resource
class_name InteractionCondition

"""
A condition used in `ActionNode`s
"""

# A GDScript expression that is run on the global state, for example
# `health > 5`.
export var expression : String

func is_met(state : GlobalInteractionState) -> bool:
	var gd_expression := Expression.new()
	gd_expression.parse(expression)
	return gd_expression.execute([], state)
