extends Node

func _ready():
	# Tải và instance TileMap từ scene `Background.tscn`
	var background_scene = preload("res://ui/background.tscn")
	var background_instance = background_scene.instantiate()
	
	# Thêm background vào scene hiện tại
	add_child(background_instance)
# Called every frame. 'delta' is the elapsed time since the previous frame.
