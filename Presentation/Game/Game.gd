extends Control

var minutes = 20
var seconds = 0
var current_sheet = 3

func _ready():
	# Called when the node is added to the scene for the first time.
	$Sheets/Area2D/Collision_Area.polygon[1].x = $UI/Background.texture.get_width()
	$Sheets/Area2D/Collision_Area.polygon[2].x = $UI/Background.texture.get_width()
	$Sheets/Area2D/Collision_Area.polygon[2].y = $UI/Background.texture.get_height()
	$Sheets/Area2D/Collision_Area.polygon[3].y = $UI/Background.texture.get_height()
	
	# Hide the UI
	$UI/Buttons/Tokens.self_modulate = Color('00ffffff')
	$UI/Buttons/Rules.self_modulate = Color('00ffffff')
	$UI/Buttons/Player.self_modulate = Color('00ffffff')
	$UI/Buttons/Goals.self_modulate = Color('00ffffff')

func initialize():
	next_sheet()
	$Timer.start()

func next_sheet():
	$Sheets.get_child(current_sheet).disabled = false
	current_sheet -= 1
	if current_sheet < 0:
		$UI/Buttons/Goals.self_modulate = Color('ffffffff')
		$AnimationPlayer.play('ToggleGoals', -1.0, 2.0)

func _on_Timer_timeout():
	seconds -= 1
	if seconds < 0:
		seconds = 59
		minutes -= 1
		
		if minutes < 0:
			$Timer.stop()
			return
	
	$UI/Time.set_text('%02d:%02d' % [minutes, seconds])

func _on_Area2D_area_entered(area):
	area.get_parent().byebye = true