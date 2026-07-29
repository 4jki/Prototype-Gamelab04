extends Label

func _on_timer_timeout() -> void:
	# Option 1: Instant vanish
	# visible = false
	
	# Option 2: Smooth fade out (looks better)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	# Hide or remove it completely after fading
	queue_free()
