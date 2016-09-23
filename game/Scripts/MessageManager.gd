
extends Node

var actionlist = []

func add_action(action):
	actionlist.push_back(action)

func process():
	var currentTurn = get_node("/root/globals").get_current_turn()
	for action in actionlist:
		if (action.ExecTurn == currentTurn) :
			action.execute()

