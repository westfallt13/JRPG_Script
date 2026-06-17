extends Node

var armor_class

var item_name
var item_database = {
		"item_name" : "String",
		"description": "String Value", #String value, clearly
		"quantity": 0, #Integer Value
		"can_be_equipped": false, #Boolean Value, used to determine if the item can be equipped or is a consumable/quest item (have changed in the future)
		"weight": 0.0, #Float Value, potentially used for inventory weight limits and encumbrance mechanics
		"total_weight": 0.0, #Float Value, calculated as weight multiplied by quantity, used for inventory weight limits and encumbrance mechanics
		"item_type": {
			"consumables": {
				#can_be_consumed: false, #Boolean Value, used to determine if the item can be consumed or is a quest item/equipment (have changed in the future, if health > 0 cannot be consumed)
			},
			"quest_items": {
				#can_be_quest_item: false, #Boolean Value, used to determine if the item is a quest item or is consumable/equipment (have changed in the future)
			},
			 #Equipment (potentially expand into heavy, medium, and light gear)
		}, #Item Type
} #Item_database