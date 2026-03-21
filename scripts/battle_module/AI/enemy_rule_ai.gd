extends RefCounted
class_name EnemyRuleAI

# 决定敌人的行动总入口
static func decide_enemy_action(enemy: Battle_Character, all_characters: Array[Battle_Character]) -> Dictionary:
	if enemy.display_name == "铁壁卫士":
		return decide_guardian_action(enemy, all_characters)

	if enemy.display_name == "帝国射手":
		return decide_archer_action(enemy, all_characters)

	return {
		"ability": null,
		"target": null
	}

# 在全体角色里筛选合法玩家
static func get_alive_player_targets(all_characters: Array[Battle_Character]) -> Array[Battle_Character]:
	var result: Array[Battle_Character] = []

	for character in all_characters:
		if character.control == true and character.died == false:
			result.append(character)

	return result

# 获取可用技能列表
static func get_available_enemy_abilities(enemy: Battle_Character) -> Array[ablities_data]:
	var result: Array[ablities_data] = []

	for ability_index in enemy.ablities:
		var ability: ablities_data = enemy.ablities[ability_index]
		if ability.countDown == 0:
			result.append(ability)

	return result

# 在可用技能中找到对应的名字的技能对象
static func find_ability_by_name(
	available_abilities: Array[ablities_data],
	ability_name: String
) -> ablities_data:
	for ability in available_abilities:
		if ability.displayname == ability_name:
			return ability

	return null

# 判断目标当前是否持有某个关键词
static func target_has_keyword(target: Battle_Character, keyword: int) -> bool:
	return Keywords.has_keyword_runtime(target, keyword)

# 从目标列表中筛出持有指定关键词的目标
static func get_targets_with_keyword(
	targets: Array[Battle_Character],
	keyword: int
) -> Array[Battle_Character]:
	var result: Array[Battle_Character] = []

	for target in targets:
		if target_has_keyword(target, keyword):
			result.append(target)

	return result

# 从目标列表中筛出没有指定关键词的目标
static func get_targets_without_keyword(
	targets: Array[Battle_Character],
	keyword: int
) -> Array[Battle_Character]:
	var result: Array[Battle_Character] = []

	for target in targets:
		if not target_has_keyword(target, keyword):
			result.append(target)

	return result

# 从候选目标中筛出当前 HP 最低的所有目标
static func get_lowest_hp_targets(targets: Array[Battle_Character]) -> Array[Battle_Character]:
	var result: Array[Battle_Character] = []

	if targets.is_empty():
		return result

	var lowest_hp := targets[0].hp

	for target in targets:
		if target.hp < lowest_hp:
			lowest_hp = target.hp

	for target in targets:
		if target.hp == lowest_hp:
			result.append(target)

	return result

# 从候选目标中随机选出一个
static func pick_random_target(targets: Array[Battle_Character]) -> Battle_Character:
	if targets.is_empty():
		return null

	return targets.pick_random()

# 铁壁卫士使用盾击时的目标选择
static func choose_guardian_shield_bash_target(
	player_targets: Array[Battle_Character]
) -> Battle_Character:
	var targets_without_stagger := get_targets_without_keyword(
		player_targets,
		Keywords.keywords.STAGGER
	)

	if targets_without_stagger.is_empty():
		return null

	var lowest_hp_targets := get_lowest_hp_targets(targets_without_stagger)
	return pick_random_target(lowest_hp_targets)

# 铁壁卫士使用盾牌冲锋时的目标选择
static func choose_guardian_shield_charge_target(
	player_targets: Array[Battle_Character]
) -> Battle_Character:
	var lowest_hp_targets := get_lowest_hp_targets(player_targets)
	return pick_random_target(lowest_hp_targets)
	
# 铁壁卫士的技能选择
static func choose_guardian_ability(
	enemy: Battle_Character,
	player_targets: Array[Battle_Character]
) -> ablities_data:
	var available_abilities := get_available_enemy_abilities(enemy)

	var shield_bash := find_ability_by_name(available_abilities, "盾击")
	if shield_bash != null:
		var targets_without_stagger := get_targets_without_keyword(
			player_targets,
			Keywords.keywords.STAGGER
		)
		if not targets_without_stagger.is_empty():
			return shield_bash

	return find_ability_by_name(available_abilities, "盾牌冲锋")

# 铁壁卫士的目标选择
static func choose_guardian_target(
	selected_ability: ablities_data,
	player_targets: Array[Battle_Character]
) -> Battle_Character:
	if selected_ability == null:
		return null

	if selected_ability.displayname == "盾击":
		return choose_guardian_shield_bash_target(player_targets)

	if selected_ability.displayname == "盾牌冲锋":
		return choose_guardian_shield_charge_target(player_targets)

	return null

# 铁壁卫士完整决策
static func decide_guardian_action(
	enemy: Battle_Character,
	all_characters: Array[Battle_Character]
) -> Dictionary:
	var player_targets := get_alive_player_targets(all_characters)
	var selected_ability := choose_guardian_ability(enemy, player_targets)
	var selected_target := choose_guardian_target(selected_ability, player_targets)

	return {
		"ability": selected_ability,
		"target": selected_target
	}

# 帝国射手使用瞄准射击时的目标选择
static func choose_archer_aimed_shot_target(
	player_targets: Array[Battle_Character]
) -> Battle_Character:
	var stagger_targets := get_targets_with_keyword(
		player_targets,
		Keywords.keywords.STAGGER
	)

	var candidate_targets := stagger_targets
	if candidate_targets.is_empty():
		candidate_targets = player_targets

	var lowest_hp_targets := get_lowest_hp_targets(candidate_targets)
	return pick_random_target(lowest_hp_targets)

# 帝国射手使用射击时的目标选择
static func choose_archer_basic_shot_target(
	player_targets: Array[Battle_Character]
) -> Battle_Character:
	var lowest_hp_targets := get_lowest_hp_targets(player_targets)
	return pick_random_target(lowest_hp_targets)

# 帝国射手的技能选择
static func choose_archer_ability(
	enemy: Battle_Character,
	player_targets: Array[Battle_Character]
) -> ablities_data:
	var available_abilities := get_available_enemy_abilities(enemy)

	var aimed_shot := find_ability_by_name(available_abilities, "瞄准射击")
	if aimed_shot != null:
		return aimed_shot

	return find_ability_by_name(available_abilities, "射击")

# 帝国射手的目标选择
static func choose_archer_target(
	selected_ability: ablities_data,
	player_targets: Array[Battle_Character]
) -> Battle_Character:
	if selected_ability == null:
		return null

	if selected_ability.displayname == "瞄准射击":
		return choose_archer_aimed_shot_target(player_targets)

	if selected_ability.displayname == "射击":
		return choose_archer_basic_shot_target(player_targets)

	return null

# 帝国射手完整决策
static func decide_archer_action(
	enemy: Battle_Character,
	all_characters: Array[Battle_Character]
) -> Dictionary:
	var player_targets := get_alive_player_targets(all_characters)
	var selected_ability := choose_archer_ability(enemy, player_targets)
	var selected_target := choose_archer_target(selected_ability, player_targets)

	return {
		"ability": selected_ability,
		"target": selected_target
	}
