extends AbstractBattleState

class_name BattleLoopStates

signal player_ui_turn_finished

var ui_events_bound: bool = false
var ui_turn_active: bool = false
var ui_selected_spirit_id: String = ""

# 当前动作结算上下文
var current_ability: abilities_data
var attacktarget: Battle_Character
var targetView: Battle_Character_View
var current_action_record: Dictionary = {}

# 玩家本次行动选择
var selected_ability_index: int
var selected_action_sequence: Array[String] = []

# 回声系统运行时状态
var echo_system: EchoSystem = EchoSystem.new()
var available_echo_action_record: Dictionary = {}
var selected_echo_action_record: Dictionary = {}

# 回合流程控制
var conutNum: int = 0
var current_round_action_order: Array = []
var current_turn_index: int = -1

# 本回合碎片奖励状态
var fragment_awarded_this_round: bool = false
var fragment_rewarded_target_indices: Array[int] = []

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

func _bind_ui_events() -> void:
	if ui_events_bound:
		return

	EventManager.subscribe(UIBattleEventNames.MENU_ITEM_SELECTED, _on_ui_menu_item_selected)
	EventManager.subscribe(UIBattleEventNames.MENU_SEQUENCE_CONFIRMED, _on_ui_menu_sequence_confirmed)
	EventManager.subscribe(UIBattleEventNames.TARGET_SELECTED, _on_ui_target_selected)
	EventManager.subscribe(UIBattleEventNames.TARGET_SELECTION_CANCELED, _on_ui_target_selection_canceled)

	ui_events_bound = true

func start_player_turn_via_ui(character: Battle_Character) -> void:
	ui_turn_active = true
	ui_selected_spirit_id = str(character.weapId)
	selected_echo_action_record.clear()
	selected_action_sequence.clear()

	battle_scene.battle_ui_root.show_spirit_select_menu(
		_build_spirit_menu_items(),
		_get_player_menu_position(character.index),
		ui_selected_spirit_id
	)

	await player_ui_turn_finished

func _get_player_menu_position(character_index: int) -> Vector2:
	var view := battle_scene.our_team_character[character_index]
	return view.global_position + Vector2(180, -40)

func _finish_player_ui_turn() -> void:
	ui_turn_active = false
	player_ui_turn_finished.emit()

func _show_target_select_for_current_action(action_context: Dictionary) -> void:
	battle_scene.battle_ui_root.show_target_select_phase(
		Global_Model.current_character.index,
		_get_alive_enemy_target_ids(),
		action_context
	)

func _restore_player_menu_from_action_context(action_context: Dictionary) -> void:
	var return_stage := str(action_context.get(UIBattleEventNames.ACTION_CONTEXT_RETURN_STAGE, ""))

	if return_stage == UIBattleEventNames.ACTION_CONTEXT_RETURN_STAGE_TOP_LEVEL:
		battle_scene.battle_ui_root.show_top_level_select_menu(
			_get_player_menu_position(Global_Model.current_character.index),
			str(action_context.get(UIBattleEventNames.ACTION_CONTEXT_SPIRIT_ID, ui_selected_spirit_id)),
			str(action_context.get(UIBattleEventNames.ACTION_CONTEXT_TOP_LEVEL_ITEM_ID, ""))
		)
		return

	if return_stage == UIBattleEventNames.ACTION_CONTEXT_RETURN_STAGE_SKILL_SELECT:
		var spirit_id := str(action_context.get(UIBattleEventNames.ACTION_CONTEXT_SPIRIT_ID, ui_selected_spirit_id))
		var ability_index := int(action_context.get(UIBattleEventNames.ACTION_CONTEXT_ABILITY_INDEX, -1))
		var use_echo := bool(action_context.get(UIBattleEventNames.ACTION_CONTEXT_USE_ECHO, false))
		var order_key := str(action_context.get(UIBattleEventNames.ACTION_CONTEXT_ORDER_KEY, ""))

		battle_scene.battle_ui_root.show_skill_select_menu(
			_build_skill_menu_items(int(spirit_id), ability_index, ability_index if use_echo else -1, order_key),
			_get_player_menu_position(Global_Model.current_character.index),
			spirit_id,
			str(ability_index)
		)

func _set_selected_action_sequence_main_only() -> void:
	selected_action_sequence.clear()
	selected_action_sequence.append("main")

