tool
extends InteractionNode

"""
A node that holds an action

Has one input and one output port.
There are different actions, for example messages, events, state changes and
more. How they are handled depends on the `InteractionMenu`.
"""

export var data : InteractionActionData
