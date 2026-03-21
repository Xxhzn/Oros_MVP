extends AbstractBattleState

class_name BattleLoopStates

var ablities:ablities_data
var attacktarget:Battle_Character
var targetView:Battle_Character_View
var conutNum:int = 0
# 当前回合的临时行动队列
var current_round_action_order: Array = []
# 当前正在处理到行动队列中的哪个index
var current_turn_index: int = -1

# 把关键词编号数组格式化成可读字符串
func format_keyword_list(keyword_list: Array) -> String:
	var parts: Array[String] = []
	for keyword in keyword_list:
		parts.append(Keywords.get_keyword_name(keyword))
	return "[" + ", ".join(PackedStringArray(parts)) + "]"

# 把 keyword_runtimes 格式化成可读字符串
func format_runtime_list(keyword_runtimes: Array[KeywordRuntime]) -> String:
	var parts: Array[String] = []
	for runtime in keyword_runtimes:
		parts.append("%s 施放者=%d 剩余=%d" % [
			Keywords.get_keyword_name(runtime.keyword),
			runtime.caster_index,
			runtime.remaining_owner_turn_ends
		])
	return "[" + ", ".join(PackedStringArray(parts)) + "]"

func enter():
	
	# 根据速度生成行动顺序表
	var battle_action_list = Battle_Action_List.new()
	battle_action_list.action_list_by_speed()
	
	while 1:
		var round_action_order = Global_Model.BattleCharacters.CharacterArr.duplicate()
		current_round_action_order = round_action_order
		
		var turn_index = 0
		while turn_index < round_action_order.size():
			var character = round_action_order[turn_index]
			current_turn_index = turn_index
			Global_Model.current_character = character
			print("\n[行动角色] %s" % character.display_name)
			
			on_character_turn_start(character)
			
			# 先找到行动的角色的view，然后调用这个view里面的向前走一步方法
			if character.control == true and character.display_name == "艾登" and character.died == false:
				var characterView:Battle_Character_View = battle_scene.our_team_character[character.index]
				characterView.forward()
				if conutNum != 0:
					await change_abilities_countdown()
				# 弹出菜单让玩家选择
				await aiden_start_select_weapon()
				await aiden_start_select_action()
				on_character_turn_end(character)
				characterView.backward()
				
			elif character.control == false and character.died == false:
				var characterView:Battle_Character_View = battle_scene.enemy_team_character[character.index]
				characterView.forward()
				if conutNum != 0:
					await change_abilities_countdown()
				# 敌人则自动行动
				await enemy_start_attack(character)
				on_character_turn_end(character)
				characterView.backward()
				
			turn_index += 1
			
		if is_group_died_all(battle_scene.enemy_team_character):
			fsm.change_state(Main.States.Win)
			break
		elif is_group_died_all(battle_scene.our_team_character):
			fsm.change_state(Main.States.Lose)
			break
			
		conutNum += 1
			
# 当前单位行动开始时的调试入口
func on_character_turn_start(character: Battle_Character):
	print("[行动开始] %s 状态=%s runtimes=%s" % [
	character.display_name,
	format_keyword_list(character.states),
	format_runtime_list(character.keyword_runtimes)
])

# 当前单位行动结束时的状态结算
func on_character_turn_end(character: Battle_Character):
	print("[行动结束] %s 状态=%s runtimes=%s" % [
		character.display_name,
		format_keyword_list(character.states),
		format_runtime_list(character.keyword_runtimes)
	])
	
	if Keywords.has_keyword_runtime(character, Keywords.keywords.STABLE):
		var heal_value = roundi(character.max_hp * 0.1)
		character.hp = min(character.max_hp, character.hp + heal_value)
		print("[稳固触发] %s 治疗=%d hp=%d/%d" % [
			character.display_name,
			heal_value,
			character.hp,
			character.max_hp
		])

	for tarGet in Global_Model.BattleCharacters.CharacterArr:
		for runtime in tarGet.keyword_runtimes.duplicate():
			if runtime.caster_index == character.index:
				runtime.remaining_owner_turn_ends -= 1
				print("[runtime结算] 施放者=%s 目标=%s 关键词=%s 剩余=%d" % [
					character.display_name,
					tarGet.display_name,
					Keywords.get_keyword_name(runtime.keyword),
					runtime.remaining_owner_turn_ends
				])

				if runtime.remaining_owner_turn_ends <= 0:
					print("[runtime移除] 目标=%s 关键词=%s" % [
						tarGet.display_name,
						Keywords.get_keyword_name(runtime.keyword)
					])
					Keywords.remove_keyword_from_target(tarGet, runtime.keyword)

# 把目标在“当前回合行动队列”中向后延一格
func delay_target_one_slot_in_current_round(tarGet: Battle_Character, round_action_order: Array, turn_index: int):
	var target_index = round_action_order.find(tarGet)
	
	if target_index == -1:
		return
	
	if target_index <= turn_index:
		return
	
	if target_index >= round_action_order.size() - 1:
		return

	var next_character = round_action_order[target_index + 1]
	round_action_order[target_index + 1] = tarGet
	round_action_order[target_index] = next_character

	print("[行动延后] 目标=%s 新的index=%d" % [tarGet.display_name, target_index + 1])


