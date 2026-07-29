extends Control

# Paths pointing to your character scenes
# Note: Using Godot's relative paths ("res://...") is much safer than absolute C:/ paths!
const FIGHTER_SCENE_PATH := "res://fighter.tscn"
const SAMURAI_SCENE_PATH := "res://samurai.tscn"
const SHINOBI_SCENE_PATH := "res://Shinobi.tscn"

# Connect this signal from your Fighter Button
func _on_fighter_button_pressed() -> void:
	if GameManager:
		# select_character sets the path AND resets life to 5 & score to 0!
		GameManager.select_character(FIGHTER_SCENE_PATH)
	start_game()

# Connect this signal from your Samurai Button
func _on_samurai_button_pressed() -> void:
	if GameManager:
		GameManager.select_character(SAMURAI_SCENE_PATH)
	start_game()

# Connect this signal from your Shinobi Button
func _on_shinobi_button_pressed() -> void:
	if GameManager:
		GameManager.select_character(SHINOBI_SCENE_PATH)
	start_game()

func start_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/base_level.tscn")
