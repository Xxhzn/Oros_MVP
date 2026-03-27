extends PanelContainer

class_name UITurnOrderBar

const TURN_ORDER_ITEM_SCENE := preload("res://scenes/battle/ui/turn_order_item.tscn")

var current_entries: Array = []
var highlighted_index: int = -1
var highlighted_entry_id: String = ""

@onready var item_root: HBoxContainer = $ItemRoot

func _ready() -> void:
	EventManager.subscribe(UIBattleEventNames.TURN_ORDER_SET, _on_turn_order_set)
	EventManager.subscribe(UIBattleEventNames.TURN_ORDER_CLEAR, _on_turn_order_clear)
	EventManager.subscribe(UIBattleEventNames.TURN_ORDER_HIGHLIGHT, _on_turn_order_highlight)

func _exit_tree() -> void:
	EventManager.unsubscribe(UIBattleEventNames.TURN_ORDER_SET, _on_turn_order_set)
	EventManager.unsubscribe(UIBattleEventNames.TURN_ORDER_CLEAR, _on_turn_order_clear)
	EventManager.unsubscribe(UIBattleEventNames.TURN_ORDER_HIGHLIGHT, _on_turn_order_highlight)

func set_entries(entries: Array) -> void:
	current_entries = entries.duplicate()
	_rebuild_items()

func clear_entries() -> void:
	current_entries.clear()
	highlighted_index = -1
	highlighted_entry_id = ""
	_rebuild_items()

func _on_turn_order_set(payload: Dictionary) -> void:
	if payload.has("entries"):
		set_entries(payload["entries"])

func _on_turn_order_clear(_payload: Dictionary) -> void:
	clear_entries()

func _rebuild_items() -> void:
	for child in item_root.get_children():
		child.queue_free()

	for entry in current_entries:
		var item := TURN_ORDER_ITEM_SCENE.instantiate() as UITurnOrderItem
		var display_name := ""
		var entry_id := ""
		var is_player := false
		var portrait: Texture2D = null

		if entry is Dictionary:
			display_name = str(entry.get("display_name", entry.get("name", "")))
			entry_id = str(entry.get("id", display_name))
			is_player = bool(entry.get("is_player", false))
			portrait = entry.get("portrait", null)
		else:
			display_name = str(entry)
			entry_id = display_name

		item_root.add_child(item)
		item.set_entry_id(entry_id)
		item.set_is_player(is_player)
		item.set_portrait(portrait)
		item.set_display_name(display_name)

	# 重建列表后重新应用当前高亮状态
	_update_item_highlight()

func _on_turn_order_highlight(payload: Dictionary) -> void:
	# 优先按稳定的条目 id 高亮。
	if payload.has("entry_id"):
		highlighted_entry_id = str(payload["entry_id"])
		highlighted_index = -1
		_update_item_highlight()
		return

	# 兼容临时测试用的 index 高亮。
	if payload.has("index"):
		highlighted_index = int(payload["index"])
		highlighted_entry_id = ""
		_update_item_highlight()

func _update_item_highlight() -> void:
	var children = item_root.get_children()

	for i in range(children.size()):
		var item = children[i] as UITurnOrderItem
		if item == null:
			continue

		var is_highlighted := false

		# 优先按条目 id 判断高亮。
		if highlighted_entry_id != "":
			is_highlighted = item.entry_id == highlighted_entry_id
		else:
			is_highlighted = i == highlighted_index

		item.set_highlighted(is_highlighted)
		# 当前行动项额外做下拉提示。
		item.set_lowered(is_highlighted)
