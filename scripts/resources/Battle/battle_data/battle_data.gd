extends Resource
class_name BattleData 

# 常量id
var const_key: StringName = ""
# 常量名
var const_name: String = ""
# 数值类型
var value_type: String = ""
# 值
var value
# 单位
var unit: String = ""
# 常量分类
var category: String = ""
# 常量描述
var desc: String = ""

func from_dict(data: Dictionary) -> BattleData:
	var battle_data = BattleData.new()
	battle_data.const_key = Util.safe_get(data, "const_key", "")
	battle_data.const_name = Util.safe_get(data, "const_name", "")
	battle_data.value_type = Util.safe_get(data, "value_type", "")
	battle_data.value = Util.safe_get(data, "value", "")
	battle_data.unit = Util.safe_get(data, "unit", "")
	battle_data.category = Util.safe_get(data, "category", "")
	battle_data.desc = Util.safe_get(data, "note", "")
	return battle_data 
