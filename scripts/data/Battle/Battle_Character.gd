
class_name Battle_Character

# 当前角色发生变化
signal on_Change
signal on_hit

# 角色索引
var index

# 显示名称
var display_name:String

# 角色贴图
var texture_path:String:
	get:
		return texture_path
	set(texturePath):
		if texturePath != "":
			texture_path = texturePath
		else:
			texture_path = "res://art/sprite/prototype_player.png"
	
# 角色最大生命值
var max_hp: int = 0

# 角色血量
var hp:int:
	get:
		return hp
	set(value):
		hp = value
		
# 角色伤害
var dmg:int:
	get:
		return dmg
	set(value):
		dmg = value
		
# 角色速度
var speed:int:
	get:
		return speed
	set(value):
		speed = value

# 是否死亡
var died:bool = false

# 是否行动
var act:bool = false

# 是敌人还是玩家(true为玩家，false为敌人，不可操作)
var control:bool = true

# 状态数组
var states:Array = []

# 关键词运行时实例列表
var keyword_runtimes: Array[KeywordRuntime] = []

# 运行时防御效果
var shield_hp: int = 0
var shield_caster_index: int = -1
var shield_remaining_owner_turn_ends: int = 0

func add_shield(amount: int) -> void:
	if amount <= 0:
		return
	shield_hp += amount

func clear_shield() -> void:
	shield_hp = 0
	shield_caster_index = -1
	shield_remaining_owner_turn_ends = 0

func refresh_shield_runtime(caster_index: int, duration: int) -> void:
	shield_caster_index = caster_index
	shield_remaining_owner_turn_ends = duration

func apply_damage_to_shield_and_hp(amount: int) -> int:
	if amount <= 0:
		return 0

	var remaining_damage = amount

	if shield_hp > 0:
		var absorbed_by_shield = min(shield_hp, remaining_damage)
		shield_hp -= absorbed_by_shield
		remaining_damage -= absorbed_by_shield

	hp -= remaining_damage
	if hp < 0:
		hp = 0

	return remaining_damage

# 玩家武器(只有主角艾登拥有，后期要每个角色都要单独起类来继承Battle_Character)
var weapId:int = 0

# 角色技能
var abilities:Dictionary[int,abilities_data] = {}
