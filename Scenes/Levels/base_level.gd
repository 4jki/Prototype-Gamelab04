extends Node2D # Assuming your root node is a Node2D based on the context

# It is good practice to explicitly declare node references if they are not onready
# based on your scene, ensure these NodePaths are correct in the editor.
@onready var spawn_point = $SpawnPoint # Assuming a Node2D named SpawnPoint exists in your scene root
# @onready var music_player = $MusicPlayer # Optional: More stable than using $ syntax repeatedly

func _ready() -> void:
	# CRITICAL MISSING LOGIC: Call the spawn function when the level starts
	spawn_selected_character()
	
	# Start the music if it's not set to Autoplay in the editor
	if $MusicPlayer:
		$MusicPlayer.play()

# --- Player Spawner ---
func spawn_selected_character() -> void:
	# Basic check to ensure GameManager exists and a character is selected
	if GameManager and GameManager.selected_character_path != "":
		var char_resource = load(GameManager.selected_character_path)
		if char_resource:
			# 1. Instantiate the scene resource
			var player_instance = char_resource.instantiate()
			
			# 2. Assign reference to GameManager (so other scripts can find the player)
			GameManager.player = player_instance
			
			# 3. Set player position to the SpawnPoint marker
			if spawn_point:
				# FIX: Changed from global_p to global_position
				player_instance.global_position = spawn_point.global_position
			else:
				# Fallback safety if SpawnPoint is missing
				push_warning("base_level.gd: SpawnPoint not found. Spawning at origin.")
				player_instance.global_position = Vector2.ZERO
			
			# 4. CRITICAL MISSING LOGIC: Actually add the child to the scene tree
			add_child(player_instance)
			
			# Debug print to confirm success
			print("Player spawned at: ", player_instance.global_position)

# --- Event Handlers ---
# Assuming these are connected to the player's Area2D or Body signals in the editor
func _on_player_hit_enemy(_body) -> void:
	if GameManager.has_method("damage"):
		GameManager.damage(5)
	else:
		push_warning("GameManager does not have method 'damage'")

func _on_player_hit_trap(_body) -> void:
	if GameManager.has_method("death"):
		GameManager.death()
	else:
		push_warning("GameManager does not have method 'death'")

# --- Music Player Handling ---
func _on_music_player_finished() -> void:
	# The safest way to restart a track
	if $MusicPlayer:
		# FIX: Removed redundant '0' parameter, simplified to just play()
		$MusicPlayer.play()
