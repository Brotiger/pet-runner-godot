extends Node2D

@export var day_text: Node
@export var animation_player: Node
@export var health_bar: Node
@export var player: Node

var day_count = 0

func _ready():
	health_bar.max_value = player.max_health
	health_bar.value = player.max_health
	
func set_day():
	day_count += 1
	day_text.text = "DAY " + str(day_count)
	day_text_fade()
	
func day_text_fade():
	animation_player.play("day_text_fade_in")
	await get_tree().create_timer(3).timeout
	animation_player.play("day_text_fade_out")


func _on_player_health_changed(health):
	health_bar.value = health
