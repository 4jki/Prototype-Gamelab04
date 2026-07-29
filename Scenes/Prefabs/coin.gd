extends Area2D

@export var amplitude := 4
@export var frequency := 5

var time_passed = 0
var initial_position := Vector2.ZERO

func _ready():
	initial_position = position

func _process(delta):
	coin_hover(delta)

func coin_hover(delta):
	time_passed += delta
	var new_y = initial_position.y + amplitude * sin(frequency * time_passed)
	position.y = new_y
	rotate(randf_range(0.5, 4) * delta)

func _on_body_entered(body):
	# Checks for both "player" and "Player" groups, or individual character classes
	if body.is_in_group("player") or body.is_in_group("Player") or body is Fighter or body is Samurai or body is Shinobi:
		if AudioManager and "coin_pickup_sfx" in AudioManager:
			AudioManager.coin_pickup_sfx.play()
		if GameManager and GameManager.has_method("add_score"):
			GameManager.add_score()
			
		var tween = create_tween()
		tween.tween_property(self, "position", Vector2(position.x, position.y - 100), 0.5)
		tween.set_parallel()
		tween.tween_property(self, "scale", Vector2(2, 2), 0.5)
		await tween.finished
		queue_free()
