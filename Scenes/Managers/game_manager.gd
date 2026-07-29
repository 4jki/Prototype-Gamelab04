# This script is an autoload, that can be accessed from any other script!

extends Node2D

var score : int = 0
var hp    : int = 100
var life  : int = 5        # Set initial lives to 5
var max_life : int = 5
var max_hp  : int = 100

var sfx_on = true
var music_on = true

var player = null
var current_level : String = "res://Scenes/Levels/Level_01.tscn"
var death_level : String = "" # Tracks level active when player died

var save_path := "user://game.save"
var save_player_position = Vector2.ZERO

# --- Checkpoint Variables ---
var last_checkpoint_position : Vector2 = Vector2.ZERO
var has_checkpoint : bool = false

# Default selected character
var selected_character_path : String = "res://Scenes/Characters/Fighter/fighter.tscn"

# --- Checkpoint System ---

func set_checkpoint(pos: Vector2) -> void:
	last_checkpoint_position = pos
	has_checkpoint = true

func clear_checkpoint() -> void:
	has_checkpoint = false
	last_checkpoint_position = Vector2.ZERO

# --- Level Tracking Additions ---

# Records the active scene file path before changing scenes
func record_current_level() -> void:
	if get_tree() and get_tree().current_scene != null:
		var active_path = get_tree().current_scene.scene_file_path
		if active_path != "":
			death_level = active_path

# Reloads the level where the player died (used by Play Again button)
func restart_current_level() -> void:
	# Refill player HP/Stats when retrying the level
	hp = max_hp
	
	if death_level != "":
		get_tree().change_scene_to_file(death_level)
	elif get_tree() and get_tree().current_scene != null and get_tree().current_scene.scene_file_path != "":
		get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)
	else:
		get_tree().change_scene_to_file("res://Scenes/Levels/Level_01.tscn")

# --------------------------------

# --- Function to reset stats for a fresh game or replay ---
func reset_player_stats() -> void:
	score = 0
	life = max_life
	hp = max_hp
	save_player_position = Vector2.ZERO
	clear_checkpoint()
	# Note: death_level is preserved so Play Again still knows where you died!

# --- Call this when picking a new character for a NEW GAME ---
func select_character(character_path: String) -> void:
	selected_character_path = character_path
	death_level = "" # Reset death tracking for a fresh playthrough
	reset_player_stats()

# Adds 1 to score variable
func add_score(v=1):
	score += v

# Loads next level
func load_next_level(next_scene : PackedScene):
	get_tree().change_scene_to_packed(next_scene)

func restart():
	death_level = ""
	reset_player_stats()
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_01.tscn")

func damage(val=1):
	hp = hp - val
	if hp <= 0:
		death()

func add_hp(val=1):
	hp = hp + val
	if hp > max_hp:
		hp = max_hp

func update_option():
	var music_bus = AudioServer.get_bus_index("music")
	var sfx_bus = AudioServer.get_bus_index("sfx")
	AudioServer.set_bus_mute(sfx_bus, !sfx_on)
	AudioServer.set_bus_mute(music_bus, !music_on)
	
func add_life():
	if life < max_life:
		life += 1

func death():
	# Record level location as soon as player dies
	record_current_level()

	if AudioManager and AudioManager.has_node("DeathSfx"):
		AudioManager.get_node("DeathSfx").play()

	if player != null and player.has_method("death_tween"):
		await player.death_tween()
	
	life -= 1
	if life <= 0:
		clear_checkpoint()
		get_tree().change_scene_to_file("res://Scenes/Levels/game_over.tscn")	

func save_option():
	var file = FileAccess.open("user://option.json", FileAccess.WRITE)
	if file:
		var payload: Dictionary = {
			"music" : music_on,
			"sound" : sfx_on,
		}
		var json_text = JSON.stringify(payload, "  ")
		file.store_pascal_string(json_text)
		file.close()

func load_option():
	if FileAccess.file_exists("user://option.json"):
		var file = FileAccess.open("user://option.json", FileAccess.READ)
		var text = file.get_pascal_string()
		var data = JSON.parse_string(text)         		
		file.close()
		music_on = data.get("music", true)
		sfx_on = data.get("sound", true)
		update_option()
				
func save_game():
	if get_tree().current_scene != null:
		current_level = get_tree().current_scene.scene_file_path
		
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file and player != null:
		var pos = player.global_position
		var payload: Dictionary = {
			"current_level" : current_level,
			"player" : [pos.x, pos.y],
			"score": score,
			"life" : life,
			"hp": hp,
			"character" : selected_character_path
		}
		var json_text = JSON.stringify(payload, "  ")
		file.store_pascal_string(json_text)
		file.close()

func has_gamesaved():
	return FileAccess.file_exists(save_path)

func load_game():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var text = file.get_pascal_string()
		var data = JSON.parse_string(text)         		
		file.close()
		
		# Load saved file attributes
		current_level = data.get("current_level", current_level)
		score = data.get("score", score)
		life = data.get("life", max_life)
		hp = data.get("hp", max_hp)
		selected_character_path = data.get("character", selected_character_path)
		
		var pos = data.get("player", [0, 0])
		save_player_position = Vector2(pos[0], pos[1])
		
		# Load into saved level scene
		get_tree().change_scene_to_file(current_level)
	else:
		restart()
