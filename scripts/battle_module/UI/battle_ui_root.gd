extends Control

class_name UIBattleRoot
## 战斗 UI 根模块
# 负责统一接收战斗 UI 事件，并管理菜单、玩家 HUD、目标选择层和状态层。

## 悬浮状态栈资源
# 用于按单位动态创建关键词状态列。
const STATUS_STACK_SCENE := preload("res://scenes/battle/ui/status_stack.tscn")

## 运行时状态
# 记录当前场上单位对应的悬浮状态栈实例。
var status_stack_map: Dictionary = {}

## 子模块引用
# 战斗操作菜单。
@onready var battle_menu: UIBattleMenu = $FloatingCommandLayer/BattleMenu
# 左下角玩家状态栏。
@onready var player_status_panel: UIUnitStatusPanel = $PlayerHudArea/PlayerStatusPanel
# 单位悬浮状态层。
@onready var status_layer: Control = $StatusLayer
# 目标选择覆盖层。
@onready var target_select_overlay: UITargetSelectOverlay = $TargetSelectOverlay

#region --- 生命周期 ---
# 进入场景时统一订阅战斗 UI 事件。
func _ready() -> void:
	EventManager.subscribe(UIBattleEventNames.UI_RESET, _on_ui_reset)
	EventManager.subscribe(UIBattleEventNames.MENU_SHOW, _on_menu_show)
	EventManager.subscribe(UIBattleEventNames.MENU_HIDE, _on_menu_hide)
	EventManager.subscribe(UIBattleEventNames.MENU_CLOSED, _on_menu_closed)
	EventManager.subscribe(UIBattleEventNames.PLAYER_HUD_SET, _on_player_hud_set)
	EventManager.subscribe(UIBattleEventNames.PLAYER_HUD_HIDE, _on_player_hud_hide)
	EventManager.subscribe(UIBattleEventNames.STATUS_STACK_SET, _on_status_stack_set)
	EventManager.subscribe(UIBattleEventNames.STATUS_STACK_REMOVE, _on_status_stack_remove)
	EventManager.subscribe(UIBattleEventNames.TARGET_OVERLAY_SHOW, _on_target_overlay_show)
	EventManager.subscribe(UIBattleEventNames.TARGET_OVERLAY_HIDE, _on_target_overlay_hide)

	hide_player_hud()

# 离开场景时取消订阅，避免残留回调。
func _exit_tree() -> void:
	EventManager.unsubscribe(UIBattleEventNames.UI_RESET, _on_ui_reset)
	EventManager.unsubscribe(UIBattleEventNames.MENU_SHOW, _on_menu_show)
	EventManager.unsubscribe(UIBattleEventNames.MENU_HIDE, _on_menu_hide)
	EventManager.unsubscribe(UIBattleEventNames.MENU_CLOSED, _on_menu_closed)
	EventManager.unsubscribe(UIBattleEventNames.PLAYER_HUD_SET, _on_player_hud_set)
	EventManager.unsubscribe(UIBattleEventNames.PLAYER_HUD_HIDE, _on_player_hud_hide)
	EventManager.unsubscribe(UIBattleEventNames.STATUS_STACK_SET, _on_status_stack_set)
	EventManager.unsubscribe(UIBattleEventNames.STATUS_STACK_REMOVE, _on_status_stack_remove)
	EventManager.unsubscribe(UIBattleEventNames.TARGET_OVERLAY_SHOW, _on_target_overlay_show)
	EventManager.unsubscribe(UIBattleEventNames.TARGET_OVERLAY_HIDE, _on_target_overlay_hide)

# 把战斗 UI 恢复到默认状态。
func reset_ui() -> void:
	battle_menu.hide()
	battle_menu.clear_menu_id()
	hide_player_hud()
	hide_target_overlay()
	clear_status_stacks()

	EventManager.push_event(UIBattleEventNames.TURN_ORDER_CLEAR, {})
	EventManager.push_event(UIBattleEventNames.LOG_CLEAR, {})

# 响应全局战斗 UI 重置事件。
func _on_ui_reset(_payload: Dictionary) -> void:
	reset_ui()
#endregion

