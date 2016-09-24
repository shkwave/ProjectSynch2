extends Node2D

var CHARS = ResourceLoader.load("res://Scripts/CharClassDefinition.gd")
var ALIVE_CHILDREN 
var ActiveCharIndx = 0

func _ready():
	randomize()
	var minnchar = 4
	var maxnchar = 8
	var nchar = randi()%(maxnchar+1-minnchar)+minnchar
	for i in range(nchar):
		var s = CHARS.Lancer.new()
		s.TEAM = "P1"
		var positioned = false
		var newpos = null
		while !positioned :
			newpos = Vector2(randi()%8,randi()%25)
			positioned = get_node("../Terrain").is_available(newpos)
			for kid in self.get_children():
				if newpos == kid.get_grid_pos() :
					positioned = false
		self.add_child(s)
		s.set_grid_pos(newpos)

	#print(nchar," character have been generated")
	ALIVE_CHILDREN = get_children()
	#print(ALIVE_CHILDREN)
	ALIVE_CHILDREN = shuffle(ALIVE_CHILDREN)
	#print(ALIVE_CHILDREN)
	

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