extends Resource
class_name CharacterData 

## 角色基本信息
@export_category("基本信息")
# 角色编号索引
@export var index: StringName = ""
# 角色名
@export var display_name: String = "未命名角色"	
# 角色资源路径
@export var texture_path: String = ""
# 角色描述
@export_multiline var description: String = ""

## 角色视觉表现
@export_group("视觉表现")
# 角色动画库
@export var animation_library : AnimationLibrary		
# 角色偏移
@export var sprite_offset : Vector2 = Vector2.ZERO		
# 角色图标
@export var icon : Texture2D				

## 敌人ai行为树
#@export var enemy_ia_behavior:EnemyRuleAI = EnemyRuleAI.new()
# 是否为玩家 true=玩家，false=敌人
@export var is_player: bool = true  

## 战斗属性
@export_category("战斗属性")
# 最大HP
@export var max_hp: int = 100
# 当前HP
@export var hp: int = 100
# 攻击力
@export var dmg: int = 10
# 速度
@export var speed: int = 50

## 战斗状态
@export_category("战斗状态")
# 是否死亡
@export var is_died: bool = false
# 本回合是否已行动
@export var acted: bool = false  
# 是否可操作
@export var is_controllable: bool = true  

## 技能和装备
@export_category("技能装备")
# 器灵id
@export var weapon_id: StringName = ""
# 器灵技能组	技能ID -> 技能数据
var abilities: Dictionary[StringName,SkillData] = {} 
# 当前状态效果
var states: Array = [] 
