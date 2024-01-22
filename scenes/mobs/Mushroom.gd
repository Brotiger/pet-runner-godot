extends CharacterBody2D

@export var sprite: Node
@export var attack_direction: Node
@export var animation_player: Node
@export var attack_collision: Node
@export var damage = 20

var player_pos: Vector2
var direction: Vector2
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum {
	IDLE,
	ATTACK,
	CHASE
}

var state = IDLE:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()

func _ready():
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))
	
func _on_player_position_update(pos):
	player_pos = pos
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if state == CHASE:
		chase_state()
		
	move_and_slide()

func _on_attack_range_body_entered(_body):
	state = ATTACK

func idle_state():
	animation_player.play("Idle")
	await get_tree().create_timer(1).timeout
	attack_collision.disabled = false
	state = CHASE

func attack_state():
	animation_player.play("Attack")
	await animation_player.animation_finished
	attack_collision.disabled = true
	state = IDLE

func chase_state():
	direction = (player_pos - position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		attack_direction.rotation_degrees = 180
	elif direction.x > 0:
		sprite.flip_h = false
		attack_direction.rotation_degrees = 0


func _on_hit_box_area_entered(_area):
	Signals.emit_signal("enemy_damage", damage)
