extends Area2D

# Assign a scene in the Inspector to force a specific level, 
# or leave it empty to automatically calculate the next level.
@export_file("*.tscn") var next_level_scene: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.is_in_group("player") or body is CharacterBody2D:
		change_to_next_level()

func change_to_next_level() -> void:
	# 1. If a specific scene path was manually assigned in the Inspector, use it
	if next_level_scene != "":
		_switch_scene(next_level_scene)
		return

	# 2. Automatically figure out the next level based on current level name
	var current_scene_path: String = get_tree().current_scene.scene_file_path
	# Convert to lowercase so "Level_04" and "level_04" both work!
	var current_filename: String = current_scene_path.get_file().get_basename().to_lower()

	var target_scene_path: String = ""

	# Check level progression: Level 1 -> Level 2 -> Level 3 -> Level 4 -> Game Win
	if "level_01" in current_filename or "Level_01" in current_filename:
		target_scene_path = "res://Scenes/Levels/Level_02.tscn"
	elif "level_02" in current_filename or "level_02" in current_filename:
		target_scene_path = "res://Scenes/Levels/level_03.tscn"
	elif "level_03" in current_filename or "level_03" in current_filename:
		target_scene_path = "res://Scenes/Levels/Level_04.tscn"
	elif "level_04" in current_filename or "Level_04" in current_filename:
		target_scene_path = "res://Scenes/Levels/game_win.tscn"
	else:
		print("Door Warning: Could not auto-detect next level from scene name: ", current_filename)
		return

	_switch_scene(target_scene_path)

func _switch_scene(scene_path: String) -> void:
	if typeof(SceneTransition) != TYPE_NIL and SceneTransition.has_method("load_scene_path"):
		SceneTransition.load_scene_path(scene_path)
	elif typeof(SceneTransition) != TYPE_NIL and SceneTransition.has_method("load_scene"):
		SceneTransition.load_scene(load(scene_path))
	else:
		get_tree().change_scene_to_file(scene_path)
