class_name Item
extends Resource

@export_group("Settings")
@export var name: String
@export_multiline var description: String
@export var icon: CompressedTexture2D
@export_enum("Weapon","Armor","Useable") var type: String
@export var is_original: bool = true  # New property to track if item is original

@export_group("stats")
@export var health: int
@export var strengtht: int
@export var armor: int

@export_group("inventory data")
@export var inventarSlot: String
@export var inventarPosition: int
