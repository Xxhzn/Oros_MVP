extends Node
class_name Util

static func safe_get(data, key, default_value = null):
	if typeof(data) == TYPE_DICTIONARY and data.has(key):
		return data[key]
	return default_value

# 四种类型安全的获取函数
static func get_string(data, key, default_value = "") -> String:
	var value = safe_get(data, key, default_value)
	return str(value) if value != null else default_value

static func get_int(data, key, default_value = 0) -> int:
	var value = safe_get(data, key, default_value)
	return int(value) if typeof(value) in [TYPE_INT, TYPE_FLOAT, TYPE_STRING] else default_value

static func get_float(data, key, default_value = 0.0) -> float:
	var value = safe_get(data, key, default_value)
	return float(value) if typeof(value) in [TYPE_INT, TYPE_FLOAT, TYPE_STRING] else default_value

static func get_bool(data, key, default_value = false) -> bool:
	var value = safe_get(data, key, default_value)
	return bool(value) if typeof(value) in [TYPE_BOOL, TYPE_INT, TYPE_STRING] else default_value
	
	
func load_file(file_path: String):
	var file = FileAccess.open(file_path,FileAccess.READ)
	if not file:
		print("加载配置文件: %s 失败" % file_path) 
		return null
	
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_error = json.parse(content)
	if parse_error != OK:
		print("JSON解析错误： %s（第%d行）" %[
			json.get_error_message(),
			json.get_error_line()
		])
		return null
	
	return json.data
