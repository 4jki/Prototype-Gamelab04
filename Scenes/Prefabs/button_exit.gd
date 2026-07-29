extends Button

@export var exitToScene : PackedScene

func _on_pressed() -> void:
	if exitToScene != null:
		if SceneTransition:
			SceneTransition.load_scene(exitToScene)
	else:
		var tree = get_tree()
		if tree:
			tree.call_deferred("change_scene_to_file", "res://Scenes/Levels/menu.tscn")
