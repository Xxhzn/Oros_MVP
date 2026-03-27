extends Panel

class_name UIBattleMenu
## 战斗操作菜单
# 负责显示器灵选择、一级菜单、技能菜单，以及技能回声顺序弹窗的交互入口。

## 子节点引用
# 菜单项容器。
@onready var menu_item_root: VBoxContainer = $MenuItemRoot
# 菜单项模板。
@onready var battle_menu_item_template: Button = $MenuItemRoot/BattleMenuItemTemplate
# 菜单标题。
@onready var title: Label = $title
# 技能回声顺序弹窗。
@onready var skill_sequence_popup: UISkillSequencePopup = $SkillSequencePopup

## 兼容旧流程的完成信号
signal finished

## 运行时状态
# 当前已创建的菜单项实例。
var menu_items:Array[Button] = []
# 当前菜单实例 ID。
var current_menu_id: String = ""
# 点击菜单项后是否自动关闭。
var close_on_select: bool = true
# 当前菜单所属阶段模式。
var current_menu_mode: String = ""
# 当前高亮选中的菜单项 ID。
var selected_item_id: String = ""
# 菜单项 ID 到按钮实例的映射。
var menu_item_map: Dictionary = {}
# 当前菜单上下文数据。
var current_menu_context: Dictionary = {}
# 当前鼠标悬停的菜单项 ID。
var hovered_item_id: String = ""
# 当前顺序弹窗绑定的技能项 ID。
var popup_item_id: String = ""
# 当前顺序弹窗绑定的技能项元数据。
var popup_item_meta: Dictionary = {}
# 当前已插入回声的技能项 ID。
var echo_bound_item_id: String = ""
# 当前已确认的回声施放顺序。
var echo_bound_order_key: String = ""

#region --- 生命周期与基础状态 ---
# 初始化菜单模板和顺序弹窗。
func _ready() -> void:
	battle_menu_item_template.hide()
	title.hide()
	skill_sequence_popup.hide()
	skill_sequence_popup.order_confirmed.connect(_on_skill_sequence_popup_order_confirmed)

# 打开菜单并重置本轮菜单状态。
func open():
	for menu_item in menu_items:
		menu_item.queue_free()
		
	menu_items.clear()
	title.show()
	self.show()
	close_on_select = true
	current_menu_mode = ""
	selected_item_id = ""
	menu_item_map.clear()
	current_menu_context.clear()
	hovered_item_id = ""
	popup_item_id = ""
	popup_item_meta.clear()
	skill_sequence_popup.hide()
	echo_bound_item_id = ""
	echo_bound_order_key = ""

# 设置当前菜单实例 ID。
func set_menu_id(menu_id: String) -> void:
	current_menu_id = menu_id

# 清空当前菜单实例 ID。
func clear_menu_id() -> void:
	current_menu_id = ""

# 设置当前选中的菜单项。
func set_selected_item(item_id: String) -> void:
	selected_item_id = item_id
	_update_selected_state()

# 设置当前鼠标悬停的菜单项。
func set_hovered_item(item_id: String) -> void:
	hovered_item_id = item_id
	_update_selected_state()

# 设置当前菜单阶段模式。
func set_menu_mode(menu_mode: String) -> void:
	current_menu_mode = menu_mode

# 设置当前菜单上下文数据。
func set_menu_context(menu_context: Dictionary) -> void:
	current_menu_context = menu_context.duplicate(true)

# 设置点击选项后是否自动关闭菜单。
func set_close_on_select(value: bool) -> void:
	close_on_select = value

# 清空当前菜单阶段模式。
func clear_menu_mode() -> void:
	current_menu_mode = ""

# 清空当前菜单上下文数据。
func clear_menu_context() -> void:
	current_menu_context.clear()

# 设置菜单标题文本。
func set_menu_title(text: String) -> void:
	title.text = text

# 设置菜单在屏幕中的位置。
func set_menu_position(screen_position: Vector2) -> void:
	global_position = screen_position
#endregion

