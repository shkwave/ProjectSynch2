
extends Control

onready var ActDef = get_node("/root/ActionClassDefinition")

func menu_generate(active_hero):
	var attackoptions = active_hero.get_attack_options()
	for i in range(attackoptions.size()) :
		var s = Button.new()
		s.set_pos(Vector2(0,i*30))
		s.set_size(Vector2(120,30))
		s.set_text(attackoptions[i])
		s.set_name(attackoptions[i])
		s.connect("pressed",ActDef,"createaction",[attackoptions[i],get_tree().get_root().get_node("World").ACTIVE_CHAR])
		self.add_child(s)

