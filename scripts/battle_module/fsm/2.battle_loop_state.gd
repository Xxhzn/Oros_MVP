extends AbstractBattleState

class_name BattleLoopStates

func enter():
	
	# 根据速度生成行动顺序表
	var battle_action_list = Battle_Action_List.new()
	battle_action_list.action_list_by_speed()
	
	for character in Global_Model.BattleCharacters.CharacterArr:
		Global_Model.current_character = character
		print(character.display_name)
		# 先找到行动的角色的view，然后调用这个view里面的向前走一步方法
		var index = battle_scene.our_team_character.find_custom(func(c:Battle_Character): return c.data == Global_Model.current_character)
		var characterView:Battle_Character_View = battle_scene.our_team_character[index]
		characterView.forward()
		
		# 弹出菜单让玩家选择
		if character.control == true and character.display_name == "艾登" and character.died == false:
			await aiden_start_select_weapon()
			await aiden_start_select_action()
			await aiden_start_select_target()
		elif character.control == false and character.died == false:
			await enemy_start_attack(character)

func enemy_start_attack(character:Battle_Character):
	
	var ablitiy:ablities_data
	var target:Battle_Character
	
	while ablities_data == null:
		var key = character.ablities.keys().pick_random()
		var random_value = character.ablities[key]
		if random_value.abCooldown != 0:
			continue
		else:
			ablitiy = random_value
	
	while(1):
		target = Global_Model.BattleCharacters.CharacterArr.pick_random()
		if target.control:
			break
	
			
	if ablities_data != null:
		calcDmg(ablitiy, target)

func calcDmg(ablitiy:ablities_data, target:Battle_Character):
	pass

func aiden_start_select_weapon():
	battle_scene.battle_menu.open()
	battle_scene.battle_menu.title.text = "请选择要使用的器灵"
	for weap in Global_Model.BattleCharacters.WeaponArr:
		battle_scene.battle_menu.item(Global_Model.BattleCharacters.WeaponArr[weap].displayName,func():
			print(Global_Model.BattleCharacters.WeaponArr[weap].displayName)
			battle_scene.select_character_weapon(weap)
		)
		
	await battle_scene.battle_menu.finished
	
	
func aiden_start_select_action():
	battle_scene.battle_menu.open()
	battle_scene.battle_menu.title.text = "请选择动作"
	for i in Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities:
		battle_scene.battle_menu.item(Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].displayname,
		func():
			print(Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].displayname)
			)
		
	await battle_scene.battle_menu.finished
	
func aiden_start_select_target():
	battle_scene.battle_menu.open()
	battle_scene.battle_menu.title.text = "请选择目标"
	for character in Global_Model.BattleCharacters.CharacterArr:
		if character.control == false and character.died == false:
			battle_scene.battle_menu.item(character.display_name,
			func():
				print(character.display_name)
				)
	await battle_scene.battle_menu.finished
	battle_scene.battle_menu.hide()
	
		
		
	
			
		
