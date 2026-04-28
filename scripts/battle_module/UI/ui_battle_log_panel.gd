extends PanelContainer

class_name UIBattleLogPanel

var log_entries: Array[String] = []
var log_entry_types: Array[String] = []

@onready var debug_log_label: RichTextLabel = $DebugLogLabel

func _ready() -> void:
	EventManager.subscribe(UIBattleEventNames.LOG_APPEND, _on_log_append)
	EventManager.subscribe(UIBattleEventNames.LOG_CLEAR, _on_log_clear)
	_update_debug_text()

func _exit_tree() -> void:
	EventManager.unsubscribe(UIBattleEventNames.LOG_APPEND, _on_log_append)
	EventManager.unsubscribe(UIBattleEventNames.LOG_CLEAR, _on_log_clear)

func append_log(text: String, log_type: String = "") -> void:
	log_entries.append(text)
	log_entry_types.append(log_type)
	_update_debug_text()
	call_deferred("_scroll_to_latest")

# 追加“轮到谁行动”的日志。
func append_turn_start_log(unit_name: String) -> void:
	append_log("轮到 %s 行动。" % unit_name)

# 追加固定格式的技能施放日志。
func append_skill_cast_log(source_name: String, target_name: String, skill_name: String) -> void:
	append_log("%s 对 %s 施放了“%s”。" % [source_name, target_name, skill_name])

# 追加固定格式的伤害日志。
func append_damage_log(source_name: String, target_name: String, damage: int) -> void:
	append_log("%s 对 %s 造成了 %d 点伤害！" % [source_name, target_name, damage], UIBattleEventNames.LOG_TYPE_DAMAGE)

# 追加固定格式的死亡日志。
func append_death_log(target_name: String) -> void:
	append_log("%s 已死亡！" % target_name, UIBattleEventNames.LOG_TYPE_DEATH)

# 追加固定格式的治疗日志。
func append_heal_log(target_name: String, heal_value: int) -> void:
	append_log("%s 恢复了 %d 点生命。" % [target_name, heal_value])

# 追加固定格式的状态获得日志。
func append_status_gain_log(target_name: String, status_name: String, turns: int) -> void:
	append_log("%s 获得了“%s”，持续 %d 回合。" % [target_name, status_name, turns])

# 追加固定格式的状态移除日志。
func append_status_remove_log(target_name: String, status_name: String) -> void:
	append_log("%s 的“%s”消失了。" % [target_name, status_name])

# 追加固定格式的护盾获得日志。
func append_shield_gain_log(target_name: String, shield_value: int) -> void:
	append_log("%s 获得了 %d 点护盾。" % [target_name, shield_value])

# 追加固定格式的联动触发日志。
func append_synergy_trigger_log(synergy_name: String) -> void:
	append_log("触发联动：“%s”。" % synergy_name)

# 追加固定格式的回声碎片获得日志。
func append_echo_gain_log(amount: int) -> void:
	append_log("获得了 %d 点回声碎片。" % amount)

# 追加固定格式的回声碎片消耗日志。
func append_echo_use_log(amount: int) -> void:
	append_log("消耗了 %d 点回声碎片。" % amount)

func clear_logs() -> void:
	log_entries.clear()
	log_entry_types.clear()
	_update_debug_text()
	call_deferred("_scroll_to_latest")

# 优先处理结构化日志数据，兼容旧的纯文本追加。
func _on_log_append(payload: Dictionary) -> void:
	var log_key := str(payload.get("log_key", ""))

	match log_key:
		UIBattleEventNames.LOG_KEY_TURN_START:
			if payload.has("unit_name"):
				append_turn_start_log(str(payload["unit_name"]))
				return

		UIBattleEventNames.LOG_KEY_SKILL_CAST:
			if payload.has("source_name") and payload.has("target_name") and payload.has("skill_name"):
				append_skill_cast_log(
					str(payload["source_name"]),
					str(payload["target_name"]),
					str(payload["skill_name"])
				)
				return

		UIBattleEventNames.LOG_KEY_DAMAGE:
			if payload.has("source_name") and payload.has("target_name") and payload.has("damage"):
				append_damage_log(
					str(payload["source_name"]),
					str(payload["target_name"]),
					int(payload["damage"])
				)
				return

		UIBattleEventNames.LOG_KEY_DEATH:
			if payload.has("target_name"):
				append_death_log(str(payload["target_name"]))
				return
		UIBattleEventNames.LOG_KEY_HEAL:
			if payload.has("target_name") and payload.has("heal_value"):
				append_heal_log(
					str(payload["target_name"]),
					int(payload["heal_value"])
				)
				return

		UIBattleEventNames.LOG_KEY_STATUS_GAIN:
			if payload.has("target_name") and payload.has("status_name") and payload.has("turns"):
				append_status_gain_log(
					str(payload["target_name"]),
					str(payload["status_name"]),
					int(payload["turns"])
				)
				return

		UIBattleEventNames.LOG_KEY_STATUS_REMOVE:
			if payload.has("target_name") and payload.has("status_name"):
				append_status_remove_log(
					str(payload["target_name"]),
					str(payload["status_name"])
				)
				return

		UIBattleEventNames.LOG_KEY_SHIELD_GAIN:
			if payload.has("target_name") and payload.has("shield_value"):
				append_shield_gain_log(
					str(payload["target_name"]),
					int(payload["shield_value"])
				)
				return

		UIBattleEventNames.LOG_KEY_SYNERGY_TRIGGER:
			if payload.has("synergy_name"):
				append_synergy_trigger_log(str(payload["synergy_name"]))
				return

		UIBattleEventNames.LOG_KEY_ECHO_GAIN:
			if payload.has("amount"):
				append_echo_gain_log(int(payload["amount"]))
				return

		UIBattleEventNames.LOG_KEY_ECHO_USE:
			if payload.has("amount"):
				append_echo_use_log(int(payload["amount"]))
				return

	if payload.has("text"):
		append_log(str(payload["text"]), str(payload.get("log_type", "")))

func _on_log_clear(_payload: Dictionary) -> void:
	clear_logs()

# 临时用富文本颜色区分不同日志类型。
func _update_debug_text() -> void:
	var lines: Array[String] = []

	for i in range(log_entries.size()):
		var text := log_entries[i]
		var log_type := ""
		if i < log_entry_types.size():
			log_type = log_entry_types[i]

		lines.append("%s%s[/color]" % [_get_log_color_tag(log_type), text])

	debug_log_label.text = "\n".join(lines)

# 新日志出现后自动滚到最底部。
func _scroll_to_latest() -> void:
	var scroll_bar := debug_log_label.get_v_scroll_bar()
	if scroll_bar != null:
		scroll_bar.value = scroll_bar.max_value

# 重要结果用红色，其余日志先保持中性白色。
func _get_log_color_tag(log_type: String) -> String:
	match log_type:
		UIBattleEventNames.LOG_TYPE_DAMAGE:
			return "[color=#ff9a9a]"
		UIBattleEventNames.LOG_TYPE_DEATH:
			return "[color=#ff5c5c]"
		_:
			return "[color=#f2f2f2]"
