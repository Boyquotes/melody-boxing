extends Node2D


func _ready():
	pass # Replace with function body.

func _process(delta):
	update();

func _draw():
	draw_texture(.texture , Vector2(100,100));
