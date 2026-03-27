extends PanelContainer

class_name UISkillSequencePopup
## 技能回声顺序弹窗
# 负责选择主技能与回声技能的施放顺序，并确认本次回声配置。

## 对外信号
# 选中某个施放顺序时发出。
signal order_selected(order_key: String)
# 点击确认后发出最终顺序结果。
signal order_confirmed(order_key: String)

## 子节点引用
# 主技能先于回声技能的顺序块。
@onready var main_then_echo_badge: ColorRect = $Content/LayoutRoot/OrderRow/MainThenEchoBadge
# 回声技能先于主技能的顺序块。
@onready var echo_then_main_badge: ColorRect = $Content/LayoutRoot/OrderRow/EchoThenMainBadge
# 确认按钮块。
@onready var confirm_badge: ColorRect = $Content/LayoutRoot/ConfirmBadge

## 运行时状态
# 当前已选中的施放顺序。
var selected_order: String = ""

#region --- 生命周期与输入 ---
# 初始化弹窗默认状态并绑定顺序输入。
func _ready() -> void:
	visible = false

	# 点击两个顺序块时切换当前顺序选择。
	main_then_echo_badge.gui_input.connect(func(event: InputEvent) -> void:
		_on_order_badge_gui_input(event, "main_then_echo")
	)
	echo_then_main_badge.gui_input.connect(func(event: InputEvent) -> void:
		_on_order_badge_gui_input(event, "echo_then_main")
	)
	confirm_badge.gui_input.connect(func(event: InputEvent) -> void:
		_on_confirm_badge_gui_input(event)
	)

	_update_order_highlight()

# 设置当前选中的施放顺序。
func set_selected_order(order_key: String) -> void:
	selected_order = order_key
	_update_order_highlight()
	order_selected.emit(order_key)

# 处理顺序块点击。
func _on_order_badge_gui_input(event: InputEvent, order_key: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		set_selected_order(order_key)

# 处理确认按钮点击。
func _on_confirm_badge_gui_input(event: InputEvent) -> void:
	if selected_order == "":
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		order_confirmed.emit(selected_order)
#endregion

#region --- 视觉刷新 ---
# 刷新顺序选项和确认按钮高亮。
func _update_order_highlight() -> void:
	if main_then_echo_badge != null:
		main_then_echo_badge.color = Color(0.36, 0.56, 0.86, 1.0) if selected_order == "main_then_echo" else Color(0.28, 0.42, 0.66, 1.0)

	if echo_then_main_badge != null:
		echo_then_main_badge.color = Color(0.36, 0.56, 0.86, 1.0) if selected_order == "echo_then_main" else Color(0.28, 0.42, 0.66, 1.0)

	if confirm_badge != null:
		confirm_badge.color = Color(0.82, 0.58, 0.24, 1.0) if selected_order != "" else Color(0.40, 0.40, 0.40, 1.0)
#endregion
