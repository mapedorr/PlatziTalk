extends Control

export(bool) var auto_init = false
export(int, 'Sheets', 'Goals', 'Creation', 'Context', 'Conclusion', 'Thanks') var step = 0

enum AbstractGameParts {
	MAGIC_CIRCLE,
	TOKENS,
	RULES,
	FEEDBACK_LOOP
}

onready var learned_info = $AbstractGame/MentalModel/LearnedInformation
onready var animated_label = preload('res://Presentation/Game/Tokens/AnimatedLabel/AnimatedLabel.tscn')
onready var animated_label_font = preload('res://Presentation/CustomResources/DynamicFonts/KennyPixelRegular-72.tres')
onready var rules_fixed = load('res://Presentation/Game/Sprites/AbstractGame/Rules-Fixed.png')
onready var thanks_label = $Thanks/Carenalga/PanelContainer/Thanks

var minutes = 20
var seconds = 0
var current_sheet = 3
var goals_open = false
var first_time_goals = true
var shown_abstract_game_parts = 0
var interacting = false
var abstract_game_info = [
	'  :-D  Puedo adelantar el tiempo',
	'  :-|  Puedo ponerme a cosechar',
	'  :-(  Si cojo armas me arrestan',
	'  >:(  No entiendo por qué me morí'
]
var info_index = 0
var mental_model_fixed = false
var abstract_game_finished = false
var fake_button_click = 0
var show_designer_context = false
var conclusions = [
	'Un juego es un espacio de experimentación de un mundo.',
	'El juego tiene partes, reglas, funcionalidades y estética.',
	'El ciclo jugador-juego-jugador produce un modelo mental en el segundo.',
	'Los juegos son una herramienta de expresión para el diseñador y el jugador.',
	'El diseñador crea a partir de las limitaciones.'
]
var shown_questions = 0
var current_conclusion = 0
var goto_thanks = false

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
		3:
			step_context(true)
		4:
			step_conclusions(true)
		5:
			step_thanks(true)

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

		if current_conclusion == conclusions.size():
			$GoalsList.check_goals()
		elif shown_questions == 3:
			$GoalsList.check_designer_questions()
			$AnimationPlayer.play('ShowDesignQuestions', -1.0, -2.0, true)
			yield($AnimationPlayer, 'animation_finished')
			$UI.hide_button('Designer')

		$AnimationPlayer.play('ToggleGoals', -1.0, 2.0)
		yield($AnimationPlayer, 'animation_finished')
	else:
		goals_open = false
		$AnimationPlayer.play('ToggleGoals', -1.0, -2.5, true)

		if current_conclusion == conclusions.size():
			yield($AnimationPlayer, 'animation_finished')
			$UI.hide_button('Goals')
			$AnimationPlayer.play('ShowThanks')
			yield($AnimationPlayer, 'animation_finished')
			thanks_label.set_text('¡G R A C I A S!')
			yield(thanks_label, 'completed')
			yield(get_tree().create_timer(2.0), 'timeout')
			thanks_label.set_text('¿P R E G U N T A S?')
			yield(thanks_label, 'completed')
			yield(get_tree().create_timer(3.0), 'timeout')
			thanks_label.set_text('Quise hacer un juego para la presentación' \
				+ ' pero no le dediqué tanto tiempo a fin de cuentas' \
				+ ' y por eso quedó este intento de presentación-juego,' \
				+ ' que más bien no tiene nada de juego y sí mucho de' \
				+ ' presentación. . .')
			yield(thanks_label, 'completed')
		elif shown_questions == 3:
			yield($AnimationPlayer, 'animation_finished')
			$AnimationPlayer.play('ShowConclusions')
			$Conclusions.disabled = false
		else:
			step_creation_buttons()

func show_abstract_game(part):
	shown_abstract_game_parts += 1

	match part:
		MAGIC_CIRCLE:
			$AbstractGame/Magic_Circle.show()
			$AbstractGame/World.show()
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

func step_context(forced = false):
	if forced:
		current_sheet = -1
		$Sheets.hide()
		$GoalsList.initialize()
		$UI.enable_button('Goals')
		$UI.enable_button('Designer')
		yield(get_tree().create_timer(1.0), 'timeout')
	
	$GoalsList.check_designer_perspective()
	$UI.press_button('Goals')
	toggle_goals()

	$UI.hide_button('Game')
	$UI.hide_button('Player')
	$UI.press_button('Designer', false)

	# Set the flag that will make the Designer button show the context when clicked
	show_designer_context = true

func step_conclusions(forced = false):
	if forced:
		shown_questions = 3
		current_sheet = -1
		$Sheets.hide()
		$GoalsList.initialize()
		$UI.press_button('Goals')
		$UI.enable_button('Goals')
		toggle_goals()

	$GoalsList.check_designer_perspective()

