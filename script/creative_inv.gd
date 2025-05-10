extends Control

signal dropOut

@onready var bagContainer = $TextureRect/bagslot
@onready var keyBarContainer = $TextureRect/keybar
@onready var trashCan: TextureRect = $MarginContainer/TextureRect
var inventoryDict = {}
var onInventory = false
var items = [
	"res://itemResource/carrot.tres",
	"res://itemResource/diamond_helmet.tres",
	"res://itemResource/diamond_sword.tres"
]
var blocks = []  # Danh sách để lưu trữ đường dẫn resource của Block

func _ready():
	inventoryDict = {
		"BagSlots": bagContainer,
		"KeyBar": keyBarContainer
	}
	
	_refresh_ui()

func add_item(resource: Resource):
	if resource is Item:
		resource.inventarSlot = "BagSlots"
		resource.inventarPosition = _get_next_empty_bag_slot()
		resource.is_original = true
		items.append(resource.resource_path)
	elif resource is Block:
		# Block không cần is_original vì không clone
		resource.inventarSlot = "BagSlots"
		resource.inventarPosition = _get_next_empty_bag_slot()
		blocks.append(resource.resource_path)
	_refresh_ui()

func _get_next_empty_bag_slot():
	for slot in inventoryDict["BagSlots"].get_children():
		if slot.texture == null:
			var slotNumber = int(slot.name.split("Slot")[1])
			return slotNumber
	return -1

func _get_drag_data(at_position):
	var dragSlotNode = get_slot_node_at_position(at_position)
	
	if dragSlotNode == null:
		print("DEBUG: Không tìm thấy slot tại vị trí: ", at_position)
		return
	
	if dragSlotNode.texture == null:
		print("DEBUG: Slot không có texture, không thể kéo!")
		return
	
	var dragResource = dragSlotNode.itemResource
	if not (dragResource is Item or dragResource is Block):
		print("DEBUG: Slot không chứa Item hoặc Block hợp lệ")
		return
	
	# Chỉ cho phép clone Item gốc từ bagContainer
	if dragResource is Item and dragResource.is_original and dragSlotNode.get_parent() != bagContainer:
		print("DEBUG: Chỉ có thể clone Item gốc từ BagSlots")
		return
	
	print("DEBUG: Bắt đầu kéo ", "Item" if dragResource is Item else "Block", " có texture: ", dragSlotNode.texture)
	
	var dragPreviewNode = dragSlotNode.duplicate()
	dragPreviewNode.custom_minimum_size = Vector2(55, 55)
	set_drag_preview(dragPreviewNode)

	return {"slot": dragSlotNode, "texture": dragSlotNode.texture, "resource": dragResource}

func _can_drop_data(at_position, data):
	var targetSlotNode = get_slot_node_at_position(at_position)
	var onTrashCan = _on_trash_can(at_position)
	
	if targetSlotNode or onTrashCan:
		return true
	return false

