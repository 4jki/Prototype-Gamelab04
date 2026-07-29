extends CanvasLayer

@onready var score_label = %ScoreLabel
@onready var hp_bar = %ProgressBar
@onready var alert_label: Label = $GameUI/BottomBar/AlertLabel
@onready var life_rect = $GameUI/TopBar/LifeRect

func _ready() -> void:
	# Force immediate refresh on scene start
	update_ui_display()

func _process(_delta):
	update_ui_display()

func update_ui_display() -> void:
	if not GameManager:
		return

	# Set the score label text to the score variable in game manager script
	score_label.text = "Score: %d" % GameManager.score
	hp_bar.value = GameManager.hp
	
	# Update Sound/Music UI buttons
	$GameUI/TopBar/btnSound/on.visible   = GameManager.sfx_on
	$GameUI/TopBar/btnSound/mute.visible = !GameManager.sfx_on
	$GameUI/TopBar/btnMusic/mute.visible = !GameManager.music_on
	
	# --- FIX FOR HEART BAR DISPLAY ---
	# 48 is the pixel width per heart. Multiplying by GameManager.life resizes the display.
	life_rect.custom_minimum_size.x = 48 * GameManager.life
	life_rect.size.x = 48 * GameManager.life

func alert(text):
	alert_label.text = text
	alert_label.visible = true
	alert_label.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(alert_label, "scale", Vector2(1,1), 0.3)
	await get_tree().create_timer(2).timeout
	alert_label.visible = false 
	
func _on_btn_sound_pressed() -> void:
	GameManager.sfx_on = !GameManager.sfx_on
	GameManager.update_option()
	GameManager.save_option()
	
func _on_btn_music_pressed() -> void:
	GameManager.music_on = !GameManager.music_on
	GameManager.update_option()
	GameManager.save_option()
	
func _on_btn_left_pressed() -> void:
	Input.action_press("Left")

func _on_btn_left_released() -> void:
	Input.action_release("Left")

func _on_btn_up_pressed() -> void:
	Input.action_press("Jump")

func _on_btn_up_released() -> void:
	Input.action_release("Jump")

func _on_btn_right_pressed() -> void:
	Input.action_press("Right")

func _on_btn_right_released() -> void:
	Input.action_release("Right")

func _on_btn_shoot_button_down() -> void:
	Input.action_press("Shoot")
	
func _on_btn_shoot_button_up() -> void:
	Input.action_release("Shoot")

func _on_btn_save_pressed() -> void:
	GameManager.save_game()
	alert("Game is saved.")
