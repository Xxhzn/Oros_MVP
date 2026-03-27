extends Control

class_name UITargetSelectOverlay
## 目标选择覆盖层
# 负责显示目标选择提示，并在目标选择阶段处理取消输入。

## 子节点引用
# 目标选择阶段的提示文字。
@onready var hint_label: Label = $HintLabel

## 运行时状态
# 当前是否允许取消目标选择。
var allow_cancel: bool = true
# 当前发起行动的单位 ID。
var source_unit_id: int = -1
# 当前目标选择阶段对应的行动上下文。
var action_context: Dictionary = {}
var candidate_target_ids: Array = []

#region --- 生命周期与基础接口 ---
# 初始化覆盖层默认状态。
func _ready() -> void:
	hide()

# 设置目标选择提示文字。
func set_hint_text(text: String) -> void:
	hint_label.text = text

# 显示目标选择覆盖层。
func show_overlay(
	hint_text: String = "请选择目标",
	new_source_unit_id: int = -1,
	new_action_context: Dictionary = {},
	new_allow_cancel: bool = true,
	new_candidate_target_ids: Array = []
) -> void:
	set_hint_text(hint_text)
	source_unit_id = new_source_unit_id
	action_context = new_action_context.duplicate(true)
	allow_cancel = new_allow_cancel
	candidate_target_ids = new_candidate_target_ids.duplicate()
	show()

# 隐藏目标选择覆盖层并清空当前上下文。
func hide_overlay() -> void:
	source_unit_id = -1
	action_context.clear()
	allow_cancel = true
	candidate_target_ids.clear()
	hide()
#endregion

#region --- 取消输入 ---
# 在目标选择阶段监听取消输入，并对外发取消事件。
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if not allow_cancel:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var target_index := -1

		if event.keycode == KEY_1:
			target_index = 0
		elif event.keycode == KEY_2:
			target_index = 1
		elif event.keycode == KEY_3:
			target_index = 2

		if target_index >= 0 and target_index < candidate_target_ids.size():
			var selected_target_id := int(candidate_target_ids[target_index])
			var selected_source_unit_id := source_unit_id
			var selected_action_context := action_context.duplicate(true)

			hide_overlay()
			EventManager.push_event(UIBattleEventNames.TARGET_SELECTED, {
				UIBattleEventNames.TARGET_KEY_SOURCE_UNIT_ID: selected_source_unit_id,
				UIBattleEventNames.TARGET_KEY_TARGET_ID: selected_target_id,
				UIBattleEventNames.TARGET_KEY_ACTION_CONTEXT: selected_action_context
			})
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("ui_cancel"):
		var canceled_source_unit_id := source_unit_id
		var canceled_action_context := action_context.duplicate(true)
		var canceled_allow_cancel := allow_cancel

		hide_overlay()
		EventManager.push_event(UIBattleEventNames.TARGET_SELECTION_CANCELED, {
			UIBattleEventNames.TARGET_KEY_SOURCE_UNIT_ID: canceled_source_unit_id,
			UIBattleEventNames.TARGET_KEY_ACTION_CONTEXT: canceled_action_context,
			UIBattleEventNames.TARGET_KEY_ALLOW_CANCEL: canceled_allow_cancel
		})
		get_viewport().set_input_as_handled()
#endregion
