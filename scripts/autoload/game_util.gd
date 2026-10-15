class_name GameUtility

static var RESOURCE_ICONS := {
	GameEnum.ResourceType.CURRENCY_MONEY: preload("uid://cngavd7y55hn0"),
	GameEnum.ResourceType.COAL_RAW: load("res://assets/textures/icon/ICON_COAL.png"),
	GameEnum.ResourceType.BRONZE_INGOT: load("res://assets/textures/icon/ICON_BRONZE.png"),
	GameEnum.ResourceType.BRONZE_ORE: load("res://assets/textures/icon/ICON_RAWORE_BRONZE.png"),
	GameEnum.ResourceType.IRON_INGOT: load("res://assets/textures/icon/ICON_INGOT_IRON.png"),
	GameEnum.ResourceType.IRON_ORE: load("res://assets/textures/icon/ICON_RAWORE_IRON.png"),
	GameEnum.ResourceType.GOLD_ORE: load("res://assets/textures/icon/ICON_RAWORE_GOLD.png"),
	GameEnum.ResourceType.GOLD_INGOT: load("res://assets/textures/icon/ICON_INGOT_GOLD.png"),
}

static var RESOURCE_DISPLAY_NAMES: Dictionary[GameEnum.ResourceType, String] = {
	GameEnum.ResourceType.CURRENCY_MONEY: "Money",
	GameEnum.ResourceType.COAL_RAW: "Coal",
	GameEnum.ResourceType.WOOD_LOG: "Wood",
	GameEnum.ResourceType.BRONZE_ORE: "Bronze Ore",
	GameEnum.ResourceType.BRONZE_INGOT: "Bronze",
	GameEnum.ResourceType.IRON_ORE: "Iron Ore",
	GameEnum.ResourceType.IRON_INGOT: "Iron Ingot",
	GameEnum.ResourceType.GOLD_ORE: "Gold Ore",
	GameEnum.ResourceType.GOLD_INGOT: "Gold Ingot",
}

static func get_resource_display_data(res: GameEnum.ResourceType) -> GameResourceDisplayInfo:
	return Database.get_res_d(res).display_info

static func get_resource_name(res: GameEnum.ResourceType) -> String:
	var data = get_resource_display_data(res)
	return data.display_name

static func get_resource_icon(res: GameEnum.ResourceType) -> CompressedTexture2D:
	var icon = get_resource_display_data(res).image
	if icon == null:
		return load("res://icon.svg")
	return icon

static func format_number(n: int = 0) -> String:
	var abs_n = abs(n)
	if abs_n >= 1_000_000_000:
		return "%.1fB" % (n / 1_000_000_000.0)
	elif abs_n >= 1_000_000:
		return "%.1fM" % (n / 1_000_000.0)
	elif abs_n >= 1_000:
		return "%.1fK" % (n / 1_000.0)
	else:
		return str(n)

static func readable_number(number: int = 0) -> String:
	var negative = number < 0
	var s = str(abs(number))
	var result = ""
	while s.length() > 3:
		result = "," + s.substr(s.length() - 3, 3) + result
		s = s.substr(0, s.length() - 3)
	result = s + result
	if negative:
		result = "-" + result
	return result

static func get_enum_name(enum_dict: Dictionary, value) -> String:
	var keys = enum_dict.keys()
	if keys and keys.get(value):
		return keys.get(value)
	return "Failed to get Enum name. Verify correct enum was used?"
