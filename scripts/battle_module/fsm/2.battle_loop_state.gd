extends AbstractBattleState

class_name BattleLoopStates

var ablities:ablities_data
var attacktarget:Battle_Character
var targetView:Battle_Character_View
var conutNum:int = 0
func enter():
	
	# 根据速度生成行动顺序表
	var battle_action_list = Battle_Action_List.new()
	battle_action_list.action_list_by_speed()
	
<<<<<<< HEAD
	for character in Global_Model.BattleCharacters.CharacterArr:
		Global_Model.current_character = character
		#on_turn_start(character)
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
#func on_turn_start(character:Battle_Character):
	#for keyword in character.states.duplicate():
		#if States.expire_on_turn_start(keyword):
			#character.states.erase(keyword)

=======
	while 1:
		
		for character in Global_Model.BattleCharacters.CharacterArr:
			Global_Model.current_character = character
			print(character.display_name)
			
			# 先找到行动的角色的view，然后调用这个view里面的向前走一步方法
			if character.control == true and character.display_name == "艾登" and character.died == false:
				var characterView:Battle_Character_View = battle_scene.our_team_character[character.index]
				characterView.forward()
				# 弹出菜单让玩家选择
				await aiden_start_select_weapon()
				await aiden_start_select_action()
				characterView.backward()
				if conutNum != 0:
					await change_abilities_countdown()
			elif character.control == false and character.died == false:
				var characterView:Battle_Character_View = battle_scene.enemy_team_character[character.index]
				characterView.forward()
				# 敌人则自动行动
				await enemy_start_attack(character)
				if conutNum != 0:
					await change_abilities_countdown()
				characterView.backward()
			
		if is_group_died_all(battle_scene.enemy_team_character):
			fsm.change_state(Main.States.Win)
			break
		elif is_group_died_all(battle_scene.our_team_character):
			fsm.change_state(Main.States.Lose)
			break
			
		conutNum += 1
			
	
func change_abilities_countdown():
	if  Global_Model.current_character.control == false:
		for i in Global_Model.current_character.ablities: 
			if Global_Model.current_character.ablities[i].countDown != 0:
				Global_Model.current_character.ablities[i].countDown = Global_Model.current_character.ablities[i].countDown - 1
	else:
		for i in Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities: 
			if Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].countDown != 0:
				Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].countDown -= 1
>>>>>>> 580ec6214cc9d650f2ac04f080cc74603a2e6a11

		
func enemy_start_attack(character:Battle_Character):
	
	
	while 1:
		var key = character.ablities.keys().pick_random()
		var random_value = character.ablities[key]
		if random_value.countDown != 0:
			continue
		else:
			ablities = random_value
			break
	
	while(1):
		attacktarget = Global_Model.BattleCharacters.CharacterArr.pick_random()
		if attacktarget.control:
			targetView = battle_scene.our_team_character[attacktarget.index]
			break
	
	print(character.display_name + "使用了" + ablities.displayname)
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
		print("冷却剩余时间: " + str(ablities.countDown) + "技能伤害" + str(ablities.dmg) + "目标" + attacktarget.display_name + "攻击了" + str(count) + "次")
		while count > 0:
			await Audio.play_attack_sfx()
			attacktarget.hp = attacktarget.hp - ablities.dmg
			if attacktarget.hp <= 0:
				attacktarget.died = true
				attacktarget.hp = 0
				await targetView.tint()
				targetView.hide()
			else:
				targetView.info.text = "%s %dhp" % [attacktarget.display_name, attacktarget.hp]
				await targetView.tint()
			count -= 1
				


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
		print(Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].displayname + "剩余冷却时间" + str(Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].ablities[i].countDown))
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
	
	print("艾登使用了" + ablities.displayname)
	
	await calcDmg()
	
		
		
	
			
		
