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

func press_button(name, press = true):
	get_node('Buttons/' + name).set_pressed(press)

func show_buttons():
	for button in $Buttons.get_children():
		button.modulate = Color('ffffffff')

func hide_menu_game():
	yield(get_tree().create_timer(0.5), 'timeout')
	$'../AnimationPlayer'.play_backwards('ShowMenuGame')
	$Buttons/Game.set_pressed(false)

func hide_button(name):
	disable_button(name)
	get_node('Buttons/' + name).modulate = Color('00ffffff')

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
	if $Buttons/Designer.is_pressed():
		$'../'.designer_clicked()

func _on_Constraints_pressed():
	$'../'.show_abstract_game(get_parent().MAGIC_CIRCLE)

func _on_Tokens_pressed():
	$'../'.show_abstract_game(get_parent().TOKENS)
	
	
func _on_Rules_pressed():
	$'../'.show_abstract_game(get_parent().RULES)


func _on_Context_pressed():
	pass # replace with function body
