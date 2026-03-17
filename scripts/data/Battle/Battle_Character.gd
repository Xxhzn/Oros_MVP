
class_name Battle_Character

# 当前角色发生变化
signal on_Change
signal on_hit

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

# 玩家武器(只有主角艾登拥有，后期要每个角色都要单独起类来继承Battle_Character)
var weapId:int = 0

# 角色技能
var ablities:Dictionary[int,ablities_data] = {}
