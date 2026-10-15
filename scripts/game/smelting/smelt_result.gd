class_name FurnaceSmeltingResult
extends Resource

@export var reward: GameEnum.ResourceType
@export var amount: int

static func create(into: GameEnum.ResourceType, amt: int) -> FurnaceSmeltingResult:
	var result = FurnaceSmeltingResult.new()
	result.amount = amt
	result.reward = into
	return result
