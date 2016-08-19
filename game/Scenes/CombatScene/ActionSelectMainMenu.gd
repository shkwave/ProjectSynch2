
extends VBoxContainer



onready var WORLD = get_tree().get_root().get_node("World")
var ActionClassDefinition = preload("res://Scripts/ActionClassDefinition.gd")

func _on_Move_pressed():
	var action = ActionClassDefinition.MoveAction.New()
	action.setup(get_tree().get_root().get_node("World").ACTIVE_CHAR)

func _on_Attack_pressed():
	get_parent().menu_load("AttackMenu")


func _on_Magic_pressed():
	get_parent().menu_load("MagicMenu")