func _set_selected_action_sequence_with_echo(order_key: String) -> void:
	selected_action_sequence.clear()
	if order_key == "main_then_echo":
		selected_action_sequence.append("main")
		selected_action_sequence.append("echo")
	else:
		selected_action_sequence.append("echo")
		selected_action_sequence.append("main")

func _build_spirit_menu_items() -> Array:
	var items: Array = []
	for spirit_id in Global_Model.BattleCharacters.WeaponArr:
		var spirit_data = Global_Model.BattleCharacters.WeaponArr[spirit_id]
		items.append(
			battle_scene.battle_ui_root.build_spirit_menu_item(
				str(spirit_id),
				str(spirit_data.displayName),
				false
			)
		)
	return items

func _refresh_turn_order_bar(round_action_order: Array) -> void:
	var entries: Array = []

	for character in round_action_order:
		if character == null:
			continue
		if character.died:
			continue

		entries.append({
			"id": str(character.index),
			"display_name": character.display_name,
			"is_player": character.control
		})

	EventManager.push_event(UIBattleEventNames.TURN_ORDER_SET, {
		"entries": entries
	})

func _highlight_turn_order_character(character: Battle_Character) -> void:
	if character == null:
		return

	EventManager.push_event(UIBattleEventNames.TURN_ORDER_HIGHLIGHT, {
		"entry_id": str(character.index)
	})

func _clear_turn_order_bar() -> void:
	EventManager.push_event(UIBattleEventNames.TURN_ORDER_CLEAR, {})

func _on_ui_menu_item_selected(payload: Dictionary) -> void:
	if not ui_turn_active:
		return

	var menu_id := str(payload.get("menu_id", ""))
	var item_id := str(payload.get("item_id", ""))
	var item_meta: Dictionary = payload.get("item_meta", {})

	if menu_id == UIBattleEventNames.MENU_ID_SPIRIT_SELECT:
		ui_selected_spirit_id = str(item_meta.get(UIBattleEventNames.MENU_META_SPIRIT_ID, item_id))
		battle_scene.select_character_weapon(int(ui_selected_spirit_id))
		battle_scene.battle_ui_root.show_top_level_select_menu(
			_get_player_menu_position(Global_Model.current_character.index),
			ui_selected_spirit_id
		)
		return

	if menu_id == UIBattleEventNames.MENU_ID_TOP_LEVEL_SELECT:
		if item_id == UIBattleEventNames.MENU_ITEM_BASIC_ATTACK:
			selected_ability_index = _find_basic_attack_ability_index(int(ui_selected_spirit_id))
			var action_context := battle_scene.battle_ui_root.build_basic_attack_action_context(ui_selected_spirit_id)
			_show_target_select_for_current_action(action_context)
			return

		if item_id == UIBattleEventNames.MENU_ITEM_SPIRIT_SKILL:
			battle_scene.battle_ui_root.show_skill_select_menu(
				_build_skill_menu_items(int(ui_selected_spirit_id)),
				_get_player_menu_position(Global_Model.current_character.index),
				ui_selected_spirit_id
			)
			return

		if item_id == UIBattleEventNames.MENU_ITEM_ESCAPE:
			_clear_turn_order_bar()
			_finish_player_ui_turn()
			fsm.change_state(Main.States.Runaway)
			return

	if menu_id == UIBattleEventNames.MENU_ID_SKILL_SELECT:
		selected_ability_index = int(item_meta.get(UIBattleEventNames.MENU_META_ABILITY_INDEX, int(item_id)))
		selected_echo_action_record = {}
		_set_selected_action_sequence_main_only()

		var selected_ability: abilities_data = Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].abilities[selected_ability_index]
		var action_context := battle_scene.battle_ui_root.build_skill_action_context(
			ui_selected_spirit_id,
			selected_ability_index,
			false,
			""
		)

		if is_self_target_ability(selected_ability):
			attacktarget = Global_Model.current_character
			current_ability = selected_ability
			targetView = battle_scene.our_team_character[attacktarget.index]

			current_action_record = echo_system.create_action_record(
				Global_Model.current_character,
				attacktarget,
				current_ability,
				false
			)

			await execute_selected_action_sequence()

			_finish_player_ui_turn()
			return

		_show_target_select_for_current_action(action_context)

