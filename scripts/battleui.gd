extends Node2D

@onready var lifebar := $Sprite2D/lifebar
@onready var stancebar := $Sprite2D/stancebar
@onready var charname := $charactername

func set_character(namee: String) -> void:
	charname.set_text(namee)

func set_lifebar(life: int) -> void:
	lifebar.set_value(life)

func set_stancebar(stance: int) -> void:
	stancebar.set_value(stance)
