class_name Enemy
extends CharacterBody2D

@export var speed: float = 60.0
@export var direction: int = 1 # 1 = Right, -1 = Left
@export var flip: bool = false

var alive: bool = true

@onready var wall_ray: RayCast2D = $Sprite/Ray/wallRay
@onready var floor_ray: RayCast2D = $Sprite/Ray/floorRay

func _ready() -> void:
	add_to_group("enemy")
	if has_node("DeathParticles"):
		$DeathParticles.one_shot = true
	
	# Standardize starting direction
	if direction > 0: direction = 1
	if direction < 0: direction = -1

func _process(_delta: float) -> void:
	# Flip sprite based on direction
	if $Sprite:
		$Sprite.scale.x = -1 if flip else 1

func _physics_process(delta: float) -> void:
	# Apply gravity if in the air
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if alive and is_on_floor():
		# Turn around if hitting a wall, wall raycast detects a wall, or floor raycast detects a ledge/edge
		var hitting_wall = is_on_wall() or (wall_ray and wall_ray.is_colliding())
		var near_edge = floor_ray and not floor_ray.is_colliding()
		
		if hitting_wall or near_edge:
			direction = -direction
		
		# Move continuously back and forth
		velocity.x = speed * direction 
	else:
		velocity.x = 0
	
	# Update visual flip state
	flip = (direction > 0)
	
	move_and_slide()

# --- Hitbox & Damage Handling ---
func _on_hit_area_body_entered(body: Node2D) -> void:
	if not alive:
		return

	# Deal damage to player on touch and play death sound
	if body.is_in_group("player") or body.is_in_group("Player") or body is Fighter or body is Samurai or body is Shinobi:
		if AudioManager and AudioManager.has_node("DeathSfx"):
			AudioManager.get_node("DeathSfx").play()

		if body.has_method("take_damage"):
			body.take_damage(1)

	# Die on hazard contact
	if body.is_in_group("Traps"):
		death_tween()

	# Die on player fireball hit
	if body.is_in_group("Bullet"):
		if GameManager and GameManager.has_method("add_score"):
			GameManager.add_score()
		death_tween()
		body.queue_free()

func death_tween() -> void:
	alive = false
	collision_layer = 0
	if has_node("Sprite"):
		$Sprite.hide()
	if has_node("DeathParticles"):
		$DeathParticles.emitting = true
	if has_node("DeathSfx"):
		$DeathSfx.play()
	await get_tree().create_timer(1.0).timeout
	queue_free()