func _drop_data(at_position, data):
	var targetSlotNode = get_slot_node_at_position(at_position)
	var onTrashCan = _on_trash_can(at_position)

	var dragSlotNode = data["slot"]
	var dragTexture = data["texture"]
	var dragResource = data["resource"]

	if not (dragResource is Item or dragResource is Block):
		print("Lỗi: Source slot không có Item hoặc Block hợp lệ")
		return

	# Xóa item/block khi thả vào thùng rác
	if onTrashCan:
		dragSlotNode.set_new_data(null)
		dragSlotNode.texture = null
		print("DEBUG: ", "Item" if dragResource is Item else "Block", " deleted via trash can")
		return

	if targetSlotNode == null:
		print("DEBUG: Không tìm thấy slot đích hợp lệ")
		return

	if not targetSlotNode.has_method("set_new_data"):
		print("Lỗi: Target slot không có phương thức set_new_data")
		return

	var sourceIsBag = dragSlotNode.get_parent() == bagContainer
	var targetIsKeyBar = targetSlotNode.get_parent() == keyBarContainer
	var targetIsBag = targetSlotNode.get_parent() == bagContainer

	if dragResource is Item and sourceIsBag and targetIsKeyBar and dragResource.is_original:
		# Clone Item từ BagSlots sang KeyBar
		var clonedResource = dragResource.duplicate()
		clonedResource.is_original = false
		clonedResource.inventarSlot = "KeyBar"
		clonedResource.inventarPosition = _get_slot_number(targetSlotNode)
		targetSlotNode.set_new_data(clonedResource)
		targetSlotNode.texture = dragTexture
		print("DEBUG: Cloned Item from BagSlots to KeyBar")
	elif dragResource is Block and sourceIsBag and targetIsKeyBar:
		# Clone Block từ BagSlots sang KeyBar
		var clonedResource = dragResource.duplicate()
		clonedResource.inventarSlot = "KeyBar"
		clonedResource.inventarPosition = _get_slot_number(targetSlotNode)
		targetSlotNode.set_new_data(clonedResource)
		targetSlotNode.texture = dragTexture
		print("DEBUG: Cloned Block from BagSlots to KeyBar")
	elif targetIsBag and not sourceIsBag:
		# Xóa Item/Block từ KeyBar khi thả lên BagSlots
		dragSlotNode.set_new_data(null)
		dragSlotNode.texture = null
		print("DEBUG: ", "Item" if dragResource is Item else "Block", " from KeyBar deleted when dropped on BagSlots")
	else:
		print("DEBUG: Hành động kéo thả không được phép")
		return

func _get_slot_type(slot_node: Node) -> String:
	for slot_type in inventoryDict.keys():
		if slot_node.get_parent() == inventoryDict[slot_type]:
			return slot_type
	return ""

func _get_slot_number(slot_node: Node) -> int:
	var slot_name = slot_node.name
	if "Slot" in slot_name:
		return int(slot_name.split("Slot")[1])
	return -1

func get_slot_node_at_position(position):
	var allSlotNodes = (bagContainer.get_children() + keyBarContainer.get_children())

	for node in allSlotNodes:
		var nodeRect = node.get_global_rect()
		
		if nodeRect.has_point(position):
			return node
	
	return null

func _on_trash_can(position):
	return trashCan.get_global_rect().has_point(position)

func _refresh_ui():
	# Xóa tất cả texture hiện tại
	for slot_type in inventoryDict:
		for slot in inventoryDict[slot_type].get_children():
			slot.set_new_data(null)
			slot.texture = null
	
	# Load Item
	for item_path in items:
		var item_resource = load(item_path) as Item
		if not item_resource:
			print("Lỗi: Không thể tải Item resource: ", item_path)
			continue
	
		item_resource.is_original = true
		var inventarSlot = item_resource.inventarSlot
		var inventarPosition = item_resource.inventarPosition
		var icon = item_resource.icon
		
		if inventarSlot not in inventoryDict:
			print("Lỗi: inventarSlot không hợp lệ cho Item: ", inventarSlot)
			continue
			
		for slot in inventoryDict[inventarSlot].get_children():
			var slotNumber = int(slot.name.split("Slot")[1])
			
			if slotNumber == inventarPosition:
				slot.set_new_data(item_resource)
				slot.texture = icon
	
	# Load Block
	for block_path in blocks:
		var block_resource = load(block_path) as Block
		if not block_resource:
			print("Lỗi: Không thể tải Block resource: ", block_path)
			continue
	
		var inventarSlot = block_resource.inventarSlot
		var inventarPosition = block_resource.inventarPosition
		var icon = block_resource.icon
		
		if inventarSlot not in inventoryDict:
			print("Lỗi: inventarSlot không hợp lệ cho Block: ", inventarSlot)
			continue
			
		for slot in inventoryDict[inventarSlot].get_children():
			var slotNumber = int(slot.name.split("Slot")[1])
			
			if slotNumber == inventarPosition:
				slot.set_new_data(block_resource)
				slot.texture = icon

func _on_texture_rect_mouse_entered() -> void:
	onInventory = true

func _on_texture_rect_mouse_exited() -> void:
	onInventory = false
