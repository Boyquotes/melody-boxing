extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var crowd = self.get_children();
var ori_pos = [];
var displace = [];

var timer = 0;
const MAX_TIMER = 50;
const MIN_TIMER = 30;

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in crowd:
		ori_pos.append(item.position);
		displace.append(0);


func _process(delta):
	timer -= 1;
	if(timer <= 0):
		displace[randi() % displace.size()] = 1;
		timer = rand_range(MIN_TIMER, MAX_TIMER);
		
	for i in range(crowd.size()):
		displace[i] = max(0, displace[i]-0.05);
		crowd[i].position.y = ori_pos[i].y - getOffset(displace[i]) * 20;
		


func getOffset(x):
	return 4*(x - x*x);
