
extends Node2D

var CHAR_SCENE = ResourceLoader.load("res://Scenes/CombatScene/ExampleChar.scn")

func _ready():
	randomize()
	for i in range(randi()%4+1):
		var s = CHAR_SCENE.instance()
		var positioned = false
		var newpos = null
		while !positioned :
			newpos = Vector2(randi()%6,randi()%6)
			positioned = true
			for kid in self.get_children():
				if newpos == kid.grid_pos :
					positioned = false
		self.add_child(s)
		s.grid_pos=newpos
		
