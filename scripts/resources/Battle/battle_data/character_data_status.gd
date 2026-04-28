extends Resource
class_name CharacterDataStatus

## 状态数据
# 状态ID
@export var status_id: StringName = ""
# 状态名
@export var status_name: StringName = ""
# 状态效果
@export var status_type: BattleEnum.EffectType = BattleEnum.EffectType.DAMAGE
# 影响的属性
@export var attribute: String = "sta" 
# 数值
@export var value: float = 0.3
# 数值类型
@export var value_type: BattleEnum.ValueType = BattleEnum.ValueType.FIXED
# 持续时间
@export var duration: int = 0
# 最大叠加层数
@export var max_stacks: int = 1
# 应用概率
@export var apply_chance: float = 1.0 
# 是否死亡后移除
@export var remove_on_death: bool = true
# 状态图标
@export var icon: Texture2D
# 状态描述
@export_multiline var description: String = ""
