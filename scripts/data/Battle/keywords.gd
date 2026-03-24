class_name Keywords

# 枚举所有关键词和联动效果
enum keywords {
	NONE, # 无
	PIERCE, # 穿刺
	STAGGER, # 震荡
	PROTECTION, # 护持
	STABLE, # 稳固
	PIERCE_STAGGER_SYNERGY, # 穿刺震荡联动
	PROTECTION_STABLE_SYNERGY # 护持稳固联动
}

# 将每个关键词和联动状态的名字，类型，效果，触发规则和失效规则都用字典的方式存起来
static var keywords_info : Dictionary = {
	keywords.NONE : {
		"name" : "无",
		"type" : "无",
		"effect" : "无效果",
		"trigger_rule" : "无",
		"expire_rule" : "无",
		"damage_taken_rate" : 0.0,
		"damage_dealt_rate" : 0.0
	},
	keywords.PIERCE : {
		"name" : "穿刺",
		"type" : "进攻型",
		"effect" : "目标受到的伤害提高10%",
		"trigger_rule" : "持续生效，无单独触发时机",
		"expire_rule" : "施放者的下一个回合行动结束时失效",
		"damage_taken_rate" : 0.1,
		"damage_dealt_rate" : 0.0,
		"owner_turn_end_duration" : 2
	},
	keywords.STAGGER : {
		"name" : "震荡",
		"type" : "进攻型",
		"effect" : "目标造成的伤害降低30%",
		"trigger_rule" : "持续生效，无单独触发时机",
		"expire_rule" : "施放者的下一个回合行动结束时失效",
		"damage_taken_rate" : 0.0,
		"damage_dealt_rate" : -0.3,
		"owner_turn_end_duration" : 2
	},
	keywords.PROTECTION : {
		"name" : "护持",
		"type" : "防御型",
		"effect" : "目标受到的伤害降低30%",
		"trigger_rule" : "持续生效，无单独触发时机",
		"expire_rule" : "施放者的下一个回合行动结束时失效",
		"damage_taken_rate" : -0.3,
		"damage_dealt_rate" : 0.0,
		"owner_turn_end_duration" : 2
	},
	keywords.STABLE : {
		"name" : "稳固",
		"type" : "防御型",
		"effect" : "目标回合结束时恢复其10%的血量",
		"trigger_rule" : "施放者行动结束时",
		"expire_rule" : "施放者的下一个回合行动结束时失效",
		"damage_taken_rate" : 0.0,
		"damage_dealt_rate" : 0.0,
		"owner_turn_end_duration" : 2
	},
	keywords.PIERCE_STAGGER_SYNERGY : {
		"name" : "穿刺震荡联动",
		"type" : "进攻型",
		"effect" : "目标受到的伤害提高20%；且目标行动轮次在本回合延后一个单位",
		"trigger_rule" : "由【穿刺】和【震荡】联动触发",
		"expire_rule" : "施放者的下一个回合行动结束时失效",
		"damage_taken_rate" : 0.2,
		"damage_dealt_rate" : 0.0,
		"owner_turn_end_duration" : 2
	},
	keywords.PROTECTION_STABLE_SYNERGY : {
		"name" : "护持稳固联动",
		"type" : "防御型",
		"effect" : "目标不会因受到伤害而被附加新的进攻型关键词",
		"trigger_rule" : "由【护持】和【稳固】联动触发",
		"expire_rule" : "施放者的下一个回合行动结束时失效",
		"damage_taken_rate" : 0.0,
		"damage_dealt_rate" : 0.0,
		"owner_turn_end_duration" : 2
	}
}

# 关键词的联动信息
static var keywords_synergy_info:Dictionary = {
	"PIERCE_STAGGER" : {
		"type" : "进攻型",
		"effect" : "目标受到的伤害提高20%；且目标行动轮次在本回合延后一个单位",
		"trigger_rule" : "【穿刺】和【震荡】同时出现在目标身上时",
		"expire_rule" : "施放者的下一个回合行动结束时失效",
		"remove_old" : true,
		"damage_taken_rate" : 0.2,
		"result_state" : keywords.PIERCE_STAGGER_SYNERGY,
		"delay_current_turn_once" : true
	},
	"PROTECTION_STABLE" : {
		"type" : "防御型",
		"effect" : "目标不会因受到伤害而被附加新的进攻型关键词",
		"trigger_rule" : "【护持】和【稳固】同时出现在目标身上时",
		"expire_rule" : "施放者的下一个回合行动结束时失效",
		"remove_old" : true,
		"damage_taken_rate" : 0.0,
		"result_state" : keywords.PROTECTION_STABLE_SYNERGY
	}
}

# 拿到一个关键词的受到伤害修正值
static func get_keyword_damage_taken_rate(keyword):
	if not keywords_info.has(keyword):
		return 0.0
	return keywords_info[keyword]["damage_taken_rate"]

# 计算所有关键词的受到伤害修正值
static func get_total_damage_taken_rate(states):
	var total_rate = 0.0
	
	for keyword in states:
		total_rate += get_keyword_damage_taken_rate(keyword)
	
	return total_rate

# 拿到一个关键词的造成伤害修正值
static func get_keyword_damage_dealt_rate(keyword):
	if not keywords_info.has(keyword):
		return 0.0
	return keywords_info[keyword]["damage_dealt_rate"]

