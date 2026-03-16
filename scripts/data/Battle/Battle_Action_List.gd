
class_name Battle_Action_List


func action_list_by_speed():
	# 1. 按速度降序排序（速度高的在前）
	Global_Model.BattleCharacters.CharacterArr.sort_custom(func(a, b): return a.speed > b.speed)
	
	# 2. 遍历并打印排序后的结果
	for character in Global_Model.BattleCharacters.CharacterArr:
		print("%s: %d" % [character.display_name, character.speed])
