extends TextureRect

@export var itemResource: Item

func set_new_data(Resource: Item):
	itemResource = Resource
	
	if itemResource != null:
		texture = itemResource.icon
		itemResource.inventarSlot = get_parent().name
		itemResource.inventarPosition = int(name.split("Slot")[1])
	else:
		texture = null
func get_slot_name():
	var parentName = get_parent().name
	var slotNumber = name.split("Slot")[1]
	
	return parentName + slotNumber
