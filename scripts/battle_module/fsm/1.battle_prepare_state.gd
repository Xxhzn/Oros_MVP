extends AbstractBattleState

class_name BattlePrepareStates

func enter():
	
	#Global_Model.BattleCharacters.InitCharacter()
	#for i in Global_Model.BattleCharacters.CharacterArr.size():
		#var _Character = Global_Model.BattleCharacters.CharacterArr[i]
		#var character = battle_scene.Player_Template.new()
		#battle_scene.add_child(character)
		#character.setup_data(_Character)
		#character.show()
		#character.update_view()
		#if !_Character.control:
			#battle_scene.enemy_team_character.set(_Character.index, character)
			#character.texture = load(_Character.texture_path)
			#character.position = battle_scene.enemy_positions[i].position
			#character.turn_left()
		#else:
			#battle_scene.our_team_character.set(_Character.index, character)
			#character.position = battle_scene.player_positions[i].position
	#
	fsm.change_state(Battle_Scene.States.Loop)
	
