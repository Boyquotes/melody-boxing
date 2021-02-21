extends Node

enum Character{TEMPLATE};
enum Stance {UP, DOWN}
enum Pose {CHARGE, BLOCK, PUNCH, HIT, IDLE};

var sprite_list = [];

func _ready():
	var template = [];
	
	template.append(preload("res://sprite/template/charge_up.png"));
	template.append(preload("res://sprite/template/charge_down.png"));
	
	template.append(preload("res://sprite/template/block_up.png"));
	template.append(preload("res://sprite/template/block_down.png"));
	
	template.append(preload("res://sprite/template/punch_up.png"));
	template.append(preload("res://sprite/template/punch_down.png"));
	
	template.append(preload("res://sprite/template/hit_up.png"));
	template.append(preload("res://sprite/template/hit_down.png"));
	
	template.append(preload("res://sprite/template/idle_up.png"));
	template.append(preload("res://sprite/template/idle_down.png"));
	
	sprite_list.append(template);

func sprite_index(stance, pose):
	return (pose * 2) + stance;