#region --- 菜单控制 ---
# 响应菜单显示事件，并按 payload 配置菜单内容。
func _on_menu_show(payload: Dictionary) -> void:
	var title := ""
	if payload.has("title"):
		title = str(payload["title"])
	var menu_id := ""
	if payload.has("menu_id"):
		menu_id = str(payload["menu_id"])

	var menu_mode := ""
	if payload.has("menu_mode"):
		menu_mode = str(payload["menu_mode"])

	var menu_context: Dictionary = {}
	if payload.has("menu_context"):
		menu_context = payload["menu_context"]

	battle_menu.set_menu_id(menu_id)
	battle_menu.set_menu_mode(menu_mode)
	battle_menu.set_menu_context(menu_context)
	battle_menu.set_menu_title(title)

	var close_on_select := true
	if payload.has("close_on_select"):
		close_on_select = bool(payload["close_on_select"])

	if payload.has("screen_position"):
		battle_menu.set_menu_position(payload["screen_position"])

	battle_menu.open()
	battle_menu.set_close_on_select(close_on_select)

	if payload.has("items"):
		battle_menu.set_menu_items(payload["items"])

	if payload.has("selected_item_id"):
		battle_menu.set_selected_item(str(payload["selected_item_id"]))

# 响应菜单隐藏事件，按 menu_id 收起当前菜单。
func _on_menu_hide(payload: Dictionary) -> void:
	if not payload.has("menu_id"):
		battle_menu.hide()
		battle_menu.clear_menu_id()
		return

	var menu_id = str(payload["menu_id"])
	if menu_id == battle_menu.current_menu_id:
		battle_menu.hide()
		battle_menu.clear_menu_id()

# 响应菜单关闭事件，并清理当前菜单状态。
func _on_menu_closed(payload: Dictionary) -> void:
	if not payload.has("menu_id"):
		battle_menu.hide()
		battle_menu.clear_menu_id()
		return

	var menu_id = str(payload["menu_id"])
	if menu_id == battle_menu.current_menu_id:
		battle_menu.hide()
		battle_menu.clear_menu_id()
#endregion

#region --- 状态栈 ---
# 确保指定单位拥有一个悬浮状态栈实例。
func ensure_status_stack(unit_id: int) -> UIStatusStack:
	if status_stack_map.has(unit_id):
		return status_stack_map[unit_id] as UIStatusStack

	var status_stack := STATUS_STACK_SCENE.instantiate() as UIStatusStack
	status_layer.add_child(status_stack)
	status_stack_map[unit_id] = status_stack
	return status_stack

# 设置指定单位的悬浮状态文字列表。
func set_unit_status_texts(unit_id: int, status_texts: Array[String]) -> void:
	var status_stack := ensure_status_stack(unit_id)
	status_stack.set_status_texts(status_texts)

# 设置指定单位悬浮状态栈的屏幕位置。
func set_status_stack_position(unit_id: int, screen_position: Vector2) -> void:
	var status_stack := ensure_status_stack(unit_id)
	status_stack.position = screen_position

# 移除指定单位的悬浮状态栈。
func remove_status_stack(unit_id: int) -> void:
	if not status_stack_map.has(unit_id):
		return

	var status_stack := status_stack_map[unit_id] as UIStatusStack
	status_stack_map.erase(unit_id)

	if status_stack != null:
		status_stack.queue_free()

# 清空所有动态创建的悬浮状态栈。
func clear_status_stacks() -> void:
	for unit_id in status_stack_map.keys():
		remove_status_stack(unit_id)
#endregion

#region --- 玩家HUD ---
# 设置左下角玩家状态栏数据。
func set_player_hud_data(unit_name: String, current_hp: int, max_hp: int, shield_value: int) -> void:
	player_status_panel.visible = true
	player_status_panel.set_unit_name(unit_name)
	player_status_panel.set_hp(current_hp, max_hp)
	player_status_panel.set_shield(shield_value)

# 隐藏左下角玩家状态栏。
func hide_player_hud() -> void:
	player_status_panel.visible = false

# 响应玩家状态栏刷新事件。
func _on_player_hud_set(payload: Dictionary) -> void:
	if not payload.has("unit_name") or not payload.has("current_hp") or not payload.has("max_hp"):
		return

	set_player_hud_data(
		str(payload["unit_name"]),
		int(payload["current_hp"]),
		int(payload["max_hp"]),
		int(payload.get("shield_value", 0))
	)

# 响应玩家状态栏隐藏事件。
func _on_player_hud_hide(_payload: Dictionary) -> void:
	hide_player_hud()
#endregion

#region --- 目标选择 ---
# 显示目标选择覆盖层。
func show_target_overlay(
	hint_text: String = "请选择目标",
	source_unit_id: int = -1,
	action_context: Dictionary = {},
	allow_cancel: bool = true,
	candidate_target_ids: Array = []
) -> void:
	battle_menu.hide()
	battle_menu.clear_menu_id()

	target_select_overlay.show_overlay(
		hint_text,
		source_unit_id,
		action_context,
		allow_cancel,
		candidate_target_ids
	)

