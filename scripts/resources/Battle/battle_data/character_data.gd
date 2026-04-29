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


## 角色在战斗中的视觉表现
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

## 属性
# 体质
@export var constitution: int  = 1
# 力量
@export var strength: int = 1
# 耐力
@export var stamina: int = 1
# 智力
@export var intelligence: int = 1
# 敏捷
@export var agility: int = 1
# 幸运
@export var luck: int = 1

## 战斗信息
var character_battle: CharacterDataBattle
## 状态信息
var character_status: Dictionary[StringName,CharacterDataStatus] = {}
## 技能信息
var character_weapon: WeaponData
