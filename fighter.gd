class_name Fighter
extends CharacterBody2D

# --- Movement Parameters ---
@export var WALK_SPEED: float = 140.0
@export var RUN_SPEED: float = 230.0
@export var JUMP_VELOCITY: float = -380.0
@export var ACCELERATION: float = 1000.0
@export var FRICTION: float = 1200.0

@export var ATTACK_DURATION: float = 0.3
@export var HURT_DURATION: float = 0.4
@export var FALL_DEATH_Y: float = 800.0 # Instant death Y position if player falls off map
@export var ATTACK_RANGE: float = 40.0 # Distance in front of player to check for enemies

# Projectile scene
@export var projectile_scene: PackedScene

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- State Variables ---
var is_running: bool = false
var is_attacking: bool = false
var is_hurt: bool = false
var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")
	add_to_group("Player")
	floor_snap_length = 8.0
	
	if GameManager:
		GameManager.player = self
		
		# Teleport player to checkpoint if one exists
		if "has_checkpoint" in GameManager and GameManager.has_checkpoint:
			global_position = GameManager.last_checkpoint_position

func _physics_process(delta: float) -> void:
	# Stop logic completely if dead so death animation plays smoothly
	if is_dead:
		return

	# Instant death if falling off map
	if global_position.y > FALL_DEATH_Y:
		die()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	# While hurt, lock horizontal movement and slow down
	if is_hurt:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		move_and_slide()
		_check_trap_collisions()
		return

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if AudioManager and AudioManager.has_node("JumpSfx"):
			AudioManager.get_node("JumpSfx").play()

	if Input.is_action_just_pressed("Shoot") and not is_attacking:
		_perform_attack()

	if Input.is_action_just_pressed("toggle(run_walk)"):
		is_running = !is_running

	var direction := Input.get_axis("Left", "Right")
	var target_speed := RUN_SPEED if is_running else WALK_SPEED

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * target_speed, ACCELERATION * delta)
		animated_sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	_update_animation(direction)
	move_and_slide()
	
	_check_trap_collisions()

# --- Trap & Enemy Collision Detector ---
func _check_trap_collisions() -> void:
	if is_dead or is_hurt:
		return
		
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider:
			if "Trap" in collider.name or "trap" in collider.name or collider.is_in_group("Traps") or collider.is_in_group("trap"):
				die()
				break
			elif collider.is_in_group("enemy") or collider.is_in_group("Enemy") or collider is Enemy:
				take_damage(1)
				break

func _update_animation(_direction: float) -> void:
	if is_dead:
		_play_anim_safe("Death")
	elif is_hurt:
		_play_anim_safe("Hurt")
	elif not is_on_floor():
		_play_anim_safe("Jump")
	elif is_attacking:
		return
	elif abs(velocity.x) > 10.0:
		if is_running:
			_play_anim_safe("Run")
		else:
			_play_anim_safe("Walk")
	else:
		_play_anim_safe("Idle")

# Helper function to prevent restarting the animation on every single frame
func _play_anim_safe(anim_name: String) -> void:
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

func _perform_attack() -> void:
	is_attacking = true
	var attack_animations = ["Attack1", "Attack2", "Attack3"]
	
	# Pick random attack from your list
	var chosen_anim = attack_animations[randi() % attack_animations.size()]
	_play_anim_safe(chosen_anim)

	var attack_dir = -1.0 if animated_sprite.flip_h else 1.0

	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		projectile.position = global_position
		if projectile.has_method("set_direction"):
			projectile.set_direction(attack_dir)
		get_parent().add_child(projectile)

	_damage_enemies_in_front(attack_dir)

	await get_tree().create_timer(ATTACK_DURATION).timeout
	is_attacking = false

func _damage_enemies_in_front(attack_dir: float) -> void:
	var space_state = get_world_2d().direct_space_state
	var attack_center = global_position + Vector2(attack_dir * (ATTACK_RANGE / 2.0), 0)
	
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = ATTACK_RANGE
	query.shape = shape
	query.transform = Transform2D(0, attack_center)
	query.collide_with_bodies = true
	query.collide_with_areas = true

	var results = space_state.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if collider and collider != self:
			if collider.is_in_group("enemy") or collider.is_in_group("Enemy") or collider is Enemy:
				if collider.has_method("death_tween"):
					if GameManager and GameManager.has_method("add_score"):
						GameManager.add_score()
					collider.death_tween()

func take_damage(amount: int = 1) -> void:
	if is_hurt or is_dead:
		return

	is_hurt = true
	_play_anim_safe("Hurt")
	
	if GameManager:
		if "hp" in GameManager:
			GameManager.hp -= 10
			if GameManager.hp <= 0:
				die()
				return
		elif "life" in GameManager:
			GameManager.life -= amount
			if GameManager.life <= 0:
				die()
				return

	var modulate_tween = create_tween()
	modulate_tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	modulate_tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.2)

	await get_tree().create_timer(HURT_DURATION).timeout
	is_hurt = false

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	
	# Save current level location to GameManager
	if GameManager and GameManager.has_method("record_current_level"):
		GameManager.record_current_level()

	# Play Death animation (matches your screenshot!)
	_play_anim_safe("Death")
	
	if AudioManager and AudioManager.has_node("DeathSfx"):
		AudioManager.get_node("DeathSfx").play()

	if GameManager and "life" in GameManager:
		GameManager.life -= 1

	await get_tree().create_timer(0.6).timeout
	
	if GameManager and "life" in GameManager and GameManager.life <= 0:
		get_tree().change_scene_to_file("res://Scenes/Levels/game_over.tscn")
	else:
		get_tree().reload_current_scene()
