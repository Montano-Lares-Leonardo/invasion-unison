extends Node

class Espada:
	var myname:= ""
	var desc:= ""
	var dmg:= 1
	
	func _init(name: String, description: String, damage: int) -> void:
		myname = name
		desc = description
		dmg = damage
