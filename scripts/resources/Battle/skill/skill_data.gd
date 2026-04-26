extends Resource
class_name SkillData

# 技能索引
@export var skill_id: StringName = ""
# 技能名称
@export var skill_name: StringName = ""
# 技能描述
@export_multiline var description: String = ""
# 技能标签
@export var tag_type: BattleEnum.TagType = BattleEnum.TagType.NORMAL
# 目标类型
@export var target_type: BattleEnum.TargetType = BattleEnum.TargetType.ENEMY_SINGLE
# 启动时间
@export var start_up_tu: int = 0
# 恢复时间
@export var recovery_tu: int = 0
# 技能倍率
@export var dmg_rate: float = 0.0
# 基础BP值
@export var base_break: int = 0
# 基础打断值
@export var base_interrupt: int = 0
# 是否可被打断
@export var can_be_interrupt: bool = false
# 被打断需要的打断值
@export var int_thres: int = 0
# 战势值消耗
@export var mor_cost: int = 0
# 技能范围
@export var range_type: BattleEnum.RangeType = BattleEnum.RangeType.MELEE
# 最大目标数
@export var max_targets: int = 1  
# 技能效果
@export var effects: Array[StringName] = []  
# 应用概率
@export var skill_apply_chance: float = 1.0 
# 时间节点位移
@export var node_move: int = 1
# 是否可以暴击
@export var can_crit: bool = false
# 是否有命中概率
@export var can_miss: bool = false
# 生命值消耗
@export var hp_cost: int = 0  
# 技能攻击次数
@export var attack_count : int

# 行动优先级
@export var priority: int = 0 
# 学习等级要求
@export var level_requirement: int = 1 
# 前置技能要求
@export var required_skills: Array[StringName] = []  
# 解锁消耗
@export var unlock_cost: int = 0  

@export_group("视觉与音效 (可选)")
@export var icon: Texture2D = null 								## 技能图标
@export var cast_animation: StringName = "" 					## 施法动画名 (如果角色动画器中有)
@export var pre_cast_delay: float = 0.2							## 释放前延迟
@export var post_cast_delay: float = 0.0						## 释放后延迟

# 未来可扩展其他视觉和音效选项
# @export var vfx_scene: PackedScene # 技能特效场景
# @export var sfx: AudioStream # 技能音效

## 获得技能完整描述
func get_full_description() -> String:
	var desc = ""
	return desc.strip_edges()
	
	
	
	
	
	
	
	
