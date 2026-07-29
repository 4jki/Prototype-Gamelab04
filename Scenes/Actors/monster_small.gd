extends Enemy

func _ready() -> void:
	super._ready()
	if has_node("Sprite/AnimateSprite"):
		var anim = $Sprite/AnimateSprite
		var types = Array(anim.sprite_frames.get_animation_names())
		if types.size() > 0:
			anim.animation = types.pick_random()
			anim.play()
