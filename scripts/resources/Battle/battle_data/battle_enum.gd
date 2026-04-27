extends Resource

class_name BattleEnum

# 效果类型枚举
enum EffectType {
	DAMAGE,     # 伤害
	HEAL,       # 治疗
	BUFF,       # 增益
	DEBUFF,     # 减益
	DOT,        # 持续伤害
	HOT,        # 持续治疗
	CLEANSE,    # 净化
	REVIVE,     # 复活
	KNOCKBACK,  # 击退
	STUN,       # 眩晕
	SILENCE,    # 沉默
	ROOT,       # 定身
}

# 值类型枚举
enum ValueType {
	FIXED,          # 固定值
	PERCENT,        # 百分比
	ATTRIBUTE_BASED # 基于属性
}

# 技能类型
enum SkillType { 
	ACTIVE,  # 主动技能，由玩家/AI选择施放
	PASSIVE  # 被动技能，在满足条件时自动生效
}

# 技能标签
enum TagType { 
	NORMAL,  	# 普攻
	FAST_LIGHT, # 快捷轻技能
	STD_LIGHT,	# 标准轻技能
	HEAVY,		# 重技能
	CHANT,		# 吟唱技能
}

# 目标类型
enum TargetType {
	NONE,                   # 无需目标 (例如自身buff)
	ENEMY_SINGLE,           # 敌方单体
	ENEMY_ALL,              # 敌方全体
	ALLY_SINGLE,            # 我方单体 (不含自己)
	ALLY_ALL,               # 我方全体 (不含自己)
	SELF,                   # 施法者自己
	ALLY_SINGLE_INC_SELF,   # 我方单体 (含自己)
	ALLY_ALL_INC_SELF,      # 我方全体 (含自己)
	ENEMY_RANDOM,           # 敌方随机
	ALLY_RANDOM,            # 我方随机 (不含自己)
	ALLY_RANDOM_INC_SELF    # 我方随机 (含自己)
}


# 技能范围
enum RangeType { 
	MELEE,  # 近战
	RANGE, 	# 远程
}
