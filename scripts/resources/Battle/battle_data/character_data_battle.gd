extends Resource
class_name CharacterDataBattle 

## 战斗属性
@export_category("战斗属性")
# 最大HP  由基础属性中的体质计算得来
@export var max_hp: int = 100
# 当前HP
@export var hp: int = 100
# 物理攻击力  由基础属性中的力量计算得来
@export var phys_atk = 1
# 魔法攻击力  由基础属性中的智力计算得来
@export var mag_atk = 1
# 物理防御  由基础属性中的耐力计算得来
@export var phys_def: int = 1
# 魔法防御  由基础属性中的耐力计算得来
@export var mag_def: int = 1
# 速度  由基础属性中的敏捷计算得来
@export var speed: int = 50
# 暴击  由基础属性中的幸运计算得来
@export var crit_rate: int = 1

## 战斗状态
@export_category("战斗状态")
# 是否死亡
@export var is_died: bool = false
# 本回合是否已行动
@export var acted: bool = false  
# 是否可操作
@export var is_controllable: bool = true  