func step_thanks(forced = false):
	if forced:
		current_conclusion = conclusions.size()
		shown_questions = 3
		current_sheet = -1
		$Sheets.hide()
		$GoalsList.initialize()
		$UI.enable_button('Goals')

	yield($Conclusions.byebye(), 'completed')

func _on_Player_pressed():
	if not interacting:
		interact()
	else:
		for i in range(0, info_index):
			if learned_info.get_child(i):
				learned_info.get_child(i).hide()

		# The mental model should be on screen. Hide it and then interact.
		learned_info.hide()
		$AnimationPlayer.play_backwards('ShowMentalModel')
		yield($AnimationPlayer, 'animation_finished')

		# Enable interaction after the mental model panel is closed
		interacting = false

		if not abstract_game_finished \
				and $'AbstractGame/Magic_Circle/FixGameButton'.is_disabled():
			interact()
		elif abstract_game_finished:
			hide_abstract_game()

func interact():
	interacting = true

	# Interact with the game
	$AnimationPlayer.play('Interact')
	$FeedbackLoopPlayer.play('SendInput', -1.0, 2.0)
	yield($FeedbackLoopPlayer, 'animation_finished')

	# TODO: Show the loop in the game
	yield(get_tree().create_timer(2.0), 'timeout')

	# Send the feedback to the player
	$FeedbackLoopPlayer.play('SendFeedback', -1.0, 2.0)
	yield($FeedbackLoopPlayer, 'animation_finished')

	# Learn something about the game
	$AnimationPlayer.play('ShowMentalModel')
	yield($AnimationPlayer, 'animation_finished')
	learned_info.show()

	for i in range(0, info_index):
		if learned_info.get_child(i):
			learned_info.get_child(i).show()

	var instance = animated_label.instance()
	instance.add_font_override('font', animated_label_font)
	instance.set_autowrap(true)
	learned_info.add_child(instance)

	if info_index < abstract_game_info.size():
		instance.set_text(abstract_game_info[info_index])
		info_index += 1

	if info_index == abstract_game_info.size() and not mental_model_fixed:
		instance.add_color_override('font_color', Color('#f55e61'))
		$'AbstractGame/Magic_Circle/FixGameButton'.disabled = false
	elif info_index == abstract_game_info.size() and mental_model_fixed:
		abstract_game_finished = true

	yield(instance, 'completed')

func _on_FakeButton_pressed():
	fake_button_click += 1
	match fake_button_click:
		1:
			$DesignGoal/Label2.show()
			for p in $DesignGoal/Perspectives.get_children():
				p.self_modulate = Color('ffffffff')
				$Tween.interpolate_property(
					p,
					'rect_scale',
					Vector2(0.0, 0.0),
					Vector2(1.0, 1.0),
					0.4,
					$Tween.TRANS_SINE,
					$Tween.EASE_OUT
				)
				$Tween.start()
				yield(get_tree().create_timer(0.5), 'timeout')
		2:
			$AnimationPlayer.play_backwards('ShowDesignGoal')
			yield($AnimationPlayer, 'animation_finished')
			$UI.enable_button('Game')


func _on_FixGameButton_pressed():
	mental_model_fixed = true
	$'AbstractGame/Magic_Circle/FixGameButton'.disabled = true

	var childs = learned_info.get_children().size() - 1
	abstract_game_info[childs - 1] = '  :-O  ¡Ah!. . . el frío me mata'
	# abstract_game_info.append('  :)  Los perros me defienden')
	abstract_game_info.append('  :-)  ¿Qué pasará si le digo que no?')
	abstract_game_info.append('  :-(  Fue mi culpa que se muriera')
	abstract_game_info.append('  :-D  Síiiiiii.....¡Toma eso gonorrea!, por\n  matar al perrito')
	abstract_game_info.append('  :-)  Si lo atacamos al tiempo seguro que\n  le ganamos')
	abstract_game_info.append('  :-)  Severo juego')

	learned_info.get_child(childs).queue_free()
	learned_info.remove_child(learned_info.get_child(childs))

	info_index -= 1
	$AbstractGame/Rules.texture = rules_fixed

func hide_abstract_game():
	$AnimationPlayer.play('HideAbstractGame')
	yield($AnimationPlayer, 'animation_finished')
	
	step_context()

func designer_clicked():
	if show_designer_context:
		$AnimationPlayer.play('ShowDesignQuestions')
	else:
		$AnimationPlayer.play('ShowDesignGoal')

func _on_QuestionButton_pressed(button):
	$AnimationPlayer.play('ShowQuestion%s' % button)
	$DesignQuestions.get_node('Question%s/QuestionButton' % button).set_disabled(true)
	shown_questions += 1
	if shown_questions == 3:
		yield($AnimationPlayer, 'animation_finished')


func _on_Conclusions_drag_end():
	if conclusions.size() <= current_conclusion:
		step_thanks()
		return

	var conclusion = $Conclusions/Container/List.get_child(current_conclusion)
	conclusion.set_text(conclusions[current_conclusion])
	yield(conclusion, 'completed')
	current_conclusion += 1