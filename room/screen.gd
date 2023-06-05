extends Node2D

const RADIUS = 130;
const TRAIL_LEN = 10;
var noteProg = 0;
var prevProg = [];

func _ready():
	refresh();

func refresh():
	prevProg.clear();
	for i in range(TRAIL_LEN+1):
		prevProg.push_back(0);

func _process(delta):
	update();

func _draw():
	#draw_arc($judge.rect_position+ $judge.rect_pivot_offset, RADIUS, 0, 2*PI, 50, Color(1,1,1), 5,true)
	
#	draw_arc($combo.rect_position+ $combo.rect_pivot_offset, 150*noteProg, 0, 2*PI, 50, Color(1,1,1), 5,true)
	
	if noteProg!= 0:
		var temp = pow(noteProg,4)
		
		for i in range(TRAIL_LEN,0,-1):
			prevProg[i] = prevProg[i-1];
		prevProg[0] = temp;
		
		for i in range(TRAIL_LEN):
			var width = 1;
#			if(i!=0):
			width = $judge.rect_size.x*prevProg[i] - $judge.rect_size.x*prevProg[i+1];
			#draw_arc($judge.rect_position+ $judge.rect_pivot_offset, prevProg[i], 0, 2*PI, 50, Color(1,1,1,1-i/10.0), width,true)
			if(prevProg[i]!=1):
				draw_rect(Rect2(-$judge.rect_pivot_offset*prevProg[i], $judge.rect_size*prevProg[i]),
					Color(1,1,1,0.5-i/20.0),false,width,false);

func set_note_progress(prog):
	noteProg = prog;

func set_text(text):
	$judge.text = text;