# 隐藏目标选择覆盖层。
func hide_target_overlay() -> void:
	target_select_overlay.hide_overlay()

# 显示目标选择阶段。
func show_target_select_phase(
	source_unit_id: int,
	candidate_target_ids: Array,
	action_context: Dictionary,
	allow_cancel: bool = true,
	hint_text: String = "请选择目标"
) -> void:
	EventManager.push_event(UIBattleEventNames.TARGET_OVERLAY_SHOW, {
		UIBattleEventNames.TARGET_KEY_HINT_TEXT: hint_text,
		UIBattleEventNames.TARGET_KEY_SOURCE_UNIT_ID: source_unit_id,
		UIBattleEventNames.TARGET_KEY_CANDIDATE_IDS: candidate_target_ids,
		UIBattleEventNames.TARGET_KEY_ACTION_CONTEXT: action_context,
		UIBattleEventNames.TARGET_KEY_ALLOW_CANCEL: allow_cancel
	})

# 构建普通攻击路径的行动上下文。
func build_basic_attack_action_context(selected_spirit_id: String) -> Dictionary:
	return {
		UIBattleEventNames.ACTION_CONTEXT_SPIRIT_ID: selected_spirit_id,
		UIBattleEventNames.ACTION_CONTEXT_TOP_LEVEL_ITEM_ID: UIBattleEventNames.MENU_ITEM_BASIC_ATTACK,
		UIBattleEventNames.ACTION_CONTEXT_ABILITY_INDEX: -1,
		UIBattleEventNames.ACTION_CONTEXT_USE_ECHO: false,
		UIBattleEventNames.ACTION_CONTEXT_ORDER_KEY: "",
		UIBattleEventNames.ACTION_CONTEXT_IS_BASIC_ATTACK: true,
		UIBattleEventNames.ACTION_CONTEXT_RETURN_STAGE: UIBattleEventNames.ACTION_CONTEXT_RETURN_STAGE_TOP_LEVEL
	}

# 构建器灵技能路径的行动上下文。
func build_skill_action_context(
	selected_spirit_id: String,
	ability_index: int,
	use_echo: bool = false,
	order_key: String = ""
) -> Dictionary:
	return {
		UIBattleEventNames.ACTION_CONTEXT_SPIRIT_ID: selected_spirit_id,
		UIBattleEventNames.ACTION_CONTEXT_TOP_LEVEL_ITEM_ID: UIBattleEventNames.MENU_ITEM_SPIRIT_SKILL,
		UIBattleEventNames.ACTION_CONTEXT_ABILITY_INDEX: ability_index,
		UIBattleEventNames.ACTION_CONTEXT_USE_ECHO: use_echo,
		UIBattleEventNames.ACTION_CONTEXT_ORDER_KEY: order_key,
		UIBattleEventNames.ACTION_CONTEXT_IS_BASIC_ATTACK: false,
		UIBattleEventNames.ACTION_CONTEXT_RETURN_STAGE: UIBattleEventNames.ACTION_CONTEXT_RETURN_STAGE_SKILL_SELECT
	}

# 响应目标选择覆盖层显示事件。
func _on_target_overlay_show(payload: Dictionary) -> void:
	show_target_overlay(
		str(payload.get(UIBattleEventNames.TARGET_KEY_HINT_TEXT, "请选择目标")),
		int(payload.get(UIBattleEventNames.TARGET_KEY_SOURCE_UNIT_ID, -1)),
		payload.get(UIBattleEventNames.TARGET_KEY_ACTION_CONTEXT, {}),
		bool(payload.get(UIBattleEventNames.TARGET_KEY_ALLOW_CANCEL, true)),
		payload.get(UIBattleEventNames.TARGET_KEY_CANDIDATE_IDS, [])
	)

# 响应目标选择覆盖层隐藏事件。
func _on_target_overlay_hide(_payload: Dictionary) -> void:
	hide_target_overlay()
#endregion

#region --- 菜单接口 ---
# 显示器灵选择菜单。
func show_spirit_select_menu(items: Array, screen_position: Vector2, selected_spirit_id: String = "") -> void:
	EventManager.push_event(UIBattleEventNames.MENU_SHOW, {
		"menu_id": UIBattleEventNames.MENU_ID_SPIRIT_SELECT,
		"menu_mode": UIBattleEventNames.MENU_MODE_SPIRIT_SELECT,
		"title": "请选择要使用的器灵",
		"close_on_select": false,
		"screen_position": screen_position,
		"selected_item_id": selected_spirit_id,
		"items": items
	})

