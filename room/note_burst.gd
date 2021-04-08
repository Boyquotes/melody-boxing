extends Node2D

var timer = 1;
var speed = 0.1;
var texture = preload("res://sprite/note.png");

func burst(pos):
	$note_burst.visible = true;
	$note_burst.play("default");
	position = pos;
	timer = 0;

func _process(delta):
	update();
	timer += speed;
	timer = clamp(timer, 0, 1);
	

func _draw():
	if timer < 1:
#		draw_rect(Rect2(Vector2(-texture.get_width()*getX(timer)/2, -texture.get_height()*getY(timer)/2), 
#			Vector2(texture.get_width()*getX(timer), texture.get_height()*getY(timer) )),
#			Color(1-timer,1-timer,1-timer,1-timer), true);
		draw_texture_rect(texture,Rect2(Vector2(-texture.get_width()*getX(timer)/2, -texture.get_height()*getY(timer)/2), 
			Vector2(texture.get_width()*getX(timer), texture.get_height()*getY(timer) )),false, 
			Color(1-timer,1-timer,1-timer,1-timer));

func getY(x):
	return 1-0.1*x+3.1*pow(x,2)-0.6*pow(x,3)-3.4*pow(x,4);
	
func getX(x):
	return 1+8*pow(x,8);


func _on_note_burst_animation_finished():
	$note_burst.stop();
	$note_burst.visible = false;