func _on_ui_menu_sequence_confirmed(payload: Dictionary) -> void:
	if not ui_turn_active:
		return

	var item_meta: Dictionary = payload.get("item_meta", {})
	var order_key := str(payload.get("order_key", ""))

	selected_ability_index = int(item_meta.get(UIBattleEventNames.MENU_META_ABILITY_INDEX, -1))
	selected_echo_action_record = available_echo_action_record.duplicate(true)
	_set_selected_action_sequence_with_echo(order_key)

	var action_context := battle_scene.battle_ui_root.build_skill_action_context(
		ui_selected_spirit_id,
		selected_ability_index,
		true,
		order_key
	)

	_show_target_select_for_current_action(action_context)

func _on_ui_target_selection_canceled(payload: Dictionary) -> void:
	if not ui_turn_active:
		return

	var action_context: Dictionary = payload.get(UIBattleEventNames.TARGET_KEY_ACTION_CONTEXT, {})
	_restore_player_menu_from_action_context(action_context)

func _on_ui_target_selected(payload: Dictionary) -> void:
	if not ui_turn_active:
		return

	var target_id := int(payload.get(UIBattleEventNames.TARGET_KEY_TARGET_ID, -1))
	var action_context: Dictionary = payload.get(UIBattleEventNames.TARGET_KEY_ACTION_CONTEXT, {})

	current_ability = Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].abilities[selected_ability_index]
	attacktarget = _find_battle_character_by_index(target_id)
	if attacktarget == null:
		return
	if not battle_scene.enemy_team_character.has(target_id):
		return
	targetView = battle_scene.enemy_team_character[target_id]

	if not bool(action_context.get(UIBattleEventNames.ACTION_CONTEXT_USE_ECHO, false)):
		selected_echo_action_record = {}
		_set_selected_action_sequence_main_only()

	current_action_record = echo_system.create_action_record(
		Global_Model.current_character,
		attacktarget,
		current_ability,
		false
	)

	await execute_selected_action_sequence()

	_finish_player_ui_turn()

func _clear_battle_log() -> void:
	EventManager.push_event(UIBattleEventNames.LOG_CLEAR, {})

func _append_turn_start_log(unit_name: String) -> void:
	EventManager.push_event(UIBattleEventNames.LOG_APPEND, {
		"log_key": UIBattleEventNames.LOG_KEY_TURN_START,
		"unit_name": unit_name
	})

func _append_skill_cast_log(source_name: String, target_name: String, skill_name: String) -> void:
	EventManager.push_event(UIBattleEventNames.LOG_APPEND, {
		"log_key": UIBattleEventNames.LOG_KEY_SKILL_CAST,
		"source_name": source_name,
		"target_name": target_name,
		"skill_name": skill_name
	})

func _append_damage_log(source_name: String, target_name: String, damage: int) -> void:
	EventManager.push_event(UIBattleEventNames.LOG_APPEND, {
		"log_key": UIBattleEventNames.LOG_KEY_DAMAGE,
		"source_name": source_name,
		"target_name": target_name,
		"damage": damage
	})

func _append_death_log(target_name: String) -> void:
	EventManager.push_event(UIBattleEventNames.LOG_APPEND, {
		"log_key": UIBattleEventNames.LOG_KEY_DEATH,
		"target_name": target_name
	})

func _append_echo_gain_log(amount: int) -> void:
	EventManager.push_event(UIBattleEventNames.LOG_APPEND, {
		"log_key": UIBattleEventNames.LOG_KEY_ECHO_GAIN,
		"amount": amount
	})

func _append_echo_use_log(amount: int) -> void:
	EventManager.push_event(UIBattleEventNames.LOG_APPEND, {
		"log_key": UIBattleEventNames.LOG_KEY_ECHO_USE,
		"amount": amount
	})

func _find_basic_attack_ability_index(spirit_id: int) -> int:
	for ability_index in Global_Model.BattleCharacters.WeaponArr[spirit_id].abilities:
		var ability = Global_Model.BattleCharacters.WeaponArr[spirit_id].abilities[ability_index]
		if ability.abCooldown == 0:
			return ability_index
	return -1

func _get_alive_enemy_target_ids() -> Array:
	var ids: Array = []
	for character in Global_Model.BattleCharacters.CharacterArr:
		if not character.control and not character.died:
			ids.append(character.index)
	return ids

func _find_battle_character_by_index(character_index: int) -> Battle_Character:
	for character in Global_Model.BattleCharacters.CharacterArr:
		if character.index == character_index:
			return character
	return null

