extends TextureRect

export(Texture) var checked

func initialize():
	$List/Goal1/Checkbox.texture = checked

func check_designer_perspective():
	$List/Goal2/Checkbox.texture = checked

func check_designer_questions():
	$List/Goal3/Checkbox.texture = checked

func check_goals():
	$List/Goal4/Checkbox.texture = checked