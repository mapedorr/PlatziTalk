extends Label

signal completed

export(float) var animation_time = 0.01
export(int) var character_speed = 2
export(bool) var animate_on_set_text = true

var default_position
var default_size

func _ready():
	default_position = get_position()
	default_size = get_size()
	$Timer.set_wait_time(animation_time)
	set_visible_characters(0)

func start_animation():
	$Timer.start()

func _on_Timer_timeout():
	if get_visible_characters() < text.length():
		set_visible_characters(
			get_visible_characters() + character_speed
		)
	else:
		$Timer.stop()
		completed()

func set_text(text):
	set_defaults()
	.set_text(text)

	if text != '':
		set_visible_characters(0)
		if animate_on_set_text and text and text.length() > 0:
			start_animation()
		else:
			set_visible_characters(-1)
			completed()

func set_defaults(): 
	.set_text('')
	rect_size = default_size
	rect_position = default_position
	$Timer.stop()

func completed():
	emit_signal('completed')