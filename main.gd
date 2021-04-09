extends Node2D

onready var interaction_menu : Panel = $CanvasLayer/InteractionMenu

func _on_InteractionMenu_state_changed() -> void:
	$MoneyLabel.text = "Money : %s" % interaction_menu.state.money
