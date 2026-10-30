extends CharacterBody2D

@onready var anim := $bodyanim
@onready var slash := $slash
@onready var slashanim := $slash/slashanim
@onready var deflectanim := $slash/deflectanim
@onready var slashtimer := $slash/slashtimer
@onready var knockback := $knockback
@onready var battleui := $CanvasLayer/battleui
@onready var downed := $downed
@onready var sfx := $sfxplayer
@onready var walkin := $sfxplayer/walktimer
@onready var stepsfx := preload("res://sfx/step.wav")

var sword: Sword.Espada
var speed = 300.0
var slashspeed = 0.4
var timing: Timer = null
var slashorigin: CharacterBody2D
var life := 99
var stance := 99 
var reflected := false

func _to_string() -> String:
	return "Juan el Humano"

func _ready() -> void:
	battleui.set_character(self._to_string())
	slashtimer.wait_time = slashspeed

func _physics_process(_delta: float) -> void:
	if not Stop.stop and downed.is_stopped():
		if not slash.monitoring and knockback.is_stopped() and life > 0:
			var direction := where2go()
			if direction:
				velocity = direction * speed
				slash.rotation = direction.angle() + 1.570796
			else:
				velocity = velocity.move_toward(Vector2(0, 0), speed)
				
			move_and_slide()
			
			slashing()
		elif not knockback.is_stopped() and slashorigin != null:
				velocity = (slashorigin.position - position).normalized() * -800
				move_and_slide()

func where2go() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

func slashing() -> void:
	if Input.is_action_just_pressed("slash"):
		slashnow()

func slashnow() -> void:
	slash.monitoring = true
	if timing != null:
		var howgood = timing.time_left / timing.wait_time
		if howgood >= 0.9:
			heal(5, 5)
			print("taking damage from perfect reflect")
			reflected = true
			slashorigin.hit(0, 30)
		elif howgood >= 0.7:
			print("taking damage from awesome reflect")
			reflected = true
			slashorigin.hit(0, 20)			
		elif howgood >= 0.5:
			slashorigin.hit(0, 15)
			print("taking damage from nice reflect")
			reflected = true
			hit(0, 5)
			print("taking damage from reflecting nicely")
		elif howgood >= 0.3:
			print("taking damage from reflecting too late")
			reflected = true
			hit(20, 10)
		else:
			print("taking damage from reflecting pathetically")
			reflected = true
			hit(20, 20)
			
		if howgood >= 0.5:
			deflectanim.visible = true
			deflectanim.play("deflect")
		timing = null
	slashtimer.start()

func _process(_delta: float) -> void:
	if not Stop.stop and downed.is_stopped():
		if not slash.monitoring and knockback.is_stopped() and life > 0:
			if velocity == Vector2.ZERO:
				anim.play("stand" + plyrdirection())
				inputanim()
			else:
				playsimple(stepsfx)
				if velocity.x >= 250 or velocity.x <= -250:
					anim.play("walklr")
					anim.flip_h = velocity.x < 0
				elif velocity.y > 0:
					anim.play("walkdown")
				elif velocity.y < 0:
					anim.play("walkup")
				
				if velocity.y > 0:
					slashanim.z_index = 1
				else:
					slashanim.z_index = -1
		slashanimate()
	elif not downed.is_stopped():
		anim.play("hurt")

func playsimple(sound: AudioStreamWAV) -> void:
	if not sfx.is_playing():
		print(sound)
		sfx.stream = stepsfx
		sfx.play()
 

func inputanim() -> void:
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		anim.play("standlr")
		anim.flip_h = Input.is_action_pressed("ui_left")
	elif Input.is_action_pressed("ui_up"):
		anim.play("standup")
	elif Input.is_action_just_pressed("ui_down"):
		anim.play("standdown")

func slashanimate() -> void:
	if Input.is_action_just_pressed("slash") and life > 0:
		slashanimating()

func slashanimating() -> void:
	slashanim.play("slash")
	anim.play("slash" + plyrdirection())
	slashanim.visible = true
	await slashanim.animation_finished
	slashanim.visible = false
	deflectanim.visible = false

func plyrdirection() -> String:
	var animname := ""
	if anim.get_animation() != "hurt" and anim.get_animation() != "dead":
		animname += anim.get_animation()
		animname = animname.trim_prefix("walk")
		animname = animname.trim_prefix("stand")
		animname = animname.trim_prefix("slash")
	else:
		animname += "down"
	return animname
	
func sprite_swap(p_texture) -> void:
	var unique_frames = anim.sprite_frames.duplicate(true)
	anim.sprite_frames = unique_frames
	for anim_name in anim.sprite_frames.get_animation_names():
		for i in anim.sprite_frames.get_frame_count(anim_name):
			var texture : AtlasTexture = anim.sprite_frames.get_frame_texture(anim_name, i).duplicate(true)
			anim.sprite_frames.set_frame(anim_name, i, texture)
			texture.atlas = p_texture

func slashed(timer: Timer, enemy: CharacterBody2D) -> void:
	slashorigin = enemy
	timing = timer
	await timer.timeout
	if not slash.monitoring and not reflected:
		timing = null
		hit(20, 0)
		print("taking damage from not reflecting")
	elif reflected:
		reflected = false

func hit(hp: int, sp: int):
	changestats(hp, sp)
	anim.play("hurt")
	knockback.start()
	if life <= 0:
		die()
	if not downed.is_stopped():
		heal(0, 99)
		downed.stop()
		reflected = false
	elif stance <= 0:
		reflected = false
		downed.start()
		
func heal(hp: int, sp: int)-> void:
	changestats(-hp, -sp)

func changestats(hp: int, sp: int) -> void:
	life -= hp
	battleui.set_lifebar(life)
	stance -= sp
	battleui.set_stancebar(stance)

func die() -> void:
	anim.play("dead")

func _on_slash_body_entered(body: Node2D) -> void:
	if body.is_in_group("slashable") and body != self:
		body.slashed(slashtimer, self)

func _on_slashtimer_timeout() -> void:
	slash.monitoring = false
