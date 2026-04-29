extends Resource

class_name WeaponData

enum WeaponType {
	NONE,		# 无 
	SWORD,  	# 剑
	DAGGER,  	# 匕首
	SCIMITAR,	# 弯刀
	SPEAR,		# 长矛
	TRIDENT,	# 三叉戟
	MACE,		# 狼牙棒
	SHIELD,		# 盾牌
	BOW,		# 弓
}

@export var weapon_id: StringName = &"new_weap" 				## 内部ID，用StringName效率略高
@export var weapon_name: String = "武器"       					## UI显示名称
@export var weapon_type: WeaponType = WeaponType.NONE			## 武器类型
@export_multiline var description: String = "武器描述..." 		## UI显示描述
@export var bonus_attr_list: Array[String] = []					## 器灵额外附加属性
@export var bonus_attr_curve: Array[String] = []				## 器灵额外增加属性的数值公式（待定数据类型）

@export_group("视觉与音效")
@export var icon: Texture2D = null 								## 武器图标
@export var cast_animation: StringName = "" 					## 施法动画名 (如果角色动画器中有)
@export var pre_cast_delay: float = 0.2							## 释放前延迟
@export var post_cast_delay: float = 0.0						## 释放后延迟

## 武器技能
var skills: Dictionary[StringName, SkillData] = {}
