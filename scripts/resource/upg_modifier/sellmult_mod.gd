class_name UpgradeModSellMultiplier
extends GameUpgradeModiferBase

@export var add_power: float = 0.0

func redeem():
	Game.active_state.sell_multiplier += add_power
