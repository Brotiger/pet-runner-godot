extends CharacterBody2D

signal health_changed(health)

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@export var animated_sprite_2d: Node
@export var animation_player: Node

var max_health = 100
var health: int
var gold = 0
var state = MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false

enum {
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE,
	DAMAGE,
	DEATH,
}

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	Signals.connect("enemy_damage", Callable(self, "_on_damage_received"))
	health = max_health

func _physics_process(delta):
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
		DAMAGE:
			damage_state()
		DEATH:
			death_state()
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if velocity.y > 0:
		animation_player.play("Fall")

	move_and_slide()
	
	Signals.emit_signal("player_position_update", position)
		
func move_state():
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED * run_speed
		
		if velocity.y == 0 :
			if run_speed <= 1:
				animation_player.play("Walk")
			else:
				animation_player.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0 :
			animation_player.play("Idle")
			
	if direction == -1:
		animated_sprite_2d.flip_h = true
	elif direction == 1:
		animated_sprite_2d.flip_h = false
		
	if Input.is_action_pressed("run"):
		run_speed = 2
	else:
		run_speed = 1
		
	if Input.is_action_pressed("block"):
		if velocity.x == 0:
			state = BLOCK
		else:
			state = SLIDE
			
	if Input.is_action_just_pressed("attack") and attack_cooldown == false:
		state = ATTACK
		
func block_state():
	velocity.x = 0
	animation_player.play("Block")
	if Input.is_action_just_released("block"):
		state = MOVE
		
func slide_state():
	animation_player.play("Slide")
	await animation_player.animation_finished
	state = MOVE
	
func attack_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	
	velocity.x = 0
	animation_player.play("Attack")
	await animation_player.animation_finished
	attack_freeze()
	state = MOVE

func attack2_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK3
	animation_player.play("Attack2")
	await animation_player.animation_finished
	state = MOVE
	
func attack3_state():
	animation_player.play("Attack3")
	await animation_player.animation_finished
	state = MOVE

func combo1():
	combo = true
	await animation_player.animation_finished
	combo = false

func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false
	
func damage_state():
	velocity.x = 0
	animation_player.play("Damage")
	await animation_player.animation_finished
	state = MOVE
	
func death_state():
	velocity.x = 0
	animation_player.play("Death")
	await animation_player.animation_finished
	queue_free()
	get_tree().change_scene_to_file.bind("res://scenes/menu/menu.tscn").call_deferred()
	
func _on_damage_received(enemy_damage):
	health -= enemy_damage
	
	if health <= 0:
		health = 0
		state = DEATH
	else:
		state = DAMAGE
	
	emit_signal("health_changed", health)
