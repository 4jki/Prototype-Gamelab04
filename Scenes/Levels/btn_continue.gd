extends Button

func _on_btn_continue_pressed() -> void:
	if GameManager:
		if GameManager.has_gamesaved():
			# Loads saved character, level, score, and position directly!
			GameManager.load_game()
		else:
			print("No save file found!")
