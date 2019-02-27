extends Container

func _ready():
	for button in $Buttons.get_children():
		button.disabled = true
		button.modulate = Color('00ffffff')

func initialize():
	pass

func enable_button(name):
	get_node('Buttons/' + name).modulate = Color('ffffffff')
	get_node('Buttons/' + name).disabled = false

func disable_button(name):
	get_node('Buttons/' + name).disabled = true

func show_buttons():
	for button in $Buttons.get_children():
		button.modulate = Color('ffffffff')

func hide_menu_game():
	yield(get_tree().create_timer(1.0), 'timeout')
	$'../AnimationPlayer'.play_backwards('ShowMenuGame')
	$Buttons/Game.set_pressed(false)

# ------------------------------------------------------------------------------
# CLICK LISTENERS!
# ------------------------------------------------------------------------------
func _on_Goals_pressed():
	$'../'.toggle_goals()


func _on_Game_pressed():
	if $Buttons/Game.is_pressed():
		$'../AnimationPlayer'.play('ShowMenuGame')
	else:
		$'../AnimationPlayer'.play_backwards('ShowMenuGame')


func _on_Player_pressed():
	$'../'.show_abstract_game(get_parent().FEEDBACK_LOOP)

func _on_Designer_pressed():
	enable_button('Game')


func _on_Constraints_pressed():
	$'../'.show_abstract_game(get_parent().MAGIC_CIRCLE)

func _on_Tokens_pressed():
	$'../'.show_abstract_game(get_parent().TOKENS)
	
	
func _on_Rules_pressed():
	$'../'.show_abstract_game(get_parent().RULES)
