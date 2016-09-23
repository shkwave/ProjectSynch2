extends Node

var actionlist = []

func add_action(action):
	actionlist.push_back(action)

func process():
	var currentTurn = get_node("/root/globals").get_current_turn()
	var i = 0
	while i < (actionlist.size()):
		var action = actionlist[i]
		if action.ExecTurn == currentTurn :
			action.execute()
			actionlist.remove(i)
		else :
			i +=1
	