#region --- 菜单项构建与显示 ---
# 根据传入数据构建并显示当前菜单项列表。
func set_menu_items(items: Array) -> void:
	for item_data in items:
		var item_id = str(item_data.get("id", ""))
		var label = str(item_data.get("label", ""))
		var item_meta = item_data.get("meta", {})
		var disabled = bool(item_data.get("disabled", false))
		var cooldown_text = str(item_data.get("cooldown_text", ""))
		var keyword_text = str(item_data.get("keyword_text", ""))
		var slot_text = str(item_data.get("slot_text", item_data.get("suffix", "")))
		var slot_state = str(item_data.get("slot_state", ""))
		var item_kind = str(item_data.get("item_kind", ""))

		var menu_item := item(label, func():
			set_selected_item(item_id)

			EventManager.push_event(UIBattleEventNames.MENU_ITEM_SELECTED, {
				"menu_id": current_menu_id,
				"menu_mode": current_menu_mode,
				"menu_context": current_menu_context,
				"item_id": item_id,
				"item_meta": item_meta
			})


			if close_on_select:
				EventManager.push_event(UIBattleEventNames.MENU_CLOSED, {
					"menu_id": current_menu_id
				})
		)
		
		menu_item_map[item_id] = menu_item
		menu_item.set_meta("item_id", item_id)
		menu_item.set_meta("slot_text", slot_text)
		menu_item.set_meta("slot_state", slot_state)
		menu_item.set_meta("item_kind", item_kind)
		menu_item.set_meta("item_meta", item_meta)
		_set_item_main_text(menu_item, label)
		_set_item_detail_text(menu_item, cooldown_text, keyword_text)
		_set_item_suffix_text(menu_item, slot_text)

		if item_kind == UIBattleEventNames.MENU_ITEM_KIND_SKILL:
			menu_item.mouse_entered.connect(func():
				set_hovered_item(item_id)
			)
			menu_item.mouse_exited.connect(func():
				if hovered_item_id == item_id:
					set_hovered_item("")
			)

		menu_item.disabled = disabled
		_apply_item_colors(menu_item)

# 设置菜单项左侧主文本。
func _set_item_main_text(menu_item: Button, text: String) -> void:
	var main_label := menu_item.get_node("Content/Row/TextColumn/MainLabel") as Label
	if main_label != null:
		main_label.text = text

		var item_kind := str(menu_item.get_meta("item_kind", ""))
		var font_size := 28 if item_kind == UIBattleEventNames.MENU_ITEM_KIND_TOP_LEVEL else 22
		main_label.add_theme_font_size_override("font_size", font_size)

	menu_item.text = ""

# 设置菜单项副文本，用于显示冷却和关键词。
func _set_item_detail_text(menu_item: Button, cooldown_text: String, keyword_text: String) -> void:
	var detail_label := menu_item.get_node("Content/Row/TextColumn/DetailLabel") as Label
	if detail_label == null:
		return

	detail_label.add_theme_font_size_override("font_size", 18)
	var item_kind := str(menu_item.get_meta("item_kind", ""))
	var detail_parts: Array[String] = []

	if cooldown_text != "":
		detail_parts.append(cooldown_text)

	if keyword_text != "":
		detail_parts.append(keyword_text)

	var detail_text := " | ".join(detail_parts)
	var should_show_detail := item_kind == UIBattleEventNames.MENU_ITEM_KIND_SKILL and detail_text != ""

	detail_label.visible = should_show_detail
	detail_label.text = detail_text if should_show_detail else ""

# 设置菜单项右侧回声槽文本。
func _set_item_suffix_text(menu_item: Button, text: String) -> void:
	var suffix_label := menu_item.get_node("Content/Row/SuffixBadge/SuffixLabel") as Label
	if suffix_label == null:
		return

	suffix_label.add_theme_font_size_override("font_size", 18)
	suffix_label.text = text
	_update_item_suffix_visibility(menu_item)

# 根据当前悬停和回声绑定状态刷新右侧回声槽显隐。
func _update_item_suffix_visibility(menu_item: Button) -> void:
	var suffix_label := menu_item.get_node("Content/Row/SuffixBadge/SuffixLabel") as Label
	var suffix_badge := menu_item.get_node("Content/Row/SuffixBadge") as Control
	if suffix_label == null:
		return

	var item_kind := str(menu_item.get_meta("item_kind", ""))
	var item_id := str(menu_item.get_meta("item_id", ""))
	var slot_text := str(menu_item.get_meta("slot_text", ""))
	var popup_active := skill_sequence_popup != null and skill_sequence_popup.visible

	var should_show_suffix := (
		item_kind == UIBattleEventNames.MENU_ITEM_KIND_SKILL
		and slot_text != ""
		and (
			item_id == hovered_item_id
			or (popup_active and item_id == popup_item_id)
			or item_id == echo_bound_item_id
		)
	)

	suffix_badge.visible = should_show_suffix

