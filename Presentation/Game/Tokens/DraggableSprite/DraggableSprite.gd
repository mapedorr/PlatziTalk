extends Sprite

signal drag_start
signal drag_end

export (Texture) var on_drag_texture

var mouse_hover = false
var mouse_hover_candidate = false
var drag = false
var mouse_last_position = Vector2(0, 0)
var next_slot_candidate
var previous_position = Vector2(0, 0)
var original_texture
var props = {}
var disabled = true
var byebye = false

func _ready():
	$Area2D/Collision_Area.polygon[1].x = self.texture.get_width()
	$Area2D/Collision_Area.polygon[2].x = self.texture.get_width()
	$Area2D/Collision_Area.polygon[2].y = self.texture.get_height()
	$Area2D/Collision_Area.polygon[3].y = self.texture.get_height()

	$Area2D.connect("mouse_entered", self, "on_mouse_enter")
	$Area2D.connect("mouse_exited", self, "on_mouse_exit")

	original_texture = self.texture

func _process(delta):
	if !disabled:
		self.handle_drag()

func handle_drag():
	var mouse_pos = get_viewport().get_mouse_position()

	if mouse_hover && Input.is_action_pressed("click") && not drag:
		drag = true
		previous_position = position
		mouse_last_position = mouse_pos
		$Area2D/Collision_Drawing.position = mouse_pos - global_position
#		z_index = 4
		on_drag_start()

	if drag && !Input.is_action_pressed("click"):
		drag = false
#		z_index = 0
		on_drag_end()

	if drag:
		var mouse_mov = mouse_pos - mouse_last_position
		position += mouse_mov
		mouse_last_position = mouse_pos

func on_mouse_enter():
	if not Input.is_action_pressed("click"):
		mouse_hover = true
	else:
		mouse_hover_candidate = true

func on_mouse_exit():
	mouse_hover = false
	mouse_hover_candidate = false

func on_drag_end():
	if byebye:
		yield(byebye(), 'completed')
		$'../..'.next_sheet()

func on_drag_start():
	self.texture = on_drag_texture
	object_grab()
	emit_signal("drag_start")
	next_slot_candidate = self.get_parent()

func byebye():
	disabled = true
	$Tween.interpolate_property(
		self,
		'position',
		get_position(),
		Vector2(texture.get_size().x + 1920 + 64, get_position().y),
		1.0,
		$Tween.TRANS_BOUNCE,
		$Tween.EASE_IN
	)
	$Tween.start()
	yield($Tween, 'tween_completed')

func return_to_original_position():
	pass

func object_insert():
	pass


func object_grab():
	pass

func on_overlap():
	pass

func update_title():
	pass

func set_disabled(disable = false):
	self.disabled = disable