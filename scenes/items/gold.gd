extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		var position_x = get_tree().create_tween()
		var modulate_a = get_tree().create_tween()
		position_x.tween_property(self, "position", position - Vector2(0, 15), 0.3)
		modulate_a.tween_property(self, "modulate:a", 0, 0.3)
		position_x.tween_callback(queue_free)
		body.gold += 1
