extends AnimatedSprite

enum Direction {LEFT = -1, RIGHT = 1};
enum Pose {DEFEND, IDLE};
enum Stance {UP, DOWN};

const Anim = {
	IDLE_UP = "idle_up",
	IDLE_DOWN = "idle_down",
	ATTACK_UP = "atk_up",
	ATTACK_DOWN = "atk_down",
	DEFEND_UP = "def_up",
	DEFEND_DOWN = "def_down",
	HIT_UP = "hit_up",
	HIT_DOWN = "hit_down",
	DEFL_UP = "defl_up",
	DEFL_DOWN = "defl_down"
}

#var character = Global.Character.TEMPLATE;
var direction = -1;
var actionTimer = 0;
var shakeTimer = 0;
var actionDelay = 0;
var pounceTimer = 0;
var pounceTimer2 = 0;

var originalPos = Vector2(0,0);
var shakePos = Vector2(0,0);
var pouncePos = Vector2(0,0);
var pounceDir = 0;
var pounceIntensity = 0;

#The lower the difficulty value, the more difficult it is
var isCpu = false;
var cpuDifficulty = 2;
var cpuRepeat = cpuDifficulty;
var cpuRepeatAllowance = 1

var pose = Pose.IDLE;
var stance = Stance.UP;

var effectObj = null;

var blockEffectPos = [];
var burstEffectPos = [];

#Health points of the character
var maxHp = 100.0;
var hpGhost = 100.0;
var hp = 100.0;
var maxSp = 100.0;
var spGhost = 0.0;
var sp = 0.0;

#Stats
var comboToSp = 30;
var baseAtk = 1.0;
var maxSpMult = 1.5;
var maxJudgeMult = 1.5;
var enemySpInc = 2;

func _ready():
	z_index = 50;
	speed_scale = 2;
	originalPos = self.position;
	
	var blockx = 140;
	var attackx = 400;
	var fxy = -120;
	var fxy2 = 20;
	
	if(self.flip_h): 
		direction = Direction.LEFT; 
		blockEffectPos.append(Vector2(-blockx,fxy));
		blockEffectPos.append(Vector2(-blockx,fxy2));
		burstEffectPos.append(Vector2(-attackx,fxy));
		burstEffectPos.append(Vector2(-attackx,fxy2));
	else: 
		direction = Direction.RIGHT;
		blockEffectPos.append(Vector2(blockx,fxy));
		blockEffectPos.append(Vector2(blockx,fxy2));
		burstEffectPos.append(Vector2(attackx,fxy));
		burstEffectPos.append(Vector2(attackx,fxy2));
		

func set_stance(stance):
	self.stance = stance;
	default_pose();
	
func attack(movement = false):
	z_index = 100;
	if stance==Stance.UP: 
		play(Anim.ATTACK_UP);
	else:
		play(Anim.ATTACK_DOWN);
	if movement:
		pounce(direction, 200, 5);
		if(effectObj!=null): effectObj.burst(position+burstEffectPos[stance]);

func hit(movement = false):
	if stance==Stance.UP: 
		play(Anim.HIT_UP);
	else:
		play(Anim.HIT_DOWN);
	if movement:
		pounce(-direction, 100, 12);
	
func defend(movement = false):
	if stance==Stance.UP: 
		play(Anim.DEFEND_UP);
	else:
		play(Anim.DEFEND_DOWN);
	if movement:
		shake(20, 5);
		if(effectObj!=null): effectObj.block(position+blockEffectPos[stance]);
	
func set_position_xy(x,y):
	originalPos = Vector2(x,y);
	
func set_position(posVector):
	originalPos = posVector;

func shake(intensity, delay = 0):
	actionDelay = delay;
	shakeTimer = intensity;
	
func pounce(direction, intensity, delay = 0):
	actionDelay = delay;
	pounceIntensity = intensity;
	pounceDir = direction;
	pounceTimer = 1;
	pounceTimer2 = 1;

func cpu_change_stance():
	if(cpuRepeat > 0):
		cpuRepeat-=1;
		return;
	
	var prev_pose = pose;
	var prev_stance = stance;
	
	var pose_list = [Pose.IDLE, Pose.DEFEND];
	var stance_list = [Stance.UP, Stance.DOWN];
	
	pose = pose_list[randi() % pose_list.size()];
	stance = stance_list[randi() % stance_list.size()];
	
	while(prev_pose == pose && prev_stance == stance && cpuRepeatAllowance <= 0):
		pose = pose_list[randi() % pose_list.size()];
		stance = stance_list[randi() % stance_list.size()];
		
	if(prev_pose == pose && prev_stance == stance):
		cpuRepeatAllowance -= 1;
	else:
		cpuRepeatAllowance = 1;
	
	cpuRepeat = cpuDifficulty;

func default_pose():
	if(!playing || animation in [Anim.IDLE_UP, Anim.IDLE_DOWN, Anim.DEFL_UP, Anim.DEFL_DOWN] ):
		z_index = 50;
		if stance==Stance.UP: 
			if pose==Pose.IDLE:
				play(Anim.IDLE_UP);
			elif pose==Pose.DEFEND:
				play(Anim.DEFL_UP);
		elif stance==Stance.DOWN:
			if pose==Pose.IDLE:
				play(Anim.IDLE_DOWN);
			elif pose==Pose.DEFEND:
				play(Anim.DEFL_DOWN);

func _process(delta):
	hpGhost = hp + ((hpGhost-hp)/1.05);
	spGhost = sp + ((spGhost-sp)/1.05);
	
	if(actionDelay > 0):
		actionDelay -= 1;
	else:
		if(pounceTimer>0.01):
			pounceTimer = pounceTimer - pounceTimer/2.0;
			pouncePos = Vector2(pounceDir * (pounceIntensity - (pounceTimer * pounceIntensity)), 0);
		elif(pounceTimer2 > 0.01):
			pounceTimer2 = pounceTimer2 - pounceTimer2/5.0;
			pouncePos = Vector2(pounceDir * pounceTimer2 * pounceIntensity, 0);
		else:
			pounceTimer2 = 0;
			pounceTimer = 0;
			
		
		if(shakeTimer > 0.05):
			shakeTimer = shakeTimer - shakeTimer/5.0;
			var randX = rand_range(-3,3) * shakeTimer;
			var randY = rand_range(-3,3) * shakeTimer;
			shakePos = Vector2(randX, randY);
		else:
			shakeTimer = 0;
	
	self.position = originalPos + shakePos + pouncePos;


func on_animation_end():
	playing = false;
	default_pose();
