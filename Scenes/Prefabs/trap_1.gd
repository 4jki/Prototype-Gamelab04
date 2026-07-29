extends Area2D

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("Player"):
		# Trigger death on the player (shinobi.gd handles playing DeathSFX, 
		# playing the Death animation fully, and reloading the scene)
		if body.has_method("die"):
			body.die()
