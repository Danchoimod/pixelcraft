extends Control

signal dropOut

@onready var bagContainer = $TextureRect/bagslot
@onready var keyBarContainer = $TextureRect/keybar
@onready var equiment = $TextureRect/equipment
@onready var crafting = $TextureRect/crafting
@onready var trashCan: TextureRect = $MarginContainer/TextureRect
var inventoryDict = {}
var onInventory = false
var items = [
	"res://itemResource/carrot.tres",
	"res://itemResource/diamond_helmet.tres",
	"res://itemResource/diamond_sword.tres"
]

func _ready():
	inventoryDict = {
		"BagSlots":bagContainer,
		"KeyBar": keyBarContainer,
		"Equipment": equiment,
		"Creafting":crafting
	}
	
	_refesh_ui()
func add_item(item:Item):
	item.inventarSlot = "BagSlots"
	item.inventarPosition = _get_next_empty_bag_slot()
	
	item.add(item.resource_path)
	
func _get_next_empty_bag_slot():
	for slot in inventoryDict["BagSlots"].get_children():
		if slot.texture == null:
			var slotNumber = int(slot.name.split("Slot")[1])
			return slotNumber
func _get_drag_data(at_position):
	var dragSlotNode = get_slot_node_at_position(at_position)
	
	if dragSlotNode == null:
		print("DEBUG: Không tìm thấy slot tại vị trí: ", at_position)
		return
	
	if dragSlotNode.texture == null:
		print("DEBUG: Slot không có texture, không thể kéo!")
		return
	
	print("DEBUG: Bắt đầu kéo item có texture: ", dragSlotNode.texture)
	
	var dragPreviewNode = dragSlotNode.duplicate()
	dragPreviewNode.custom_minimum_size = Vector2(55, 55)
	set_drag_preview(dragPreviewNode)

	return {"slot": dragSlotNode, "texture": dragSlotNode.texture}
	
func _can_drop_data(at_position, data):
	var targetSlotNode = get_slot_node_at_position(at_position)
	var onTrashCan = _on_trash_can(at_position)
	return targetSlotNode != null || onTrashCan

func _drop_data(at_position, data):
	var targetSlotNode = get_slot_node_at_position(at_position)
	var onTrashCan = _on_trash_can(at_position)

	var dragSlotNode = data["slot"]
	var dragTexture = data["texture"]

	# Nếu item được thả vào thùng rác, xóa nó
	if onTrashCan:
		dragSlotNode.texture = null
		if dragSlotNode.has_method("set_new_data"):
			dragSlotNode.set_new_data(null)
		return

	# Nếu không có slot hợp lệ để thả, thoát
	if targetSlotNode == null:
		return

	# Kiểm tra xem các slot có phương thức set_new_data không
	if not dragSlotNode.has_method("set_new_data") or not targetSlotNode.has_method("set_new_data"):
		print("Lỗi: Một trong hai slot không có phương thức set_new_data")
		return

	# Lấy dữ liệu của item trong hai slot
	var targetResource = targetSlotNode.itemResource
	var dragResource = dragSlotNode.itemResource

	# Hoán đổi dữ liệu giữa hai slot
	targetSlotNode.set_new_data(dragResource)
	dragSlotNode.set_new_data(targetResource)

	# Cập nhật hình ảnh của slot
	targetSlotNode.texture = dragTexture
	dragSlotNode.texture = targetResource.icon if targetResource else null

func get_slot_node_at_position(position):
	var allSlotNodes = (bagContainer.get_children() + keyBarContainer.get_children()
		+ equiment.get_children() + crafting.get_children())

	for node in allSlotNodes:
		var nodeRect = node.get_global_rect()
		
		if nodeRect.has_point(position):
			return node
	
	return null

func _on_trash_can(position):
	return trashCan.get_global_rect().has_point(position)

func _refesh_ui():
	for item in items:
		item = load(item)
	
		var inventarSlot = item["inventarSlot"]
		var inventarPosition = item["inventarPosition"]
		var icon = item["icon"]
		
		for slot in inventoryDict[inventarSlot].get_children():
			var slotNumber = int(slot.name.split("Slot")[1])
			
			if slotNumber == inventarPosition:
				slot.set_new_data(item)


func _on_texture_rect_mouse_entered() -> void:
	onInventory = true


func _on_texture_rect_mouse_exited() -> void:
	onInventory = false
