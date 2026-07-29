extends Node2D

# Game Over Music Stream Reference (Updated to match your file path)
var bgm_stream = preload("res://Scenes/Levels/Sonic 1 Music_ Game Over.mp3")
@onready var music_player: AudioStreamPlayer = $MusicPlayer if has_node("MusicPlayer") else null

func _ready() -> void:
	# Start Game Over Music
	_play_game_over_music()

# --- MUSIC HELPER ---
func _play_game_over_music() -> void:
	# Create MusicPlayer dynamically if it isn't in the scene tree
	if not music_player:
		music_player = AudioStreamPlayer.new()
		music_player.name = "MusicPlayer"
		add_child(music_player)
	
	# Configure player settings and bus
	if bgm_stream:
		music_player.stream = bgm_stream
		music_player.bus = "Master" # Controlled by volume slider
			
		if not music_player.playing:
			music_player.play()

# --- STOP MUSIC HELPER ---
func _stop_game_over_music() -> void:
	if music_player and music_player.playing:
		music_player.stop()

# --- BUTTON ACTIONS ---
# Connected to your "Play Again" / Restart button
func _on_restart_button_pressed() -> void:
	_stop_game_over_music()
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_01.tscn")

# Connected to your "Main Menu" / Exit button
func _on_menu_button_pressed() -> void:
	_stop_game_over_music()
	get_tree().change_scene_to_file("res://Scenes/Levels/menu.tscn")
