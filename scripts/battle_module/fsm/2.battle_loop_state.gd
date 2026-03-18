extends AbstractBattleState

class_name BattleLoopStates

func enter():
	
	# 根据速度生成行动顺序表
	var battle_action_list = Battle_Action_List.new()
	battle_action_list.action_list_by_speed()
	
	for character in Global_Model.BattleCharacters.CharacterArr:
		Global_Model.current_character = character
		on_turn_start(character)
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

# 单位行动开始时移除到期关键词/联动状态
func on_turn_start(character:Battle_Character):
	for keyword in character.states.duplicate():
		if States.expire_on_turn_start(keyword):
			character.states.erase(keyword)


func enemy_start_attack(character:Battle_Character):
	
	var ablitiy:ablities_data
	var target:Battle_Character
	
	while ablitiy == null:
		var key = character.ablities.keys().pick_random()
		var random_value = character.ablities[key]
		if random_value.countDown != 0:
			continue
		else:
			ablitiy = random_value
	
	while(1):
		target = Global_Model.BattleCharacters.CharacterArr.pick_random()
		if target.control:
			break
	
			
	if ablitiy != null:
		calc_turn_dmg(ablitiy, target, Global_Model.current_character)

func calc_turn_dmg(ablitiy:ablities_data, target:Battle_Character, current:Battle_Character):
	# 计算技能最终造成的伤害，并四舍五入
	var damage_rate = States.get_damage_rate(target.states, current.states)
	var final_damage = ablitiy.dmg * damage_rate
	var damage_value = roundi(final_damage)
	
	# 目标hp减少
	target.hp -= damage_value
	
	# 判断目标是否死亡
	if target.hp <= 0:
		target.died = true
		
	# 
	var synergy_key = States.apply_ability_keyword(target, ablitiy.states)
	if synergy_key != "":
		print("触发联动: ", synergy_key)
		var synergy_info = States.keywords_synergy_info[synergy_key]
		var remove_old = synergy_info["remove_old"]
		var synergy_effect = synergy_info["effect"]
		var delay_current_turn_once = synergy_info["delay_current_turn_once"]
	
	# 让技能进入冷却
	if ablitiy.abCooldown != 0:
		ablitiy.countDown = ablitiy.abCooldown
	
	# 关键词联动结算
	var synergy_info = States.get_synergy_info(States.keywords.PIERCE, States.keywords.STAGGER)
	
	#if synergy_info.is_empty():
	
	
	
	# 如果所有 可控 || 不可控 目标均以死亡，战斗结束（胜利/失败）
	

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
	
		
		
	
			
		
