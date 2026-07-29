extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var solid_collision: CollisionShape2D = $SolidBlock/CollisionShape2D

func _ready() -> void:
	sprite_2d.visible = false
	solid_collision.disabled = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Fixed case sensitivity: "Player" with capital P
	if body.is_in_group("Player"):
		# Check if the player is moving UPWARD
		if body.velocity.y < 0:
			# Use call_deferred to safely enable physics collisions mid-frame
			solid_collision.set_deferred("disabled", false)
			sprite_2d.visible = true
			
			# Stop player's upward momentum instantly and push them down slightly
			body.velocity.y = 100
