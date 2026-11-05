extends Control

@onready var hunger_val = $StatsContainer/HungerBox/ValueLabel
@onready var stamina_val = $StatsContainer/StaminaBox/ValueLabel
@onready var stress_val = $StatsContainer/StressBox/ValueLabel
@onready var fatigue_val = $StatsContainer/FatigueBox/ValueLabel

func _process(_delta):
	# 每一帧都去读取全局变量的值，并更新到UI上
	# 这样只要你在剧情里改了变量，侧边栏就会立刻跟着变
	hunger_val.text = str(PlayerStats.hunger)
	stamina_val.text = str(PlayerStats.stamina)
	stress_val.text = str(PlayerStats.stress)
	fatigue_val.text = str(PlayerStats.fatigue)
