extends Control

@export var items: Array[Resource]  # Dữ liệu mặc định (fallback) nếu chưa có keybar từ Inventory

@onready var hotbar_item_container: HBoxContainer = $MarginContainer/TextureRect/MarginContainer/HBoxContainer

const HOTBAR_ITEM = preload("res://item_container.tscn")

func _ready() -> void:
	# Ưu tiên đồng bộ theo Global.keybar_items nếu có, nếu không dùng items export
	if Global.keybar_items.size() == 9 and Global.keybar_items.any(func(x): return x != null):
		_refresh_from_global()
	else:
		_fill_from_export()
	# Lắng nghe thay đổi từ Inventory
	if Global.has_signal("keybar_changed"):
		Global.keybar_changed.connect(_refresh_from_global)

func _clear_hotbar_nodes():
	for c in hotbar_item_container.get_children():
		c.queue_free()

func _spawn_item_node(item: Resource) -> void:
	if item == null:
		return
	var node = HOTBAR_ITEM.instantiate()
	if item is Block:
		node.block = item
		node.icon = item.icon
		node.block_id = item.block_id
	elif item is Item:
		node.item = item
		node.icon = item.icon
		node.item_name = item.name
	else:
		push_warning("Item is not a valid Block or Item resource: ", item)
		return
	hotbar_item_container.add_child(node)

func _fill_from_export():
	_clear_hotbar_nodes()
	for item in items:
		_spawn_item_node(item)
	_debug_print(items)

func _refresh_from_global():
	_clear_hotbar_nodes()
	# Đảm bảo đủ 9 ô, chỉ thêm node cho ô có item
	for i in range(9):
		var it = null
		if i < Global.keybar_items.size():
			it = Global.keybar_items[i]
		_spawn_item_node(it)
	_debug_print(Global.keybar_items)

func _debug_print(arr: Array):
	# Debug print for both Block and Item resources
	var dbg := arr.map(func(i): 
		if i is Block:
			return [i.block_id, i.block_name, i.atlas_coords]
		elif i is Item:
			return [i.name, i.type, i.icon]
		else:
			return null)
	print("Hotbar items:", dbg)
