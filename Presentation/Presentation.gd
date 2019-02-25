extends Node

onready var slides = $Slides

func _ready():
	# Called when the node is added to the scene for the first time.
	slides.initialize()