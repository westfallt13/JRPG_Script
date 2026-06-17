extends Node

var item_name
var inventory = {
	item_name: {
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
			"equipment": {
				"helmet" : {
					#armor_class : {}
				},#Helmet
				"chest" : {
					
				},#Chest
				"pants" : {
					
				},#Pants
				"boots" : {
					
				},#Boots
				"hands" : { 
					
				}, #Hands
				"accessories" : {
					"left_ring" : {
						
					}, #Left Ring
					"right_ring" : {
						
					}, #Right Ring
					"necklace" : {
						
					}, #Necklace
				},#Accessories
				"weapon":{
					"weapon_type" : {#Weapon Type (expand on these so that certain weapon types can only be equipped by certain characters)
						"greatsword" :{
						},
						"sword" :{
						},
						"dagger" :{
						},
						"knife" :{
						},
						"axe" :{
						},
						"bow" :{
						},
						"staff" :{
						}, #Weapon Type (expand on these so that certain weapon types can only be equipped by certain characters)
					"weapon_name" :{
						},#Weapon Name
					}, #Weapon

				},#Weapon

			}, #Equipment (potentially expand into heavy, medium, and light gear)
		}, #Item Type
	}, #Item Name

} #Inventory

func test_inventory_initialization():
	print("inventory")