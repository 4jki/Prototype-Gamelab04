extends Area2D

@export var heal_amount: int = 20

func _on_body_entered(body: Node2D) -> void:
	# Check if the body that touched the potion is in the Player group or one of the character classes
	if body.is_in_group("Player") or body.is_in_group("player") or body is Fighter or body is Samurai or body is Shinobi:
		if GameManager:
			# Restore HP
			if "hp" in GameManager and "max_hp" in GameManager:
				GameManager.hp = min(GameManager.hp + heal_amount, GameManager.max_hp)
			elif GameManager.has_method("heal"):
				GameManager.heal(heal_amount)
		
		# Optional: Play pickup SFX if available
		if AudioManager and AudioManager.has_node("PotionSfx"):
			AudioManager.get_node("PotionSfx").play()
			
		queue_free() # Remove potion from scene
