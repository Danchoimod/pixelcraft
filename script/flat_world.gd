extends Node2D

# Định nghĩa các loại block (chỉ giữ các block cần thiết cho logic cát rơi)
var sand = Vector2i(2, 1)  # Block cát
@onready var tile_map: TileMap = $TileMap
@onready var tile_map1: TileMap = $TileMap2
var current_tilemap: TileMap
@export var blocks: Array[Resource]
# Thời gian delay giữa mỗi lần cát rơi
var fall_speed = 0.2  # 0.2 giây rơi một lần
var fall_timer = 0.0  # Bộ đếm thời gian

func _ready():
	current_tilemap = tile_map  # Mặc định chọn TileMap đầu tiên

func _physics_process(delta):
	# Chuyển đổi giữa hai TileMap bằng phím "T"
	if Input.is_action_just_pressed("toggle_tilemap"):
		switch_tilemap()

	# Kiểm tra hành động chuột
	if Input.is_action_just_pressed("left_mouse") or Input.is_action_just_pressed("right_mouse"):
		place_or_break_tile()

	# Cập nhật rơi của cát
	fall_timer += delta
	if fall_timer >= fall_speed:
		fall_timer = 0  # Reset bộ đếm
		update_falling_sand()

func switch_tilemap():
	# Đổi TileMap hiện tại khi nhấn "T"
	current_tilemap = tile_map1 if current_tilemap == tile_map else tile_map
	print("Đã chuyển sang TileMap:", current_tilemap.name)

func place_or_break_tile():
	var tile = get_tile_under_mouse(current_tilemap)
	var tile_data = current_tilemap.get_cell_tile_data(0, tile)

	if Input.is_action_just_pressed("left_mouse"):
		# Phá block trên TileMap hiện tại
		current_tilemap.set_cell(0, tile, -1)
	elif Input.is_action_just_pressed("right_mouse"):
		# Nếu vị trí trống, đặt block mới
		if tile_data == null:
			if Global.atlas_coords != Vector2i(-1, -1):
				current_tilemap.set_cell(0, tile, 0, Global.atlas_coords)
			else:
				print("No valid block selected.")
		else:
			print("Không có tile tại vị trí này.")

func get_tile_under_mouse(map: TileMap) -> Vector2i:
	var mouse_position = get_global_mouse_position()
	var local_position = map.to_local(mouse_position)
	return map.local_to_map(local_position)

# ============================ #
#        CÁT RƠI XUỐNG         #
# ============================ #
func update_falling_sand():
	var falling_blocks = []
	
	# Duyệt qua tất cả các tile trong layer 0
	for tile in current_tilemap.get_used_cells(0):
		var below_tile = tile + Vector2i(0, 1)  # Ô bên dưới
		if is_sand(tile) and is_empty(below_tile):
			falling_blocks.append(tile)  # Nếu là sand và có thể rơi, thêm vào danh sách
	
	# Làm cát rơi từng bước
	for tile in falling_blocks:
		move_tile_down(tile)

func move_tile_down(tile_pos):
	var below_tile = tile_pos + Vector2i(0, 1)
	var tile_data = current_tilemap.get_cell_atlas_coords(0, tile_pos)  # Lấy dữ liệu tile
	current_tilemap.set_cell(0, tile_pos, -1)  # Xóa block cũ
	current_tilemap.set_cell(0, below_tile, 0, tile_data)  # Đặt block xuống ô dưới

func is_sand(tile_pos) -> bool:
	return current_tilemap.get_cell_atlas_coords(0, tile_pos) == sand  # Kiểm tra nếu là cát

func is_empty(tile_pos) -> bool:
	return current_tilemap.get_cell_source_id(0, tile_pos) == -1  # Kiểm tra nếu ô trống