func _build_skill_menu_items(
	spirit_id: int,
	selected_ability: int = -1,
	echo_bound_ability: int = -1,
	_order_key: String = ""
) -> Array:
	var items: Array = []
	var weapon_data = Global_Model.BattleCharacters.WeaponArr[spirit_id]

	available_echo_action_record = {}
	if echo_system.can_insert_echo(Global_Model.echonum):
		available_echo_action_record = echo_system.get_previous_round_action()

	for ability_index in weapon_data.abilities:
		var ability = weapon_data.abilities[ability_index]
		if ability.abCooldown == 0:
			continue

		var slot_text := ""
		var slot_state := ""

		if ability_index == echo_bound_ability:
			slot_text = "已插"
			slot_state = UIBattleEventNames.MENU_SLOT_STATE_FILLED
		elif Global_Model.echonum <= 0:
			slot_text = "碎片不足"
			slot_state = UIBattleEventNames.MENU_SLOT_STATE_NO_FRAGMENT
		elif available_echo_action_record.is_empty():
			slot_text = "不可用"
			slot_state = UIBattleEventNames.MENU_SLOT_STATE_UNAVAILABLE
		else:
			slot_text = "[空]"
			slot_state = UIBattleEventNames.MENU_SLOT_STATE_EMPTY

		items.append(
			battle_scene.battle_ui_root.build_skill_menu_item(
				ability_index,
				str(ability.displayname),
				"冷却 %d" % ability.countDown,
				"关键词：%s" % Keywords.get_keyword_name(ability.status),
				slot_text,
				slot_state,
				ability.countDown != 0
			)
		)

	return items

func _get_player_character() -> Battle_Character:
	for character in Global_Model.BattleCharacters.CharacterArr:
		if character.control:
			return character
	return null

func _refresh_player_hud() -> void:
	var player := _get_player_character()
	if player == null:
		EventManager.push_event(UIBattleEventNames.PLAYER_HUD_HIDE, {})
		return

	EventManager.push_event(UIBattleEventNames.PLAYER_HUD_SET, {
		"unit_name": player.display_name,
		"current_hp": player.hp,
		"max_hp": player.max_hp,
		"shield_value": player.shield_hp
	})

func enter():
	_bind_ui_events()
	# 开战时清空回声记录
	echo_system.reset_for_battle()
	_refresh_player_hud()
	_clear_battle_log()

	# 根据速度生成行动顺序表
	var battle_action_list = Battle_Action_List.new()
	battle_action_list.action_list_by_speed()
	
	while 1:
		var round_action_order = Global_Model.BattleCharacters.CharacterArr.duplicate()
		current_round_action_order = round_action_order
		_refresh_turn_order_bar(round_action_order)
		
		# 新回合开始时清空本回合候选记录
		echo_system.begin_round()
		fragment_awarded_this_round = false
		fragment_rewarded_target_indices.clear()
		
		var turn_index = 0
		while turn_index < round_action_order.size():
			var character = round_action_order[turn_index]
			current_turn_index = turn_index
			Global_Model.current_character = character
			_highlight_turn_order_character(character)
			
			# 已死亡单位直接跳过本回合行动
			if character.died:
				print("[跳过行动] %s 已死亡" % character.display_name)
				turn_index += 1
				continue

			print("\n[行动角色] %s" % character.display_name)
			on_character_turn_start(character)
			
			# 先找到行动的角色的view，然后调用这个view里面的向前走一步方法
			if character.control == true and character.display_name == "艾登" and character.died == false:
				var characterView:Battle_Character_View = battle_scene.our_team_character[character.index]
				characterView.forward()
				if conutNum != 0:
					await change_abilities_countdown()
				# 通过事件驱动 UI 让玩家完成本次行动选择
				await start_player_turn_via_ui(character)
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
			
		# 冻结上一回合记录
		echo_system.end_round()

		if is_group_died_all(battle_scene.enemy_team_character):
			_clear_turn_order_bar()
			fsm.change_state(Main.States.Win)
			break
		elif is_group_died_all(battle_scene.our_team_character):
			_clear_turn_order_bar()
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
	_append_turn_start_log(character.display_name)

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
		
		if character.control:
			_refresh_player_hud()
	resolve_expiring_shields_for_caster(character)

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
	if character.control:
		_refresh_player_hud()

