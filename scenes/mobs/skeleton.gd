extends CharacterBody2D

const SPEED = 100

@export var animated_sprite_2d: Node
@export var player: Node

var alive = true
var chase = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	var direction = (player.position - self.position).normalized()
	
	if alive == true:
		if chase == true:
			velocity.x = direction.x * SPEED
			animated_sprite_2d.play("Run")
		else:
			velocity.x = 0
			animated_sprite_2d.play("Idle")
			
		if direction.x < 0:
			animated_sprite_2d.flip_h = true
		elif direction.x > 0:
			animated_sprite_2d.flip_h = false	
		
	move_and_slide()

func _on_detector_body_entered(body):
	if body.name == "Player":
		chase = true

func _on_detector_body_exited(body):
	if body.name == "Player":
		chase = false


func _on_death_body_entered(body):
	if body.name == "Player":
		body.velocity.y -= 250
		death()
		
func _on_death_2_body_entered(body):
	if body.name == "Player":
		if alive == true:
			body.health -= 40
			death()
	
func death():
	alive = false
	animated_sprite_2d.play("Death")
	await animated_sprite_2d.animation_finished
	queue_free()
