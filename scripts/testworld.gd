extends Node2D

@onready var textbox := preload("res://scenes/textbox.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var txtbx = textbox.instantiate()
	add_child(txtbx)
	txtbx.settext("I AM THE LAST HUMAN\nON EARTH!")
	txtbx.setface("alien")