# 护盾持续时间结束时清除
func resolve_expiring_shields_for_caster(character: Battle_Character) -> void:
	for target in Global_Model.BattleCharacters.CharacterArr:
		if target.shield_hp <= 0:
			continue

		if target.shield_caster_index != character.index:
			continue

		target.shield_remaining_owner_turn_ends -= 1
		print("[护盾runtime结算] 施放者=%s 目标=%s 剩余=%d 当前护盾=%d" % [
			character.display_name,
			target.display_name,
			target.shield_remaining_owner_turn_ends,
			target.shield_hp
		])

		if target.shield_remaining_owner_turn_ends <= 0:
			print("[护盾移除] 目标=%s 护盾清空=%d" % [
				target.display_name,
				target.shield_hp
			])
			target.clear_shield()
			
			if target.control:
				_refresh_player_hud()
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
	_refresh_turn_order_bar(round_action_order)
	_highlight_turn_order_character(Global_Model.current_character)

# 联动成功后，尝试给予轮回碎片
func try_grant_fragment_for_synergy(target: Battle_Character, synergy_key: String, is_echo_action: bool) -> void:
	if synergy_key == "":
		return

	# 回声触发的联动不奖励碎片
	if is_echo_action:
		return

	# 只有玩家单位触发的联动才奖励碎片
	if not Global_Model.current_character.control:
		return

	# 本回合已经拿过碎片，就不再奖励
	if fragment_awarded_this_round:
		return

	# 同一目标本回合已经结算过碎片判定，就不再奖励
	if fragment_rewarded_target_indices.has(target.index):
		return

	fragment_awarded_this_round = true
	fragment_rewarded_target_indices.append(target.index)
	Global_Model.echonum += 1
	_append_echo_gain_log(1)

	print("[获得碎片] 联动=%s 目标=%s 当前碎片=%d" % [
		synergy_key,
		target.display_name,
		Global_Model.echonum
	])

func change_abilities_countdown():
	if  Global_Model.current_character.control == false:
		for i in Global_Model.current_character.abilities: 
			if Global_Model.current_character.abilities[i].countDown != 0:
				Global_Model.current_character.abilities[i].countDown = Global_Model.current_character.abilities[i].countDown - 1
	else:
		for i in Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].abilities: 
			if Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].abilities[i].countDown != 0:
				Global_Model.BattleCharacters.WeaponArr[Global_Model.current_character.weapId].abilities[i].countDown -= 1

# 判断是否自我目标技能
func is_self_target_ability(ability: abilities_data) -> bool:
	return ability.target == true
			
func enemy_start_attack(character:Battle_Character):
	var decision := EnemyRuleAI.decide_enemy_action(
		character,
		Global_Model.BattleCharacters.CharacterArr
	)
	
	# 选择技能
	current_ability = decision["ability"]
	if current_ability == null:
		return
		
	# 选择目标
	attacktarget = decision["target"]
	if attacktarget == null:
		return

	targetView = battle_scene.our_team_character[attacktarget.index]

	print("[使用技能] %s -> %s" % [character.display_name, current_ability.displayname])
	_append_skill_cast_log(
		character.display_name,
		attacktarget.display_name,
		current_ability.displayname
	)

	if current_ability != null:
		await calcDmg()
		await finalize_current_action_target()
	

func is_group_died_all(group:Dictionary[int,Battle_Character_View]) -> bool:
	
	var died_all = true
	
	for index in group:
		for character in Global_Model.BattleCharacters.CharacterArr:
			if index == character.index:
				if character.died == false:
					died_all = false
					break
	
	return died_all

func is_invalid_resolution_target(target: Battle_Character) -> bool:
	return target == null or target.died or target.hp <= 0

# 友方技能效果施加
func apply_self_target_ability_extra_effects(target: Battle_Character, ability_name: String) -> void:
	if ability_name == "守势回稳":
		var removed_keyword = Keywords.remove_random_attack_keyword_from_target(target)

		if removed_keyword == Keywords.keywords.NONE:
			print("[守势回稳] %s 没有可清除的攻击型关键词" % target.display_name)
		else:
			print("[守势回稳] %s 清除了 %s" % [
				target.display_name,
				Keywords.get_keyword_name(removed_keyword)
			])

	elif ability_name == "盾牌守护":
		var shield_value = roundi(target.max_hp * 0.1)
		target.add_shield(shield_value)
		target.refresh_shield_runtime(
			target.index,
			Keywords.get_owner_turn_end_duration(Keywords.keywords.PROTECTION)
		)

		print("[盾牌守护] %s 获得护盾=%d 当前护盾=%d" % [
			target.display_name,
			shield_value,
			target.shield_hp
		])