# 根据禁用态、选中态和槽位状态刷新菜单项颜色。
func _apply_item_colors(menu_item: Button) -> void:
	var main_label := menu_item.get_node("Content/Row/TextColumn/MainLabel") as Label
	var detail_label := menu_item.get_node("Content/Row/TextColumn/DetailLabel") as Label
	var suffix_label := menu_item.get_node("Content/Row/SuffixBadge/SuffixLabel") as Label
	var suffix_badge := menu_item.get_node("Content/Row/SuffixBadge") as ColorRect
	var item_id := str(menu_item.get_meta("item_id", ""))
	var slot_state := str(menu_item.get_meta("slot_state", ""))
	var is_selected: bool = item_id == selected_item_id

	var main_color := Color(1, 1, 1, 1)
	var suffix_color := _get_slot_text_color(slot_state)
	var suffix_badge_color := _get_slot_badge_color(slot_state)

	if menu_item.disabled:
		main_color = Color(0.55, 0.55, 0.55, 1.0)
		suffix_color = main_color
		suffix_badge_color = Color(0.22, 0.22, 0.22, 1.0)
	elif is_selected:
		main_color = _get_selected_text_color()

	if main_label != null:
		main_label.modulate = main_color

	if detail_label != null:
		detail_label.modulate = main_color

	if suffix_label != null:
		suffix_label.modulate = suffix_color

	if suffix_badge != null:
		suffix_badge.color = suffix_badge_color

# 刷新所有菜单项的选中态显示。
func _update_selected_state() -> void:
	for item_id in menu_item_map.keys():
		var menu_item := menu_item_map[item_id] as Button
		if menu_item == null:
			continue

		_apply_item_colors(menu_item)
		_update_item_suffix_visibility(menu_item)

# 根据当前菜单阶段返回选中项高亮颜色。
func _get_selected_text_color() -> Color:
	match current_menu_mode:
		UIBattleEventNames.MENU_MODE_SPIRIT_SELECT:
			return Color(1.0, 0.88, 0.45, 1.0)
		UIBattleEventNames.MENU_MODE_SKILL_SELECT:
			return Color(0.65, 0.88, 1.0, 1.0)
		UIBattleEventNames.MENU_MODE_TOP_LEVEL_SELECT:
			return Color(1.0, 0.9, 0.45, 1.0)
		_:
			return Color(1.0, 0.9, 0.45, 1.0)

# 根据回声槽状态返回右侧文本颜色。
func _get_slot_text_color(slot_state: String) -> Color:
	match slot_state:
		UIBattleEventNames.MENU_SLOT_STATE_EMPTY:
			return Color(0.9, 0.9, 0.9, 1.0)
		UIBattleEventNames.MENU_SLOT_STATE_FILLED:
			return Color(0.70, 1.0, 0.75, 1.0)
		UIBattleEventNames.MENU_SLOT_STATE_NO_FRAGMENT:
			return Color(1.0, 0.72, 0.72, 1.0)
		UIBattleEventNames.MENU_SLOT_STATE_UNAVAILABLE:
			return Color(0.7, 0.7, 0.7, 1.0)
		_:
			return Color(1, 1, 1, 1)

# 根据回声槽状态返回右侧色块背景颜色。
func _get_slot_badge_color(slot_state: String) -> Color:
	match slot_state:
		UIBattleEventNames.MENU_SLOT_STATE_EMPTY:
			return Color(0.55, 0.55, 0.55, 1.0)
		UIBattleEventNames.MENU_SLOT_STATE_FILLED:
			return Color(0.28, 0.72, 0.34, 1.0)
		UIBattleEventNames.MENU_SLOT_STATE_NO_FRAGMENT:
			return Color(0.82, 0.32, 0.32, 1.0)
		UIBattleEventNames.MENU_SLOT_STATE_UNAVAILABLE:
			return Color(0.32, 0.32, 0.32, 1.0)
		_:
			return Color(0.45, 0.45, 0.45, 1.0)
#endregion

