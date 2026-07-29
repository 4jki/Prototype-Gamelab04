extends Node2D

@export var enemy_scenes: Array[PackedScene] = []
@export var speed_range: Array[int] = [50, 60, 70]
@export var respawn_time: Array[int] = [10, 5]
@export var respawn_onstart: bool = true
@export var max_instance: int = 2

var trespawn: int = 10
var tsec: int = 0
var instance_count: int = 0

func _ready() -> void:
	if has_node("icon"):
		$icon.queue_free()
	if respawn_onstart:
		trespawn = 0
	else:
		trespawn = respawn_time.pick_random()

func respawn() -> void:
	tsec = 0
	if enemy_scenes.size() > 0 and instance_count < max_instance:
		var enemyscene = enemy_scenes.pick_random()
		var obj: Enemy = enemyscene.instantiate() 
		instance_count += 1
		obj.position = Vector2.ZERO
		obj.speed = speed_range.pick_random()
		obj.direction = [-1, 1].pick_random()
		
		# FIXED: Prevents enemy from popping upward on spawn
		obj.velocity.y = 0 
		
		self.add_child(obj)
		trespawn = respawn_time.pick_random()

func _on_timer_timeout() -> void:
	tsec += 1
	if tsec > trespawn:
		respawn()

func _on_child_exiting_tree(node: Node) -> void:
	if node is Enemy:
		instance_count -= 1
