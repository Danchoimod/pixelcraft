extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bt_play_pressed() -> void:
	get_tree().change_scene_to_file("res://world/flat_world.tscn")
	pass # Replace with function body.


func _on_bt_option_pressed() -> void:
	pass # Replace with function body.


func _on_bt_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

 
func _on_bt_creator_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/creator_screen.tscn")
	pass # Replace with function body.
