extends Node

var selected = 0
@export var all_blocks: Array[Block]
var block_id: int = 0
var atlas_coords: Vector2i = Vector2i(-1, -1)  # Giá trị mặc định
var selected_item: Item  # Lưu Item được chọn (nếu có)
var selected_block: Block  # Lưu Block được chọn (nếu có)
@warning_ignore("UNUSED_SIGNAL")
signal keybar_changed  # Phát tín hiệu khi hotbar (keybar) thay đổi
var keybar_items: Array = []  # Mảng 9 ô, mỗi ô là Item hoặc null

func _ready():
	selected_item = null
	selected_block = null
	# Khởi tạo 9 ô trống cho hotbar
	keybar_items.resize(9)
	for i in range(9):
		keybar_items[i] = null