#region --- 菜单点击与事件派发 ---
# 统一处理菜单项点击，区分普通点击和右侧槽位点击。
func _handle_menu_item_pressed(menu_item: Button, on_click: Callable) -> void:
	if _try_emit_slot_clicked(menu_item):
		Audio.play_menu_item_sfx()
		return

	on_click.call()
	finished.emit()
	Audio.play_menu_item_sfx()

# 如果本次点击落在右侧槽位块上，就发独立事件。
func _try_emit_slot_clicked(menu_item: Button) -> bool:
	var item_kind := str(menu_item.get_meta("item_kind", ""))
	if item_kind != UIBattleEventNames.MENU_ITEM_KIND_SKILL:
		return false

	var suffix_badge := menu_item.get_node("Content/Row/SuffixBadge") as Control
	if suffix_badge == null or not suffix_badge.visible:
		return false

	if not suffix_badge.get_global_rect().has_point(menu_item.get_global_mouse_position()):
		return false

	var item_id := str(menu_item.get_meta("item_id", ""))
	var item_meta: Dictionary = {}
	if menu_item.has_meta("item_meta"):
		item_meta = menu_item.get_meta("item_meta")

	var slot_state := str(menu_item.get_meta("slot_state", ""))

	set_selected_item(item_id)
	_show_skill_sequence_popup_for_item(menu_item)

	EventManager.push_event(UIBattleEventNames.MENU_SLOT_CLICKED, {
		"menu_id": current_menu_id,
		"menu_mode": current_menu_mode,
		"menu_context": current_menu_context,
		"item_id": item_id,
		"item_meta": item_meta,
		"slot_state": slot_state
	})

	return true

# 创建一个菜单项实例并绑定点击处理。
func item(_display_name:String, on_click:Callable)->Button:
	var menu_item = battle_menu_item_template.duplicate() as Button
	menu_item.text = _display_name
	menu_item.pressed.connect(func():
		_handle_menu_item_pressed(menu_item, on_click)
	)
	menu_item_root.add_child(menu_item)
	menu_item.show()
	menu_items.append(menu_item)
	return menu_item
#endregion

#region --- 顺序弹窗联动 ---
# 在技能项右侧显示独立的顺序弹出菜单。
func _show_skill_sequence_popup_for_item(menu_item: Button) -> void:
	if skill_sequence_popup == null:
		return

	popup_item_id = str(menu_item.get_meta("item_id", ""))
	popup_item_meta = menu_item.get_meta("item_meta", {})

	var item_rect := menu_item.get_global_rect()
	var popup_position := Vector2(item_rect.end.x + 12.0, item_rect.position.y)

	skill_sequence_popup.global_position = popup_position
	skill_sequence_popup.visible = true
	skill_sequence_popup.set_selected_order("")

# 处理回声顺序确认，并把结果回写到当前技能菜单项。
func _on_skill_sequence_popup_order_confirmed(order_key: String) -> void:
	skill_sequence_popup.hide()

	# 先清掉旧的已插技能，保证每回合最多只绑定一个回声技能。
	if echo_bound_item_id != "" and echo_bound_item_id != popup_item_id:
		var previous_item := menu_item_map.get(echo_bound_item_id, null) as Button
		if previous_item != null:
			previous_item.set_meta("slot_text", "[空]")
			previous_item.set_meta("slot_state", UIBattleEventNames.MENU_SLOT_STATE_EMPTY)
			_set_item_suffix_text(previous_item, "[空]")
			_apply_item_colors(previous_item)

	echo_bound_item_id = popup_item_id
	echo_bound_order_key = order_key
	_update_selected_state()

	var menu_item := menu_item_map.get(popup_item_id, null) as Button
	if menu_item != null:
		popup_item_meta[UIBattleEventNames.MENU_META_ORDER_KEY] = order_key
		menu_item.set_meta("item_meta", popup_item_meta)
		menu_item.set_meta("slot_text", "已插")
		menu_item.set_meta("slot_state", UIBattleEventNames.MENU_SLOT_STATE_FILLED)

		_set_item_suffix_text(menu_item, "已插")
		_apply_item_colors(menu_item)
		_update_item_suffix_visibility(menu_item)

	EventManager.push_event(UIBattleEventNames.MENU_SEQUENCE_CONFIRMED, {
		"menu_id": current_menu_id,
		"menu_mode": current_menu_mode,
		"menu_context": current_menu_context,
		"item_id": popup_item_id,
		"item_meta": popup_item_meta,
		"order_key": order_key
	})
#endregion
