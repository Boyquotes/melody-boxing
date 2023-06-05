extends AnimatedSprite


func _ready():
	hide(); 


func block(pos = null):
	show();
	if pos!= null: position = pos;
	set_frame(0);
	$block.play();
	play("block");
	
func burst(pos = null):
	show();
	if pos!= null: position = pos;
	set_frame(0);
	$hit.play();
	play("burst");
	

func _on_spr_effect_animation_finished():
	hide();

