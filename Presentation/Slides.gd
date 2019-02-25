extends Control

export var skip_animation = false

var index_active = 0 setget set_index_active
var slide_current
var slide_nodes = []

func initialize():
	for slide in get_children():
		slide.hide()
		slide_nodes.append(slide)
		remove_child(slide)
	slide_current = slide_nodes[0]
	add_child(slide_current)
	slide_current.show()
	if not skip_animation:
		var animation = "FadeIn"
		yield(slide_current.play(animation), "completed")

func next_slide():
	self.index_active += 1

func set_index_active(value):
	var index_previous = index_active
	index_active = clamp(value, 0, slide_nodes.size() - 1)
	if not index_active == index_previous:
		display(index_active)

func display(slide_index):
	var previous_slide = slide_current
	var new_slide = slide_nodes[slide_index]
	add_child(new_slide)
	new_slide.show()
	
	if not skip_animation:
		var animation = "FadeIn"
		yield(new_slide.play(animation), "completed")
	
	previous_slide.hide()
	remove_child(previous_slide)
	slide_current = new_slide
	
	if index_active == 1:
		# The game
		slide_current.get_node('Game').initialize()