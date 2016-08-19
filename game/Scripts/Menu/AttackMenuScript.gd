
extends Control

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	update()
	pass

func _draw():
	draw_rect(Rect2(Vector2(0,0),Vector2(200,150)),Color(0.2,0.2,0.2))

func menu_generate(active_hero):
	var attackoptions = active_hero.get_attack_options()
	for i in range(attackoptions.size()) :
		var s = Button.new()
		s.set_pos(Vector2(0,i*30))
		s.set_size(Vector2(200,30))
		s.set_text(attackoptions[i])
		s.set_name(attackoptions[i])
		self.add_child(s)
	


