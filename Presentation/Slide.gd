extends Control

onready var player = $AnimationPlayer

func play(anim_name):
	player.play(anim_name)
	yield(player, "animation_finished")
	
func goto_next():
	get_parent().next_slide()
