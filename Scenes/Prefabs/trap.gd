extends Node2D

func _ready() -> void:
	# Look for an Area2D child inside this Node2D
	var area = $Area2D if has_node("Area2D") else find_child("*Area2D*", true, false)
	
	if area and area is Area2D:
		if not area.body_entered.is_connected(_on_body_entered):
			area.body_entered.connect(_on_body_entered)
	else:
		push_warning("Trap Node2D relies on a child Area2D node to detect collisions!")

func _on_body_entered(body: Node2D) -> void:
	# Instantly kill the player upon contact
	if body.is_in_group("player") or body.is_in_group("Player") or body is Player:
		if body.has_method("die"):
			body.die()
