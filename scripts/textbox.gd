extends CanvasLayer

@onready var dialogue := $axis/Label
@onready var face := $axis/Sprite2D/AnimatedSprite2D
@onready var animation := $axis/animator

var dialoguefinished:= false

func _ready() -> void:
	animation.play_backwards("enter")
	Stop.stop = true

func settext(dialog: String) -> void:
	dialogue.text = dialog

func setface(facename: String) -> void:
	face.play(facename)

func _process(_delta: float) -> void:
	if Input.is_action_just_released("ui_accept") or Input.is_action_just_released("ui_cancel"):
		animation.play("enter")
		dialoguefinished = true

func _on_animator_animation_finished(_anim_name: StringName) -> void:
	if dialoguefinished:
		Stop.stop = false
		queue_free()
