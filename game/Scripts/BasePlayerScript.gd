
extends Node2D

var ALIVE_CHILDREN 
var ActiveCharIndx = 0


func _ready():
	ALIVE_CHILDREN = get_children()
	ALIVE_CHILDREN = shuffle(ALIVE_CHILDREN)
	


func shuffle(list):
	var shuffledlist = []
	var indx
	var nchar = list.size()
	randomize()
	for i in range(nchar):
		indx = randi()%list.size()
		shuffledlist.append(list[indx])
		list.remove(indx)
	return shuffledlist

func get_next_active_char():
	ActiveCharIndx += 1
	if ActiveCharIndx >= ALIVE_CHILDREN.size():
			ActiveCharIndx = 0
	while(ALIVE_CHILDREN[ActiveCharIndx].CHAR_STATE == "DEAD"):
		ActiveCharIndx += 1
		if ActiveCharIndx >= ALIVE_CHILDREN.size():
			ActiveCharIndx = 0
	return ALIVE_CHILDREN[ActiveCharIndx]


