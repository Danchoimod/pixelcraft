extends Node

@export_group("Basic Stats")
@export var level = 25
@export var basicHealth = 500
@export var basicStrengtht = 50
@export var basicArmor = 100

@export_group("Final Stats")
@export var health: int
@export var strengtht: int
@export var armor: int

func update_equipment_stats(equipStats):
	health = basicHealth + equipStats.health
	strengtht = basicStrengtht + equipStats.strengtht
	armor = basicArmor + equipStats.armor