# 构建单个器灵选择菜单项。
func build_spirit_menu_item(spirit_id: String, display_name: String, disabled: bool = false) -> Dictionary:
	return {
		"id": spirit_id,
		"label": display_name,
		"disabled": disabled,
		"meta": {
			UIBattleEventNames.MENU_META_SPIRIT_ID: spirit_id
		}
	}

# 显示技能选择菜单。
func show_skill_select_menu(
	items: Array,
	screen_position: Vector2,
	selected_spirit_id: String,
	selected_ability_id: String = ""
) -> void:
	EventManager.push_event(UIBattleEventNames.MENU_SHOW, {
		"menu_id": UIBattleEventNames.MENU_ID_SKILL_SELECT,
		"menu_mode": UIBattleEventNames.MENU_MODE_SKILL_SELECT,
		"title": "请选择动作",
		"close_on_select": false,
		"screen_position": screen_position,
		"menu_context": {
			UIBattleEventNames.MENU_CONTEXT_SELECTED_SPIRIT_ID: selected_spirit_id
		},
		"selected_item_id": selected_ability_id,
		"items": items
	})

# 构建单个技能选择菜单项。
func build_skill_menu_item(
	ability_index: int,
	display_name: String,
	cooldown_text: String = "",
	keyword_text: String = "",
	slot_text: String = "",
	slot_state: String = "",
	disabled: bool = false
) -> Dictionary:
	return {
		"id": str(ability_index),
		"label": display_name,
		"cooldown_text": cooldown_text,
		"keyword_text": keyword_text,
		"item_kind": UIBattleEventNames.MENU_ITEM_KIND_SKILL,
		"slot_text": slot_text,
		"slot_state": slot_state,
		"disabled": disabled,
		"meta": {
			UIBattleEventNames.MENU_META_ABILITY_INDEX: ability_index
		}
	}

# 显示玩家行动一级菜单。
func show_top_level_select_menu(
	screen_position: Vector2,
	selected_spirit_id: String,
	selected_item_id: String = ""
) -> void:
	EventManager.push_event(UIBattleEventNames.MENU_SHOW, {
		"menu_id": UIBattleEventNames.MENU_ID_TOP_LEVEL_SELECT,
		"menu_mode": UIBattleEventNames.MENU_MODE_TOP_LEVEL_SELECT,
		"title": "请选择行动",
		"close_on_select": false,
		"screen_position": screen_position,
		"menu_context": {
			UIBattleEventNames.MENU_CONTEXT_SELECTED_SPIRIT_ID: selected_spirit_id
		},
		"selected_item_id": selected_item_id,
		"items": [
			{
				"id": UIBattleEventNames.MENU_ITEM_BASIC_ATTACK,
				"label": "普通攻击",
				"item_kind": UIBattleEventNames.MENU_ITEM_KIND_TOP_LEVEL
			},
			{
				"id": UIBattleEventNames.MENU_ITEM_SPIRIT_SKILL,
				"label": "器灵技能",
				"item_kind": UIBattleEventNames.MENU_ITEM_KIND_TOP_LEVEL
			},
			{
				"id": UIBattleEventNames.MENU_ITEM_ESCAPE,
				"label": "逃跑",
				"item_kind": UIBattleEventNames.MENU_ITEM_KIND_TOP_LEVEL
			}
		]
	})
#endregion

#region --- 状态事件 ---
# 响应单位悬浮状态栈刷新事件。
func _on_status_stack_set(payload: Dictionary) -> void:
	if not payload.has("unit_id") or not payload.has("screen_position") or not payload.has("status_texts"):
		return

	var unit_id := int(payload["unit_id"])
	var status_texts: Array[String] = []

	# 把事件里的普通数组转换成字符串数组。
	for item in payload["status_texts"]:
		status_texts.append(str(item))

	# 空状态列表时直接隐藏该单位的状态栈。
	if status_texts.is_empty():
		remove_status_stack(unit_id)
		return

	ensure_status_stack(unit_id).visible = true
	set_status_stack_position(unit_id, payload["screen_position"])
	set_unit_status_texts(unit_id, status_texts)

# 响应单位悬浮状态栈移除事件。
func _on_status_stack_remove(payload: Dictionary) -> void:
	if not payload.has("unit_id"):
		return

	remove_status_stack(int(payload["unit_id"]))
#endregion
