extends AbstractBattleState

class_name BattleLoopStates

func enter():
	
	# 根据速度生成行动顺序表
	var battle_action_list = Battle_Action_List.new()
	battle_action_list.action_list_by_speed()
	
	for character in Global_Model.BattleCharacters.CharacterArr:
		Global_Model.current_character = character
		
		var index = battle_scene.our_team_character.find_custom(func(c:Battle_Character): return c.data == Global_Model.current_character)
		
		var characterView:Battle_Character_View = battle_scene.our_team_character[index]
		characterView.forward()