func calcDmg():
	if current_ability.target == false:
		var count = current_ability.attackCount
		current_ability.countDown = current_ability.abCooldown
		print("[技能结算] 冷却=%d 每段伤害=%d 目标=%s 伤害段数=%d" % [
			current_ability.countDown,
			current_ability.dmg,
			attacktarget.display_name,
			count
		])

		while count > 0:
			if is_invalid_resolution_target(attacktarget):
				break

			await Audio.play_attack_sfx()

			var target_keywords = Keywords.get_keywords_from_runtimes(attacktarget.keyword_runtimes)
			var current_keywords = Keywords.get_keywords_from_runtimes(Global_Model.current_character.keyword_runtimes)
			var damage_rate = Keywords.get_damage_rate(target_keywords, current_keywords)

			var final_damage = current_ability.dmg * damage_rate
			var damage_value = roundi(final_damage)
			print("[伤害段] 目标=%s 状态=%s 修正率=%.2f 最终值=%d" % [
				attacktarget.display_name,
				format_keyword_list(target_keywords),
				damage_rate,
				damage_value
			])

			var hp_damage = attacktarget.apply_damage_to_shield_and_hp(damage_value)
			var absorbed_damage = damage_value - hp_damage
			if hp_damage > 0:
				_append_damage_log(
					Global_Model.current_character.display_name,
					attacktarget.display_name,
					hp_damage
				)

			if attacktarget.control:
				_refresh_player_hud()
			print("[受伤结算] %s 护盾吸收=%d 实际扣血=%d 剩余护盾=%d 剩余hp=%d" % [
				attacktarget.display_name,
				absorbed_damage,
				hp_damage,
				attacktarget.shield_hp,
				attacktarget.hp
			])

			targetView.info.text = "%s %dhp" % [attacktarget.display_name, attacktarget.hp]
			await targetView.tint()

			count -= 1

			if is_invalid_resolution_target(attacktarget):
				break

		if not is_invalid_resolution_target(attacktarget):
			var synergy_key = Keywords.apply_ability_keyword(
				attacktarget,
				current_ability.status,
				Global_Model.current_character
			)
			if synergy_key != "":
				print("[触发联动] %s" % synergy_key)
				try_grant_fragment_for_synergy(attacktarget, synergy_key, false)

				var synergy_info = Keywords.keywords_synergy_info[synergy_key]
				if synergy_info.has("delay_current_turn_once") and synergy_info["delay_current_turn_once"] == true:
					delay_target_one_slot_in_current_round(
						attacktarget,
						current_round_action_order,
						current_turn_index
					)

	else:
		var self_target = Global_Model.current_character
		current_ability.countDown = current_ability.abCooldown
		apply_self_target_ability_extra_effects(self_target, current_ability.displayname)
		Keywords.apply_ability_keyword(self_target, current_ability.status, Global_Model.current_character)
		
		if self_target.control:
			_refresh_player_hud()

	# 整条动作结束后再提交记录
	if not current_action_record.is_empty():
		echo_system.commit_action_record(current_action_record)
		current_action_record = {}

# 统一处理本次动作结束后的目标收尾
func finalize_current_action_target() -> void:
	if attacktarget == null or targetView == null:
		return

	if attacktarget.hp <= 0:
		attacktarget.hp = 0
		if not attacktarget.died:
			print("[动作收尾] 目标死亡=%s" % attacktarget.display_name)
			attacktarget.died = true
			_append_death_log(attacktarget.display_name)
			
			await targetView.tint()
			targetView.hide()
	else:
		print("[动作收尾] 目标存活=%s hp=%d" % [attacktarget.display_name, attacktarget.hp])
		targetView.info.text = "%s %dhp" % [attacktarget.display_name, attacktarget.hp]

# 按顺序执行本次玩家行动
func execute_selected_action_sequence() -> void:
	if current_ability != null and attacktarget != null:
		_append_skill_cast_log(
			Global_Model.current_character.display_name,
			attacktarget.display_name,
			current_ability.displayname
		)

	for action_key in selected_action_sequence:
		if action_key == "main":
			await calcDmg()
		elif action_key == "echo":
			await execute_selected_echo()

	await finalize_current_action_target()

