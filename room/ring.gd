extends Node2D

#Player side
# left = 0, right = 1
var side = 0;


#Combo
var combo = 0;
var judge = "";

#Judgement window
const JD_PERFECT = 5;
const JD_FAIR = 10;
const JD_BAD = 15;

#Variables for beats
var song_pos = 0;
var song_beat = 0;

var song_bpm = 72;
#var song_bpm = 10.0;
var song_bps = float(song_bpm)/60;
var song_bpf = song_bps/60;
var song_start = 100;
var song_offset = 85;

var song_started = false;

var action_delay = (1.0/float(song_bpm)) * 1000;

#Note window
const NOTE_DELAY = 1500;

#Start and end position of notes
const START_POS = Vector2(797,65);
const END_POS = Vector2(-797,65);

var player = null;
var enemy = null;

func _ready():
	if side == 0:
		player = $spr_left;
		enemy = $spr_right;
	else:
		player = $spr_right;
		enemy = $spr_left;
	player.effectObj = $spr_effect;
	enemy.effectObj = $spr_effect;
	enemy.isCpu = true;
	enemy.cpu_change_stance();
	

func _process(delta):
	run();
	update();
	$combo.text = String(combo) + " " + String(judge) ;
	

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

		elif(song_pos < check_window + JD_FAIR &&
			song_pos > check_window - JD_FAIR):
			combo += 1;
			song_beat += 1;
			judge = "Good";
			if(ev.is_action_pressed(attack_btn)):
				player_attack();
			if(ev.is_action_pressed(defend_btn)):
				player_defend();

		elif(song_pos < check_window + JD_BAD &&
			song_pos > check_window - JD_BAD):
			combo = 0;
			song_beat += 1;
			judge = "Bad";
			player_miss();

			
	if ev.is_action_pressed("ui_up"):
		stance_up();
		
	if ev.is_action_pressed("ui_down"):
		stance_down();

func stance_up():
	player.set_stance(player.Stance.UP);
		
func stance_down():
	player.set_stance(player.Stance.DOWN);

func player_attack():
	if(enemy.pose == enemy.Pose.IDLE):
		#If enemy is attacking
		player.set_stance(enemy.stance);
		player.hit(true);
		enemy.attack(true);
	else:
		if(enemy.pose == enemy.Pose.DEFEND && player.stance != enemy.stance):
			#If enemy blocks unsuccessfully
			var tempStance =  enemy.stance;
			enemy.set_stance(player.stance);
			player.attack(true);
			enemy.hit(true);
			enemy.set_stance(tempStance);
		else:
			#If enemy blocks attack
			player.attack(false);
			enemy.defend(true);
		
	enemy.cpu_change_stance();
	
	
func player_defend():
	if(enemy.pose == enemy.Pose.IDLE):
		if(enemy.stance == player.stance):
			#If player blocks successfully
			player.defend(true);
			enemy.attack(false);
		else:
			#If player blocks unsuccessfully
			player.set_stance(enemy.stance);
			player.hit(true);
			enemy.attack(true);
	else:
		player.defend(false);
	enemy.cpu_change_stance();

func player_miss():
	if(enemy.pose == enemy.Pose.IDLE):
		player.set_stance(enemy.stance);
		player.hit(true);
		enemy.attack(true);
	enemy.cpu_change_stance();
		

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

