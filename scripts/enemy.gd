extends "res://scripts/player.gd"

@onready var myframes := preload("res://assets/alien.png")
@onready var hesitate := $hesitate
@onready var explosion := $explosion

var player: CharacterBody2D = null
var howclose := 80
var advantage := 0.1

func _to_string() -> String:
	return "Alberto el Alien"

func _ready() -> void:
	battleui.set_character(self._to_string())
	remove_from_group("player")
	speed = 200
	slashtimer.wait_time += advantage
	hesitate.wait_time = advantage
	super.sprite_swap(myframes)
	
func where2go() -> Vector2:
	if player == null or player.position.distance_to(position) < howclose:
		return Vector2(0, 0)
	else:
		return (player.position - position).normalized()
		
func slashing() -> void:
	if not player == null and hesitate.is_stopped():
		if player.position.distance_to(position) < howclose:
			slashnow()
			hesitate.start()
			await hesitate.timeout
			slashanimating()

func inputanim() -> void:
	pass
	
func slashanimate() -> void:
	pass

func _on_slashtimer_timeout() -> void:
	hesitate.start()
	super._on_slashtimer_timeout()

func die() -> void:
	anim.visible = false
	super.die()
	explosion.visible = true
	explosion.play("EXPLODE")
	
func _on_playerdetector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_explosion_animation_finished() -> void:
	explosion.visible = false
	battleui.reparent(get_parent())
	
	queue_free()
