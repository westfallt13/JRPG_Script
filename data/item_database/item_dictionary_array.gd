var items: Array = []

func add_item(p_item_name: String, p_item_data: Dictionary) -> void:
    p_item_data["item_name"] = p_item_name
    items.append(p_item_data)

func get_item(p_item_name: String) -> Dictionary:
    for item in items:
        if item["item_name"] == p_item_name:
            return item
    return {}