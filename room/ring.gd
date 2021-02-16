extends Node2D

#Player side
# left = 0, right = 1
var side = 0;
# up = 0, down = 1
var player_stance = 0; 

var punched_timer = 0;

var enemy_stance = 0;

#Combo
var combo = 0;
var judge = "";

#Judgement window
const JD_PERFECT = 3;
const JD_FAIR = 6;
const JD_BAD = 15;

#Variables for beats
var song_pos = 0;
var song_beat = 0;

var song_bpm = 72.75;
#var song_bpm = 10.0;
var song_bps = song_bpm/60;
var song_bpf = song_bps/60;
var song_start = 100;
var song_offset = 90;

var song_started = false;

var punched_timer_max = (1.0/float(song_bpm)) * 1000;

#Note window
const NOTE_DELAY = 1500;

#Repeating sequence
const REPEAT_MAX = 2;
var repeat = REPEAT_MAX;

#Start and end position of notes
const START_POS = Vector2(797,65);
const END_POS = Vector2(-797,65);

#Player sprites
const player1_char = "template";
var player1_sprite = [];

const player2_char = "template";
var player2_sprite = [];

const CHARGE_IND = 0;
const BLOCK_IND = 2;
const PUNCH_IND = 4;
const HIT_IND = 6;

func _ready():
	player1_sprite.append(preload("res://sprite/template/charge_up.png"));
	player1_sprite.append(preload("res://sprite/template/charge_down.png"));
	
	player1_sprite.append(preload("res://sprite/template/block_up.png"));
	player1_sprite.append(preload("res://sprite/template/block_down.png"));
	
	player1_sprite.append(preload("res://sprite/template/punch_up.png"));
	player1_sprite.append(preload("res://sprite/template/punch_down.png"));
	
	player1_sprite.append(preload("res://sprite/template/hit_up.png"));
	player1_sprite.append(preload("res://sprite/template/hit_down.png"));
	
	player2_sprite.append(preload("res://sprite/template/charge_up.png"));
	player2_sprite.append(preload("res://sprite/template/charge_down.png"));
	
	player2_sprite.append(preload("res://sprite/template/block_up.png"));
	player2_sprite.append(preload("res://sprite/template/block_down.png"));
	
	player2_sprite.append(preload("res://sprite/template/punch_up.png"));
	player2_sprite.append(preload("res://sprite/template/punch_down.png"));

	player2_sprite.append(preload("res://sprite/template/hit_up.png"));
	player2_sprite.append(preload("res://sprite/template/hit_down.png"));
	stance_refresh();
	stance_reset();

func _process(delta):
	run();
	update();
	$combo.text = String(combo) + " " + String(judge) ;
	
	if(punched_timer>1):
		punched_timer-=1;
	elif(punched_timer>0):
		stance_reset();
		punched_timer = 0;

func _draw():
	var x_ratio = []; 
	for i in range(10):
		x_ratio.insert(i, clamp( -(song_pos - (song_start + song_offset + (song_beat+i) * (1/song_bpf))) / 100.0 , 0.0, 1.0) ) ;
		if(x_ratio[i] != 1):
			draw_texture($spr_note.texture , Vector2(END_POS.x + (START_POS.x - END_POS.x) * x_ratio[i], START_POS.y));
		
#	x_ratio = -(song_pos - (song_start + song_offset + song_beat * (1/song_bpf))) / 100.0;
#	print_debug(x_ratio);

func _input(ev):
	var check_window = song_start + song_offset + song_beat * (1/song_bpf);
	
	var attack_btn = "";
	var defend_btn = "";
	if side == 0:
		attack_btn = "ui_right";
		defend_btn = "ui_left";
	if side == 1:
		attack_btn = "ui_left";
		defend_btn = "ui_right";
	
	if ev.is_action_pressed(attack_btn) || ev.is_action_pressed(defend_btn) :
		if(song_pos < check_window + JD_PERFECT &&
			song_pos > check_window - JD_PERFECT):
			combo += 1;
			song_beat += 1;
			judge = "Perfect";
			if(ev.is_action_pressed(attack_btn)):
				player_attack();
			if(ev.is_action_pressed(defend_btn)):
				player_defend();
			stance_refresh();
		elif(song_pos < check_window + JD_FAIR &&
			song_pos > check_window - JD_FAIR):
			combo += 1;
			song_beat += 1;
			judge = "Good";
			if(ev.is_action_pressed(attack_btn)):
				player_attack();
			if(ev.is_action_pressed(defend_btn)):
				player_defend();
			stance_refresh();
		elif(song_pos < check_window + JD_BAD &&
			song_pos > check_window - JD_BAD):
			combo = 0;
			song_beat += 1;
			judge = "Bad";
			player_miss();
			stance_refresh();
			
	if ev.is_action_pressed("ui_up"):
		pose_up();
		
	if ev.is_action_pressed("ui_down"):
		pose_down();

func pose_up():
	if(side==0):
		if(punched_timer==0):
			$spr_left.set_texture(player1_sprite[0]);
		player_stance = CHARGE_IND;
		
func pose_down():
	if(side==0):
		if(punched_timer==0):
			$spr_left.set_texture(player1_sprite[1]);
		player_stance = CHARGE_IND+1;

func player_attack():
	if(side==0):
		if(enemy_stance in [CHARGE_IND, CHARGE_IND+1]):
			$spr_left.set_texture(player1_sprite[HIT_IND+enemy_stance]);
			$spr_right.set_texture(player2_sprite[PUNCH_IND+enemy_stance]);
		else:
			$spr_left.set_texture(player1_sprite[PUNCH_IND+player_stance]);
			
			if(enemy_stance==BLOCK_IND && player_stance==CHARGE_IND+1 ||
				enemy_stance==BLOCK_IND+1 && player_stance==CHARGE_IND):
				$spr_right.set_texture(player2_sprite[HIT_IND+player_stance]);
			else:
				$spr_right.set_texture(player2_sprite[BLOCK_IND+player_stance]);
		punched_timer = punched_timer_max;
		
func player_defend():
	if(side==0):
		if(enemy_stance in [CHARGE_IND, CHARGE_IND+1]):
			$spr_right.set_texture(player2_sprite[PUNCH_IND+enemy_stance]);
		if(enemy_stance==CHARGE_IND && player_stance==CHARGE_IND+1 ||
			enemy_stance==CHARGE_IND+1 && player_stance==CHARGE_IND):
			$spr_left.set_texture(player1_sprite[HIT_IND+enemy_stance]);
		else:
			$spr_left.set_texture(player1_sprite[BLOCK_IND+player_stance]);
		punched_timer = punched_timer_max;

func player_miss():
	if(side==0):
		if(enemy_stance in [CHARGE_IND, CHARGE_IND+1]):
			$spr_left.set_texture(player1_sprite[HIT_IND+enemy_stance]);
			$spr_right.set_texture(player2_sprite[PUNCH_IND+enemy_stance]);
			punched_timer = punched_timer_max;

func stance_reset():
	if(side==0):
		$spr_left.set_texture(player1_sprite[player_stance]);
		$spr_right.set_texture(player2_sprite[enemy_stance]);

func stance_refresh():
	if(repeat > 0):
		repeat-=1;
		return;
	
	var stance_list = [CHARGE_IND, CHARGE_IND+1, BLOCK_IND, BLOCK_IND+1];
	enemy_stance = stance_list[randi() % 4];
	repeat=REPEAT_MAX;
	
#	if(side==0):
#		$spr_right.set_texture(player2_sprite[enemy_stance]);

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
		judge = "Miss";
		player_miss();
		stance_refresh();

