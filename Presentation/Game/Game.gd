extends Control

export(bool) var auto_init = false
export(int, 'Sheets', 'Goals', 'Creation') var step = 0

enum AbstractGameParts {
	MAGIC_CIRCLE,
	TOKENS,
	RULES,
	FEEDBACK_LOOP
}

var minutes = 20
var seconds = 0
var current_sheet = 3
var goals_open = false
var first_time_goals = true
var shown_abstract_game_parts = 0
var interacting = false
var abstract_game_info = [
	'  :D  Puedo adelantar el tiempo',
	'  :|  Puedo ponerme a cosechar',
	'  :(  Si cojo armas me arrestan',
	'  >:( No entiendo por qué me morí'
]
onready var learned_info = $AbstractGame/MentalModel/LearnedInformation
onready var animated_label = preload('res://Presentation/Game/Tokens/AnimatedLabel/AnimatedLabel.tscn')
# onready var animated_label_font = preload('res://Presentation/Game/Tokens/AnimatedLabel/AnimatedLabel.tscn')
var info_index = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	$SheetEater/Collision_Area.polygon[1].x = $UI/Background.texture.get_width()
	$SheetEater/Collision_Area.polygon[2].x = $UI/Background.texture.get_width()
	$SheetEater/Collision_Area.polygon[2].y = $UI/Background.texture.get_height()
	$SheetEater/Collision_Area.polygon[3].y = $UI/Background.texture.get_height()

	for game_part in $AbstractGame.get_children():
		game_part.hide()
	
	if auto_init:
		initialize()

func initialize():
	$UI.initialize()

	$Timer.start()

	match step:
		0:
			$Sheets.show()
			next_sheet()
		1:
			step_goals(true)
		2:
			step_creation_buttons(true)

func next_sheet():
	$Sheets.get_child(current_sheet).disabled = false
	current_sheet -= 1
	if current_sheet < 0:
		step_goals()

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
	
func toggle_goals():
	if not goals_open:
		goals_open = true
		$AnimationPlayer.play('ToggleGoals', -1.0, 2.0)
	else:
		goals_open = false
		$AnimationPlayer.play('ToggleGoals', -1.0, -2.5, true)
		step_creation_buttons()

func show_abstract_game(part):
	shown_abstract_game_parts += 1

	match part:
		MAGIC_CIRCLE:
			$AbstractGame/Magic_Circle.show()
			$AnimationPlayer.play('ShowMagicCircle')
			$UI/MenuGame/Constraints.set_disabled(true)
			$UI.hide_menu_game()
		TOKENS:
			$AbstractGame/Tokens.show()
			$UI/MenuGame/Tokens.set_disabled(true)
			$UI.hide_menu_game()
		RULES:
			$AbstractGame/Rules.show()
			$UI/MenuGame/Rules.set_disabled(true)
		FEEDBACK_LOOP:
			$AbstractGame/Feedback.show()
			$AbstractGame/Input.show()
			$AbstractGame/Message.show()
			$AbstractGame/MentalModel.show()
			$AbstractGame/Player_Interact.show()
			$AbstractGame/Player.show()
			$AnimationPlayer.play('AddPlayer')
			$UI.disable_button('Player')

	if shown_abstract_game_parts == 3:
		$AnimationPlayer.play_backwards('ShowMenuGame')
		$UI.disable_button('Game')
		$UI.enable_button('Player')

func step_goals(forced = false):
	if forced:
		current_sheet = -1
		for sheet in $Sheets.get_children():
			yield(sheet.byebye(), 'completed')
	$GoalsList.initialize()
	$UI.enable_button('Goals')

func step_creation_buttons(forced = false):
	if forced:
		current_sheet = -1
		$Sheets.hide()
		$GoalsList.initialize()
		$UI.enable_button('Goals')

	if first_time_goals:
		first_time_goals = false
		$UI.enable_button('Designer')


func _on_Player_pressed():
	if not interacting:
		interact()
	else:
		for i in range(0, info_index):
			learned_info.get_child(i).hide()

		# The mental model should be on screen. Hide it and then interact.
		$AnimationPlayer.play_backwards('ShowMentalModel')
		yield($AnimationPlayer, 'animation_finished')

		# Enable interaction after the mental model panel is closed
		interacting = false

		interact()


func interact():
	interacting = true

	# Interact with the game
	$AnimationPlayer.play('Interact')
	$FeedbackLoopPlayer.play('SendInput')
	yield($FeedbackLoopPlayer, 'animation_finished')

	# TODO: Show the loop in the game
	yield(get_tree().create_timer(2.0), 'timeout')

	# Send the feedback to the player
	$FeedbackLoopPlayer.play('SendFeedback')
	yield($FeedbackLoopPlayer, 'animation_finished')

	# Learn something about the game
	$AnimationPlayer.play('ShowMentalModel')
	yield($AnimationPlayer, 'animation_finished')

	for i in range(0, info_index):
		learned_info.get_child(i).show()

	var instance = animated_label.instance()
	learned_info.add_child(instance)

	if info_index < abstract_game_info.size():
		instance.set_text(abstract_game_info[info_index])
		info_index += 1

	yield(instance, 'completed')
