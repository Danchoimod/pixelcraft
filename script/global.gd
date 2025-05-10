extends Node

var selected = 0
@export var all_blocks: Array[Block]
var block_id: int = 0
var atlas_coords: Vector2i = Vector2i(-1, -1)  # Giá trị mặc định
var selected_item: Item  # Lưu Item được chọn (nếu có)

func _ready():
	selected_item = null