func change_abilities_countdown():
	if  Global_Model.current_character.control == false:
		for i in Global_Model.current_character.ablities: 
			if Global_Model.current_character.ablities[i].countDown != 0:
				Global_Model.current_character.ablities[i].countDown = Global_Model.current_character.ablities[i].countDown - 1
	else:
		for i in Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities: 
			if Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].countDown != 0:
				Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].countDown -= 1

		
func enemy_start_attack(character:Battle_Character):
	var decision := EnemyRuleAI.decide_enemy_action(
		character,
		Global_Model.BattleCharacters.CharacterArr
	)
	
	# 选择技能
	ablities = decision["ability"]
	if ablities == null:
		return
		
	# 选择目标
	attacktarget = decision["target"]
	if attacktarget == null:
		return

	targetView = battle_scene.our_team_character[attacktarget.index]

	
	print("[使用技能] %s -> %s" % [character.display_name, ablities.displayname])
	if ablities != null:
		await calcDmg()
		

func is_group_died_all(group:Dictionary[int,Battle_Character_View]) -> bool:
	
	var died_all = true
	
	for index in group:
		for character in Global_Model.BattleCharacters.CharacterArr:
			if index == character.index:
				if character.died == false:
					died_all = false
					break
	
	return died_all
				
func calcDmg():
	if ablities.target == false:
		var count = ablities.attackCount
		ablities.countDown = ablities.abCooldown
		print("[技能结算] 冷却=%d 每段伤害=%d 目标=%s 伤害段数=%d" % [
			ablities.countDown,
			ablities.dmg,
			attacktarget.display_name,
			count
		])
		
		while count > 0:
			await Audio.play_attack_sfx()
			
			var target_keywords = Keywords.get_keywords_from_runtimes(attacktarget.keyword_runtimes)
			var current_keywords = Keywords.get_keywords_from_runtimes(Global_Model.current_character.keyword_runtimes)
			var damage_rate = Keywords.get_damage_rate(target_keywords, current_keywords)

			var final_damage = ablities.dmg * damage_rate
			var damage_value = roundi(final_damage)
			print("[伤害段] 目标=%s 状态=%s 修正率=%.2f 最终值=%d" % [
				attacktarget.display_name,
				format_keyword_list(target_keywords),
				damage_rate,
				damage_value
			])
			attacktarget.hp -= damage_value
			if attacktarget.hp <= 0:
				attacktarget.died = true
				attacktarget.hp = 0
				await targetView.tint()
				targetView.hide()
			else:
				targetView.info.text = "%s %dhp" % [attacktarget.display_name, attacktarget.hp]
				await targetView.tint()
			count -= 1
			
		var synergy_key = Keywords.apply_ability_keyword(attacktarget, ablities.status, Global_Model.current_character)
		if synergy_key != "":
			print("[触发联动] %s" % synergy_key)
			
			var synergy_info = Keywords.keywords_synergy_info[synergy_key]
			if synergy_info.has("delay_current_turn_once") and synergy_info["delay_current_turn_once"] == true:
				delay_target_one_slot_in_current_round(attacktarget, current_round_action_order, current_turn_index)

		
	else:
		var self_target = Global_Model.current_character
		Keywords.apply_ability_keyword(self_target, ablities.status, Global_Model.current_character)



func aiden_start_select_weapon():
	battle_scene.battle_menu.open()
	battle_scene.battle_menu.title.text = "请选择要使用的器灵"
	for weap in Global_Model.BattleCharacters.WeaponArr:
		battle_scene.battle_menu.item(Global_Model.BattleCharacters.WeaponArr[weap].displayName,func():
			Audio.play_menu_item_sfx()
			#print(Global_Model.BattleCharacters.WeaponArr[weap].displayName)
			battle_scene.select_character_weapon(weap)
		)
		
	await battle_scene.battle_menu.finished
	
	
var ablitiy:int
func aiden_start_select_action():
	battle_scene.battle_menu.open()
	battle_scene.battle_menu.title.text = "请选择动作"

	for i in Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities:
		print("[技能冷却] %s 剩余=%d" % [
			Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].displayname,
			Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].countDown
		])
		if Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].countDown == 0:
			battle_scene.battle_menu.item(Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].displayname,
			func():
				Audio.play_menu_item_sfx()
				#print(Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].displayname)
				ablitiy = i
				)
		
	await battle_scene.battle_menu.finished
	await aiden_start_select_target(ablitiy)

var targetIndex	

func aiden_start_select_target(index:int):
	battle_scene.battle_menu.open()
	battle_scene.battle_menu.title.text = "请选择目标"
	
	for character in Global_Model.BattleCharacters.CharacterArr:
		if character.control == false and character.died == false:
			battle_scene.battle_menu.item(character.display_name,
			func():
				Audio.play_menu_item_sfx()
				targetIndex = character.index
				#print(character.display_name)
				)
	await battle_scene.battle_menu.finished
	battle_scene.battle_menu.hide()
	for i in Global_Model.BattleCharacters.CharacterArr:
		if i.index == targetIndex:
			attacktarget = i
	ablities = Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[index]
	targetView = battle_scene.enemy_team_character[targetIndex]
	
	print("[使用技能] 艾登 -> %s" % ablities.displayname)
	
	await calcDmg()
	
		
		
	
			
		
