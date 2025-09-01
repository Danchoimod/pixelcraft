extends Control

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
var blocks = [
	"res://blockResource/tnt.tres",
	"res://blockResource/diamond_ore.tres",
	"res://blockResource/sand.tres"
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
	
func _can_drop_data(at_position, _data):
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

	# Nếu slot đích hoặc nguồn nằm trong KeyBar, đồng bộ Global và phát tín hiệu
	_sync_keybar_global()

func get_slot_node_at_position(at_pos):
	var allSlotNodes = (bagContainer.get_children() + keyBarContainer.get_children()
		+ equiment.get_children() + crafting.get_children())

	for node in allSlotNodes:
		var nodeRect = node.get_global_rect()
		if nodeRect.has_point(at_pos):
			return node
	
	return null

func _on_trash_can(at_pos):
	return trashCan.get_global_rect().has_point(at_pos)

func _refesh_ui():
	# Nạp và đặt sẵn một số item + block demo
	var to_place: Array = []
	for p in items:
		var it: Resource = load(p)
		if it:
			to_place.append(it)
	for p in blocks:
		var bl: Resource = load(p)
		if bl:
			to_place.append(bl)

	# Đặt vào BagSlots theo thứ tự trống
	for r in to_place:
		for slot in inventoryDict["BagSlots"].get_children():
			if slot.texture == null and slot.has_method("set_new_data"):
				slot.set_new_data(r)
				break

	# Sau khi làm mới UI, đồng bộ KeyBar vào Global (nếu đã có sẵn gì đó)
	_sync_keybar_global()

func _sync_keybar_global():
	# Đọc 9 ô keybar và ghi vào Global.keybar_items, sau đó phát tín hiệu
	if Global.keybar_items.size() < 9:
		Global.keybar_items.resize(9)
	var changed := false
	var i := 0
	for slot in keyBarContainer.get_children():
		var item = null
		# Nhận diện slot_node qua phương thức có sẵn
		if slot.has_method("get_slot_name"):
			item = slot.itemResource
		# Cập nhật
		if i < Global.keybar_items.size():
			if Global.keybar_items[i] != item:
				Global.keybar_items[i] = item
				changed = true
		i += 1
		if i >= 9:
			break
	if changed:
		if Global.has_signal("keybar_changed"):
			Global.emit_signal("keybar_changed")


func _on_texture_rect_mouse_entered() -> void:
	onInventory = true


func _on_texture_rect_mouse_exited() -> void:
	onInventory = false
