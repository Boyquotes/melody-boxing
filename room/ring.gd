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

var song_bpm = 70;
#var song_bpm = 10.0;
var song_bps = float(song_bpm)/60.0;
var song_bpf = song_bps/60.0;
var song_start = 100;
var song_offset = 0;

var song_started = false;

var action_delay = (1.0/float(song_bpm)) * 1000;

#Note window
const NOTE_DELAY = 1500;

#Start and end position of notes
const START_POS = Vector2(797,65);
const END_POS = Vector2(-797,65);

var player = null;
var enemy = null;

var hp_ui = preload("res://sprite/ui/healthbar.png");

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
#	$combo.set_text(String(combo) + "\n" + String(judge)) ;
	
#	$combo.set_note_progress(clamp( -(song_pos - (song_start + song_offset + (song_beat) * (1/song_bpf))) / 100.0 , 0.0, 1.0) );	
	#$screen.set_note_progress(clamp( -(song_pos - (song_start + song_offset + (song_beat) * (1/song_bpf))) * song_bpf , 0.0, 1.0) );	
	$screen.set_note_progress(clamp( fmod(song_pos - (song_start + song_offset ) , 1/song_bpf) * song_bpf, 0.0, 1.0) );	
	
	#Rotate light
	$background/light.rotation = sin(OS.get_ticks_msec()/800.0) * PI/5
	$background/light2.rotation = -cos(OS.get_ticks_msec()/800.0) * PI/5
	

func _draw():
	
#	print(clamp( -(song_pos - (song_start + song_offset + (song_beat) * (1/song_bpf))) / 100.0 , 0.0, 1.0))
	
	#Position definition
	var ui_offset_top = 10
	var ui_offset_side = 10
	var ui_size_height = 140
	var ui_size_width = 900
	
	var hp_offset_top = 45
	var hp_offset_side = 125
	var hp_size_height = 51
	var hp_size_width = 770
	
	var sp_offset_top = 113
	var sp_offset_side = 130
	var sp_size_height = 30
	var sp_size_width = 464
	
	var left_ui_pos = Vector2(-position.x*2+ui_offset_side,-position.y*2+ui_offset_top)
	var left_ui_size = Vector2(ui_size_width, ui_size_height)
	
	var left_hp_pos = Vector2(-position.x*2+hp_offset_side,-position.y*2+hp_offset_top)
	var left_hpbg_size = Vector2(hp_size_width, hp_size_height)
	var left_hp_size = Vector2(hp_size_width*(player.hp/player.maxHp), hp_size_height)
	var left_hpghost_size = Vector2(hp_size_width*(player.hpGhost/player.maxHp), hp_size_height)
	
	var left_sp_pos = Vector2(-position.x*2+sp_offset_side,-position.y*2+sp_offset_top)
	var left_spbg_size = Vector2(sp_size_width, sp_size_height)
	var left_sp_size = Vector2(sp_size_width*(player.spGhost/player.maxSp), sp_size_height)
	
	var right_ui_pos = Vector2(position.x*2-ui_offset_side-ui_size_width,-position.y*2+ui_offset_top)
	var right_ui_size = Vector2(-ui_size_width, ui_size_height)
	
	var right_hp_pos = Vector2(position.x*2-hp_offset_side,-position.y*2+hp_offset_top)
	var right_hpbg_size = Vector2(-hp_size_width, hp_size_height)
	var right_hp_size = Vector2(-hp_size_width*(enemy.hp/enemy.maxHp), hp_size_height)
	var right_hpghost_size = Vector2(-hp_size_width*(enemy.hpGhost/enemy.maxHp), hp_size_height)
	
	var right_sp_pos = Vector2(position.x*2-sp_offset_side,-position.y*2+sp_offset_top)
	var right_spbg_size = Vector2(-sp_size_width, sp_size_height)
	var right_sp_size = Vector2(-sp_size_width*(enemy.spGhost/enemy.maxSp), sp_size_height)
	
	draw_rect(Rect2(left_hp_pos, left_hpbg_size), Color.dimgray);
	draw_rect(Rect2(right_hp_pos, right_hpbg_size), Color.dimgray);
	draw_rect(Rect2(left_hp_pos, left_hpghost_size), Color.white);
	draw_rect(Rect2(right_hp_pos, right_hpghost_size), Color.white);
	draw_rect(Rect2(left_hp_pos, left_hp_size), Color.green);
	draw_rect(Rect2(right_hp_pos, right_hp_size), Color.green);

	draw_rect(Rect2(left_sp_pos, left_spbg_size), Color.dimgray);
	draw_rect(Rect2(right_sp_pos, right_spbg_size), Color.dimgray);
	draw_rect(Rect2(left_sp_pos, left_sp_size), Color.orange);
	draw_rect(Rect2(right_sp_pos, right_sp_size), Color.orange);

	draw_texture_rect(hp_ui, Rect2(left_ui_pos, left_ui_size),false )
	draw_texture_rect(hp_ui, Rect2(right_ui_pos, right_ui_size),false )
	
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
			increaseCombo();
			increaseBeat();
			$screen.set_text("Great") ;
			if(ev.is_action_pressed(attack_btn)):
				player_attack(true);
			if(ev.is_action_pressed(defend_btn)):
				player_defend(true);

		elif(song_pos < check_window + JD_FAIR &&
			song_pos > check_window - JD_FAIR):
			increaseCombo();
			increaseBeat();
			$screen.set_text("Good") ;
			if(ev.is_action_pressed(attack_btn)):
				player_attack();
			if(ev.is_action_pressed(defend_btn)):
				player_defend();

		elif(song_pos < check_window + JD_BAD &&
			song_pos > check_window - JD_BAD):
			resetCombo();
			increaseBeat();
			$screen.set_text("Bad") ;
			player_miss();

			
	if ev.is_action_pressed("ui_up"):
		stance_up();
		
	if ev.is_action_pressed("ui_down"):
		stance_down();

