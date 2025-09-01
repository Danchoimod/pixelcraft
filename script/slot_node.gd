extends TextureRect

@export var itemResource: Resource  # Có thể là Item hoặc Block

func set_new_data(res: Resource):
	itemResource = res
	if itemResource != null:
		# Lấy icon chung cho cả Item và Block
		var icn: Texture2D = null
		if itemResource is Item:
			icn = itemResource.icon
			# Chỉ Item mới có metadata inventory
			itemResource.inventarSlot = get_parent().name
			itemResource.inventarPosition = int(name.split("Slot")[1])
		elif itemResource is Block:
			icn = itemResource.icon
		texture = icn
	else:
		texture = null
func get_slot_name():
	var parentName = get_parent().name
	var slotNumber = name.split("Slot")[1]
	
	return parentName + slotNumber
