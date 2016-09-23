
extends Node2D

var CHAR_SCENE = ResourceLoader.load("res://Scenes/CombatScene/ExampleChar.scn")

func _ready():
	randomize()
	var minnchar = 4
	var maxnchar = 8
	var nchar = randi()%(maxnchar+1-minnchar)+minnchar
	for i in range(nchar):
		var s = CHAR_SCENE.instance()
		var positioned = false
		var newpos = null
		while !positioned :
			newpos = Vector2(randi()%6,randi()%6)
			positioned = true
			for kid in self.get_children():
				if newpos == kid.get_grid_pos() :
					positioned = false
		self.add_child(s)
		s.set_grid_pos(newpos)
		
	print(nchar," character have been generated")