func stance_up():
	player.set_stance(player.Stance.UP);
		
func stance_down():
	player.set_stance(player.Stance.DOWN);

func player_attack(perf = false):
	if(enemy.pose == enemy.Pose.IDLE):
		#If enemy is attacking
		var tempStance =  player.stance;
		player.set_stance(enemy.stance);
		player.hit(true);
		enemy.attack(true);
		dealDamage(enemy, player, true);
		player.set_stance(tempStance);
	else:
		if(enemy.pose == enemy.Pose.DEFEND && player.stance != enemy.stance):
			#If enemy blocks unsuccessfully
			var tempStance =  enemy.stance;
			enemy.set_stance(player.stance);
			player.attack(true);
			enemy.hit(true);
			dealDamage(player, enemy, perf);
			enemy.set_stance(tempStance);
		else:
			#If enemy blocks attack
			player.attack(false);
			enemy.defend(true);
		
	enemy.cpu_change_stance();
	
	
func player_defend(perf = false):
	if(enemy.pose == enemy.Pose.IDLE):
		if(enemy.stance == player.stance):
			#If player blocks successfully
			player.defend(true);
			enemy.attack(false);
			
			if(!perf):
				dealDamage(enemy, player, true, 0.25)
		else:
			#If player blocks unsuccessfully
			var tempStance =  player.stance;
			player.set_stance(enemy.stance);
			player.hit(true);
			enemy.attack(true);
			player.hp -= enemy.baseAtk * enemy.maxJudgeMult * enemy.maxSpMult * enemy.sp/enemy.maxSp;
			dealDamage(enemy, player, true);
			player.set_stance(tempStance);
	else:
		player.defend(false);
	enemy.cpu_change_stance();

func player_miss():
	if(enemy.pose == enemy.Pose.IDLE):
		var tempStance =  player.stance;
		player.set_stance(enemy.stance);
		player.hit(true);
		enemy.attack(true);
		dealDamage(enemy, player, true);
		player.set_stance(tempStance);
	enemy.cpu_change_stance();
		
func dealDamage(attacker, victim, perf, mult = 1):
	var judgeMult = 1;
	if(perf):
		judgeMult = attacker.maxJudgeMult;
	var damage = attacker.baseAtk * judgeMult * attacker.maxSpMult * (1+attacker.sp/attacker.maxSp) * mult;
	victim.hp -= damage;

func increaseCombo():
	combo += 1;
	player.sp = min(float(combo)/float(player.comboToSp), 1) * player.maxSp;
	
func resetCombo():
	combo = 0;
	player.sp = 0;

func run():
	song_pos += 1;
	if(song_pos >= song_start):
		if(song_started):
			checkBeat();
			return;
		
		song_started = true;
		$music.play();
		return;
		
func increaseBeat():
	song_beat += 1;
	enemy.sp =  min(enemy.sp+enemy.enemySpInc, enemy.maxSp);

func checkBeat():
	if(song_pos >= song_start + song_offset + song_beat * (1/song_bpf) + JD_BAD):
		increaseBeat();
		resetCombo();
		$screen.set_text("Miss") ;
		player_miss();

