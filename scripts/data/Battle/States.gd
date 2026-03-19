class_name States

#枚举所有关键词和联动效果
enum keywords {
	NONE,
	PIERCE,
	STAGGER,
	PROTECTION,
	STABLE,
	PIERCE_STAGGER_SYNERGY,
	PROTECTION_STABLE_SYNERGY
}

#将每个关键词和联动状态的名字，类型，效果，触发规则和失效规则都用字典的方式存起来
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
		"expire_rule" : "目标下一个回合行动开始时",
		"damage_taken_rate" : 0.1,
		"damage_dealt_rate" : 0.0,
		"expire_on_turn_start" : true
	},
	keywords.STAGGER : {
		"name" : "震荡",
		"type" : "进攻型",
		"effect" : "目标造成的伤害降低30%",
		"trigger_rule" : "持续生效，无单独触发时机",
		"expire_rule" : "目标下一个回合行动开始时",
		"damage_taken_rate" : 0.0,
		"damage_dealt_rate" : -0.3,
		"expire_on_turn_start" : true
	},
	keywords.PROTECTION : {
		"name" : "护持",
		"type" : "防御型",
		"effect" : "目标受到的伤害降低30%",
		"trigger_rule" : "持续生效，无单独触发时机",
		"expire_rule" : "目标下一个回合行动开始时",
		"damage_taken_rate" : -0.3,
		"damage_dealt_rate" : 0.0,
		"expire_on_turn_start" : true
	},
	keywords.STABLE : {
		"name" : "稳固",
		"type" : "防御型",
		"effect" : "目标回合结束时恢复其10%的血量",
		"trigger_rule" : "目标回合结束时",
		"expire_rule" : "目标下一个回合行动开始时",
		"damage_taken_rate" : 0.0,
		"damage_dealt_rate" : 0.0,
		"expire_on_turn_start" : true
	},
	keywords.PIERCE_STAGGER_SYNERGY : {
		"name" : "穿刺震荡联动",
		"type" : "进攻型",
		"effect" : "目标受到的伤害提高20%；且目标行动轮次在本回合延后一个单位",
		"trigger_rule" : "由【穿刺】和【震荡】联动触发",
		"expire_rule" : "目标下一个回合行动开始时",
		"damage_taken_rate" : 0.2,
		"damage_dealt_rate" : 0.0,
		"expire_on_turn_start" : true
	},
	keywords.PROTECTION_STABLE_SYNERGY : {
		"name" : "护持稳固联动",
		"type" : "防御型",
		"effect" : "目标不会因受到伤害而被附加新的进攻型关键词",
		"trigger_rule" : "由【护持】和【稳固】联动触发",
		"expire_rule" : "目标下一个回合行动开始时",
		"damage_taken_rate" : 0.0,
		"damage_dealt_rate" : 0.0,
		"expire_on_turn_start" : true
	}
}

#关键词的联动信息
static var keywords_synergy_info:Dictionary = {
	"PIERCE_STAGGER" : {
		"type" : "进攻型",
		"effect" : "目标受到的伤害提高20%；且目标行动轮次在本回合延后一个单位",
		"trigger_rule" : "【穿刺】和【震荡】同时出现在目标身上时",
		"expire_rule" : "目标下一个回合行动开始时",
		"remove_old" : true,
		"damage_taken_rate" : 0.2,
		"result_state" : keywords.PIERCE_STAGGER_SYNERGY,
		"delay_current_turn_once" : true
	},
	"PROTECTION_STABLE" : {
		"type" : "防御型",
		"effect" : "目标不会因受到伤害而被附加新的进攻型关键词",
		"trigger_rule" : "【护持】和【稳固】同时出现在目标身上时",
		"expire_rule" : "目标下一个回合行动开始时",
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
static func apply_ability_keyword(target, ability_state):
	if not target.died and ability_state != States.keywords.NONE:
		if has_protection_stable_synergy(target) and is_attack_keyword(ability_state):
			return ""
		
		for current_state in target.states.duplicate():
			var synergy_key = get_synergy_key(current_state, ability_state)
			if synergy_key != "":
				var synergy_info = keywords_synergy_info[synergy_key]
				var remove_old = synergy_info["remove_old"]
				
				if remove_old == true:
					target.states.erase(current_state)
					
				var result_state = synergy_info["result_state"]
				if not target.states.has(result_state):
					target.states.append(result_state)
				return synergy_key

		if not target.states.has(ability_state):
			target.states.append(ability_state)
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

#判断该关键词是否为进攻型
static func is_attack_keyword(keyword):
	if not keywords_info.has(keyword):
		return false
	
	return keywords_info[keyword]["type"] == "进攻型"

# 判断目标是否获得护持稳固联动状态
static func has_protection_stable_synergy(target):
	return target.states.has(keywords.PROTECTION_STABLE_SYNERGY)

# 判断关键词是否在行动开始时失效
static func expire_on_turn_start(keyword):
	if not keywords_info.has(keyword):
		return false
	
	return keywords_info[keyword]["expire_on_turn_start"] == true
