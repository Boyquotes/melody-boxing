extends Node2D

var root;
var texture = preload("res://sprite/note.png");

func _ready():
	root =  get_owner();

func _process(delta):
	update();

func _draw():
	var x_ratio = []; 
	#Draw notes
	for i in range(10):
		x_ratio.insert(i, clamp( -(root.song_pos - (root.song_start + root.song_offset + (root.song_beat+i) * (1/root.song_bpf))) / 100.0 , 0.0, 1.0) ) ;
		if(x_ratio[i] != 1):
			draw_texture(texture , Vector2(root.END_POS.x + (root.START_POS.x - root.END_POS.x) * x_ratio[i], root.START_POS.y));
	