# 计算所有关键词的造成伤害修正值
static func get_total_damage_dealt_rate(states):
	var total_rate = 0.0
	
	for keyword in states:
		total_rate += get_keyword_damage_dealt_rate(keyword)
	
	return total_rate

# 综合计算伤害修正值。
static func get_damage_rate(target_states, current_states):
	var damage_taken = get_total_damage_taken_rate(target_states)
	var damage_dealt = get_total_damage_dealt_rate(current_states)
	
	return (1.0 + damage_taken) * (1.0 + damage_dealt)

# 给目标附加关键词/联动状态
static func apply_ability_keyword(target, ability_state, caster):
	if not target.died and ability_state != Keywords.keywords.NONE:
		if has_protection_stable_synergy(target) and is_attack_keyword(ability_state):
			return ""
		
		var target_keywords = get_keywords_from_runtimes(target.keyword_runtimes)
		for current_state in target_keywords:
			var synergy_key = get_synergy_key(current_state, ability_state)

			if synergy_key != "":
				var synergy_info = keywords_synergy_info[synergy_key]
				var remove_old = synergy_info["remove_old"]

				if remove_old == true:
					remove_keyword_from_target(target, current_state)

				var result_state = synergy_info["result_state"]
				set_keyword_on_target(target, result_state, caster)

				return synergy_key

		set_keyword_on_target(target, ability_state, caster)

	return ""
			
# 获取联动字符串键
static func get_synergy_key(state_a, state_b):
	if (state_a == keywords.PIERCE and state_b == keywords.STAGGER) or (state_a == keywords.STAGGER and state_b == keywords.PIERCE):
		return "PIERCE_STAGGER"
		
	if (state_a == keywords.PROTECTION and state_b == keywords.STABLE) or (state_a == keywords.STABLE and state_b == keywords.PROTECTION):
		return "PROTECTION_STABLE"
	return ""

# 获取联动的关键词效果信息
static func get_synergy_info(state_a, state_b):
	var synergy_key = get_synergy_key(state_a, state_b)
	
	if synergy_key == "":
		return {}
	return keywords_synergy_info[synergy_key]

# 判断该关键词是否为进攻型
static func is_attack_keyword(keyword):
	if not keywords_info.has(keyword):
		return false
	
	return keywords_info[keyword]["type"] == "进攻型"

# 移除随机的进攻型关键词状态
static func remove_random_attack_keyword_from_target(target) -> int:
	var removable_keywords: Array[int] = []

	for runtime in target.keyword_runtimes:
		var keyword: int = runtime.keyword
		if is_attack_keyword(keyword):
			removable_keywords.append(keyword)

	if removable_keywords.is_empty():
		return keywords.NONE

	var removed_keyword: int = removable_keywords.pick_random()
	remove_keyword_from_target(target, removed_keyword)
	return removed_keyword

# 判断目标是否获得护持稳固联动状态
static func has_protection_stable_synergy(target):
	return has_keyword_runtime(target, keywords.PROTECTION_STABLE_SYNERGY)

# 获取关键词默认要持续几次“施放者行动结束”
static func get_owner_turn_end_duration(keyword):
	if not keywords_info.has(keyword):
		return 0
	if not keywords_info[keyword].has("owner_turn_end_duration"):
		return 0
	return keywords_info[keyword]["owner_turn_end_duration"]
	
# 在目标身上的 keyword_runtimes 中查找指定关键词的运行时实例
static func find_keyword_runtime(target, keyword):
	for runtime in target.keyword_runtimes:
		if runtime.keyword == keyword:
			return runtime
	return null

# 从目标的 keyword_runtimes 中移除指定关键词的运行时实例
static func remove_keyword_runtime(target, keyword):
	for runtime in target.keyword_runtimes.duplicate():
		if runtime.keyword == keyword:
			target.keyword_runtimes.erase(runtime)


static func upsert_keyword_runtime(target, keyword, caster, duration):
	var runtime = find_keyword_runtime(target, keyword)
	
	if runtime != null:
		runtime.caster_index = caster.index
		runtime.remaining_owner_turn_ends = duration
	else:
		var new_runtime = KeywordRuntime.new()
		new_runtime.keyword = keyword
		new_runtime.caster_index = caster.index
		new_runtime.remaining_owner_turn_ends = duration
		target.keyword_runtimes.append(new_runtime)

# 从 keyword_runtimes 提取出纯关键词编号数组
static func get_keywords_from_runtimes(keyword_runtimes):
	var result = []
	
	for runtime in keyword_runtimes:
		result.append(runtime.keyword)
	
	return result

# 判断目标当前是否持有指定关键词
static func has_keyword_runtime(target, keyword):
	return find_keyword_runtime(target, keyword) != null

# 从目标身上移除一个关键词
static func remove_keyword_from_target(target, keyword):
	target.states.erase(keyword)
	remove_keyword_runtime(target, keyword)

# 把一个关键词设置到目标身上
static func set_keyword_on_target(target, keyword, caster):
	var duration = get_owner_turn_end_duration(keyword)
	
	if not target.states.has(keyword):
		target.states.append(keyword)
	
	upsert_keyword_runtime(target, keyword, caster, duration)

# 获取关键词的调试显示名
static func get_keyword_name(keyword):
	if not keywords_info.has(keyword):
		return str(keyword)
	return "%s(%d)" % [keywords_info[keyword]["name"], keyword]
