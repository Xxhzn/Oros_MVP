#枚举所有关键词
enum keywords {
	NONE,
	PIERCE,
	STAGGER,
	PROTECTION,
	STABLE
}

#将每个关键词的名字，类型，效果，触发规则和失效规则都用字典的方式存起来
var keywords_info : Dictionary = {
	keywords.NONE : {
		"name" : "无",
		"type" : "无",
		"effect" : "无效果",
		"trigger_rule" : "无",
		"expire_rule" : "无"
	},
	keywords.PIERCE : {
		"name" : "穿刺",
		"type" : "进攻型",
		"effect" : "目标受到的伤害提高10%",
		"trigger_rule" : "持续生效，无单独触发时机",
		"expire_rule" : "目标下一个回合行动开始时"
	},
	keywords.STAGGER : {
		"name" : "震荡",
		"type" : "进攻型",
		"effect" : "目标造成的伤害降低30%",
		"trigger_rule" : "持续生效，无单独触发时机",
		"expire_rule" : "目标下一个回合行动开始时"
	},
	keywords.PROTECTION : {
		"name" : "护持",
		"type" : "防御型",
		"effect" : "目标受到的伤害降低30%",
		"trigger_rule" : "持续生效，无单独触发时机",
		"expire_rule" : "目标下一个回合行动开始时"
	},
	keywords.STABLE : {
		"name" : "稳固",
		"type" : "防御型",
		"effect" : "目标回合结束时恢复其10%的血量",
		"trigger_rule" : "目标回合结束时",
		"expire_rule" : "目标下一个回合行动开始时"
	}
}

#关键词的联动信息
var keywords_synergy_info:Dictionary = {
	"PIERCE_STAGGER" : {
		"type" : "进攻型",
		"effect" : "目标受到的伤害提高20%；且目标行动轮次在本回合延后一个单位",
		"trigger_rule" : "【穿刺】和【震荡】同时出现在目标身上时",
		"expire_rule" : "目标下一个回合行动开始时",
		"remove_old" : true
	},
	"PROTECTION_STABLE" : {
		"type" : "防御型",
		"effect" : "目标不会因受到伤害而被附加新的进攻型关键词",
		"trigger_rule" : "【护持】和【稳固】同时出现在目标身上时",
		"expire_rule" : "目标下一个回合行动开始时",
		"remove_old" : true
	}
}

func get_keyword_info(keyword):
	return keywords_info[keyword]

var current_keyword = keywords.STAGGER
var current_info = keywords_info[current_keyword]
var current_type = current_info["type"]
