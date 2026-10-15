class_name FurnaceEntityBehv
extends ClickableEntityBehv

func _on_clicked():
	if Game.game_manager:
		Game.game_manager.game_ui.show_screen(GameUI.Screen.SMELTING)