# 执行已选中的回声结算
func execute_selected_echo() -> void:
	if selected_echo_action_record.is_empty():
		return
		
	# 扣除1个回声碎片
	if Global_Model.echonum > 0:
		Global_Model.echonum -= 1
		print("[回声消耗] 剩余碎片=%d" % Global_Model.echonum)
		_append_echo_use_log(1)

	if is_invalid_resolution_target(attacktarget):
		print("[回声结算] 当前目标无效，跳过回声")
		return

	print("[回声结算] 技能=%s 目标=%s" % [
		selected_echo_action_record["ability_name"],
		attacktarget.display_name
	])

	var preview_target_keywords = Keywords.get_keywords_from_runtimes(attacktarget.keyword_runtimes)
	var preview_caster_keywords = Keywords.get_keywords_from_runtimes(Global_Model.current_character.keyword_runtimes)
	var preview_damage_rate = Keywords.get_damage_rate(preview_target_keywords, preview_caster_keywords)

	print("[回声重算预览] 基础伤害=%d 段数=%d 当前目标状态=%s 当前施法者状态=%s 当前修正率=%.2f" % [
		int(selected_echo_action_record["ability_base_damage"]),
		int(selected_echo_action_record["ability_attack_count"]),
		format_keyword_list(preview_target_keywords),
		format_keyword_list(preview_caster_keywords),
		preview_damage_rate
	])

	var echo_base_damage: int = int(selected_echo_action_record["ability_base_damage"])
	var echo_attack_count: int = int(selected_echo_action_record["ability_attack_count"])

	for i in range(echo_attack_count):
		if is_invalid_resolution_target(attacktarget):
			break

		await Audio.play_attack_sfx()

		var echo_target_keywords = Keywords.get_keywords_from_runtimes(attacktarget.keyword_runtimes)
		var echo_caster_keywords = Keywords.get_keywords_from_runtimes(Global_Model.current_character.keyword_runtimes)
		var echo_damage_rate = Keywords.get_damage_rate(echo_target_keywords, echo_caster_keywords)

		var final_damage = echo_base_damage * echo_damage_rate
		var damage_value = roundi(final_damage)

		print("[回声伤害段] 目标=%s 状态=%s 修正率=%.2f 最终值=%d" % [
			attacktarget.display_name,
			format_keyword_list(echo_target_keywords),
			echo_damage_rate,
			damage_value
		])

		var hp_damage = attacktarget.apply_damage_to_shield_and_hp(damage_value)
		var absorbed_damage = damage_value - hp_damage
		if hp_damage > 0:
			_append_damage_log(
				Global_Model.current_character.display_name,
				attacktarget.display_name,
				hp_damage
			)

		print("[回声受伤结算] %s 护盾吸收=%d 实际扣血=%d 剩余护盾=%d 剩余hp=%d" % [
			attacktarget.display_name,
			absorbed_damage,
			hp_damage,
			attacktarget.shield_hp,
			attacktarget.hp
		])

		targetView.info.text = "%s %dhp" % [attacktarget.display_name, attacktarget.hp]
		await targetView.tint()

		if is_invalid_resolution_target(attacktarget):
			break

			
	# 回声补一次关键词效果
	var echo_keyword: int = int(selected_echo_action_record["ability_keyword"])
	if echo_keyword != Keywords.keywords.NONE and not is_invalid_resolution_target(attacktarget):
		if bool(selected_echo_action_record["ability_target_is_self"]):
			apply_self_target_ability_extra_effects(
				attacktarget,
				String(selected_echo_action_record["ability_name"])
			)

		var synergy_key = Keywords.apply_ability_keyword(
			attacktarget,
			echo_keyword,
			Global_Model.current_character
		)

		if synergy_key != "":
			print("[回声联动] %s" % synergy_key)
			try_grant_fragment_for_synergy(attacktarget, synergy_key, true)
			
			var synergy_info = Keywords.keywords_synergy_info[synergy_key]
			if synergy_info.has("delay_current_turn_once") and synergy_info["delay_current_turn_once"] == true:
				delay_target_one_slot_in_current_round(
					attacktarget,
					current_round_action_order,
					current_turn_index
				)
