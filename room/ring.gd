extends Node2D

#Combo
var combo = 0;

#Judgement window
const JD_PERFECT = 3;
const JD_FAIR = 5;
const JD_BAD = 7;

#Variables for beats
var song_pos = 0;
var song_beat = 0;

var song_bpm = 123.0;
var song_bps = song_bpm/60;
var song_bpf = song_bps/60;
var song_start = 100;
var song_offset = 0;

var song_started = false;

#Note window
const NOTE_DELAY = 1500;

#Start and end position of notes
const START_POS = Vector2(797,65);
const END_POS = Vector2(-797,65);

func _ready():
	pass # Replace with function body.


func _process(delta):
	run();
	update();
	$combo.text = String(combo);

func _draw():
	var x_ratio = []; 
	for i in range(10):
		x_ratio.insert(i, clamp( -(song_pos - (song_start + song_offset + (song_beat+i) * (1/song_bpf))) / 100.0 , 0.0, 1.0) ) ;
		if(x_ratio[i] != 1):
			draw_texture($spr_note.texture , Vector2(END_POS.x + (START_POS.x - END_POS.x) * x_ratio[i], START_POS.y));
		
#	x_ratio = -(song_pos - (song_start + song_offset + song_beat * (1/song_bpf))) / 100.0;
#	print_debug(x_ratio);

func _input(ev):
	if ev.is_action_released("ui_select"):
		if(song_pos < song_start + song_offset + song_beat * (1/song_bpf) + JD_BAD &&
			song_pos > song_start + song_offset + song_beat * (1/song_bpf) - JD_BAD):
			combo += 1;
			song_beat += 1;
			
func run():
	song_pos += 1;
	
	if(song_pos >= song_start):
		if(song_started):
			checkBeat();
			return;
		
		song_started = true;
		$music.play();
		return;
		

func checkBeat():
	if(song_pos >= song_start + song_offset + song_beat * (1/song_bpf) + JD_BAD):
		song_beat += 1;
		combo = 0;
#		print("Beat "+ String(song_beat) );

	pass
