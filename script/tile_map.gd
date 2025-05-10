extends TileMap
# Called every frame in physics processing
@onready var text_edit: TextEdit = $"../Player/TextEdit"
func _physics_process(delta):
	# Kiểm tra nhấn chuột trái
	if Input.is_action_just_pressed("left_mouse"):
		var mouse_position = get_global_mouse_position()
		var local_position = to_local(mouse_position)
		var tile = local_to_map(local_position)
		
		# Đặt tile tại vị trí này với ID 0 (tạo tile với ID 0 trong TileMap)
		set_cell(0, tile, 0)  # Tile với ID 0 ở vị trí của chuột
	var dirt = Vector2i(2,0)
	var grass = Vector2i(3,0)
	var tnt = Vector2i(8,0)
	# Kiểm tra nhấn chuột phải để đặt tile tại (1, 0) trong AtlasTexture (tức là Tile với ID 0)
	if Input.is_action_just_pressed("right_mouse"):
		var mouse_position: Vector2i = get_global_mouse_position()
		var local_position: Vector2i = to_local(mouse_position)
		var tile = local_to_map(local_position)
		var tile_data = get_cell_tile_data(0,tile)
		if text_edit.get_selected_text() == "tnt":
			print("hello")
		
