extends RefCounted
class_name EchoSystem

# 上一回合最后一次“非回声动作”记录
var previous_round_last_non_echo_action: Dictionary = {}

# 当前回合进行中，最新的一条“非回声动作候选记录”
var current_round_last_non_echo_action_candidate: Dictionary = {}

# 开始一场新战斗时，清空所有回声记录，避免上一场战斗的数据串进来
func reset_for_battle() -> void:
	previous_round_last_non_echo_action = {}
	current_round_last_non_echo_action_candidate = {}

# 每个新回合开始时，清空“当前回合最后一次非回声动作候选”
func begin_round() -> void:
	current_round_last_non_echo_action_candidate = {}

# 创建一条动作记录
func create_action_record(
	caster: Battle_Character,
	target: Battle_Character,
	ability: abilities_data,
	is_echo_action: bool
) -> Dictionary:
	return {
		"is_echo_action": is_echo_action,
		"caster_index": caster.index,
		"target_index": target.index,
		"ability_name": ability.displayname,
		"ability_keyword": ability.status,
		"ability_target_is_self": ability.target,
		"ability_base_damage": ability.dmg,
		"ability_attack_count": ability.attackCount,
	}

# 保存本回合候选记录
func commit_action_record(action_record: Dictionary) -> void:
	if action_record.get("is_echo_action", false):
		return

	current_round_last_non_echo_action_candidate = action_record.duplicate(true)

# 结束当前回合
func end_round() -> void:
	if current_round_last_non_echo_action_candidate.is_empty():
		previous_round_last_non_echo_action = {}
	else:
		previous_round_last_non_echo_action = current_round_last_non_echo_action_candidate.duplicate(true)

	current_round_last_non_echo_action_candidate = {}

# 判断能否插入回声
func can_insert_echo(fragment_count: int) -> bool:
	return fragment_count > 0 and not previous_round_last_non_echo_action.is_empty()

# 读取上一回合记录
func get_previous_round_action() -> Dictionary:
	return previous_round_last_non_echo_action.duplicate(true)
