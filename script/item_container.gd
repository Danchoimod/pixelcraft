extends TextureRect

@export var block: Block  # Tham chiếu đến Block resource
@export var item: Item  # Tham chiếu đến Item resource
@export var block_id: int
@export var item_name: String
@export var icon: Texture2D

func _ready():
	texture = icon
	if icon == null:
		push_warning("Icon is not set for item_container with block_id: ", block_id, " or item_name: ", item_name)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if block:
			Global.block_id = block_id
			Global.atlas_coords = block.atlas_coords
			print("Selected Block:")
			print("  Block Name: ", block.block_name)
			print("  Atlas Coords: ", block.atlas_coords)
			print("  Block ID: ", block.block_id)
			print("  Break Time: ", block.break_time)
			print("  Icon: ", block.icon)
		elif item:
			# Có thể thêm biến global cho Item nếu cần
			print("Selected Item:")
			print("  Item Name: ", item.name)
			print("  Description: ", item.description)
			print("  Type: ", item.type)
			print("  Health: ", item.health)
			print("  Strength: ", item.strengtht)
			print("  Armor: ", item.armor)
			print("  Icon: ", item.icon)
		else:
			print("No Block or Item resource assigned to this item_container")
