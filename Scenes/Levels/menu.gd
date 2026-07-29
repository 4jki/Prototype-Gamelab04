extends Node2D

# Main Menu Buttons
@onready var btn_start = $UI/btnStart
@onready var btn_continue = $UI/btnContinue
@onready var btn_option = $UI/btnOption
@onready var btn_credit = $UI/btnCredit

# Character Selection Container
@onready var character_selection = $UI/Character_Selection

# Character Scene Paths
const FIGHTER_PATH := "res://fighter.tscn"
const SAMURAI_PATH := "res://samurai.tscn"
const SHINOBI_PATH := "res://Shinobi.tscn"

# Music Stream Reference
var bgm_stream = preload("res://【殺戮の天使】 彼岸 BGM.mp3")
@onready var music_player: AudioStreamPlayer = $MusicPlayer if has_node("MusicPlayer") else null

func _ready() -> void:
	# Start with Main Menu visible, Character Select hidden
	_show_character_select(false)
	
	# Start Background Music
	_play_menu_music()

# --- MUSIC HELPER ---
func _play_menu_music() -> void:
	# Create MusicPlayer dynamically if it isn't in the scene tree
	if not music_player:
		music_player = AudioStreamPlayer.new()
		music_player.name = "MusicPlayer"
		add_child(music_player)
	
	# Configure player settings and bus
	if bgm_stream:
		music_player.stream = bgm_stream
		music_player.bus = "Master" # Controlled by volume slider
		
		# Ensure song loops when finished
		if not music_player.finished.is_connected(_on_music_finished):
			music_player.finished.connect(_on_music_finished)
			
		if not music_player.playing:
			music_player.play()

func _on_music_finished() -> void:
	if music_player:
		music_player.play(0)

# --- TOGGLE MENU VISIBILITY ---
func _show_character_select(show_select: bool) -> void:
	# Hide main menu buttons when character select is open
	btn_start.visible = !show_select
	btn_continue.visible = !show_select
	btn_option.visible = !show_select
	btn_credit.visible = !show_select
	
	# Show Character_Selection node only when start is clicked
	character_selection.visible = show_select

# --- MAIN MENU BUTTON ACTIONS ---
func _on_btn_start_pressed() -> void:
	# Hide main menu, show character buttons!
	_show_character_select(true)

func _on_btn_continue_pressed() -> void:
	# Check if a save file exists and load it
	if GameManager:
		if GameManager.has_gamesaved():
			GameManager.load_game()
		else:
			print("No save file found! Starting fresh game instead.")
			_show_character_select(true)

func _on_btn_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/credit.tscn")

func _on_btn_option_pressed() -> void:
	# Opens the options menu scene
	get_tree().change_scene_to_file("res://Scenes/Levels/options.tscn")

# --- CHARACTER SELECT BUTTON ACTIONS ---
func _on_fighter_pressed() -> void:
	_choose_character_and_start(FIGHTER_PATH)

func _on_samurai_pressed() -> void:
	_choose_character_and_start(SAMURAI_PATH)

func _on_shinobi_pressed() -> void:
	_choose_character_and_start(SHINOBI_PATH)

# --- HELPER FUNCTION ---
func _choose_character_and_start(character_path: String) -> void:
	if GameManager:
		# Resets hearts to 5, score to 0, and saves selected character
		GameManager.select_character(character_path)
		
	# Launch into Level 1 (matching your file system capitalization: Level_01.tscn)
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_01.tscn")
