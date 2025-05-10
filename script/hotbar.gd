extends Control

@export var items: Array[Resource]  # Mảng các Block hoặc Item resource

@onready var hotbar_item_container: HBoxContainer = $MarginContainer/TextureRect/MarginContainer/HBoxContainer

const HOTBAR_ITEM = preload("res://item_container.tscn")

func _ready() -> void:
	_fill_hotbar()
	# Debug print for both Block and Item resources
	print("Hotbar items: ", items.map(func(i): 
		if i is Block:
			return [i.block_id, i.block_name, i.atlas_coords]
		elif i is Item:
			return [i.name, i.type, i.icon]
		else:
			return null))

func _fill_hotbar():
	for item in items:
		var newHotbarIconNode = HOTBAR_ITEM.instantiate()
		if item is Block:
			newHotbarIconNode.block = item  # Gán Block resource
			newHotbarIconNode.icon = item.icon
			newHotbarIconNode.block_id = item.block_id
			hotbar_item_container.add_child(newHotbarIconNode)
		elif item is Item:
			newHotbarIconNode.item = item  # Gán Item resource
			newHotbarIconNode.icon = item.icon
			newHotbarIconNode.item_name = item.name  # Lưu tên item
			hotbar_item_container.add_child(newHotbarIconNode)
		else:
			push_warning("Item is not a valid Block or Item resource: ", item)
