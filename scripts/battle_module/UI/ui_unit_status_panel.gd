extends Control

class_name UIUnitStatusPanel

@onready var name_label: Label = $Content/LayoutRoot/NameLabel
@onready var bar_root: Control = $Content/LayoutRoot/BarRoot
@onready var hp_fill: ColorRect = $Content/LayoutRoot/BarRoot/HpFill
@onready var shield_fill: ColorRect = $Content/LayoutRoot/BarRoot/ShieldFill
@onready var value_label: Label = $Content/LayoutRoot/BarRoot/ValueLabel

# 设置单位名称。
func set_unit_name(unit_name: String) -> void:
	name_label.text = unit_name

var current_hp: int = 0
var max_hp: int = 1
var shield_value: int = 0

# 设置生命值并刷新血条。
func set_hp(value: int, max_value: int) -> void:
	current_hp = value
	max_hp = max(max_value, 1)
	_update_bar()

# 设置护盾值并刷新护盾条。
func set_shield(value: int) -> void:
	shield_value = max(value, 0)
	_update_bar()

# 根据当前数值刷新血条和护盾条宽度。
func _update_bar() -> void:
	var total_width: float = bar_root.size.x
	if total_width <= 0:
		total_width = bar_root.custom_minimum_size.x

	var hp_ratio: float = clamp(float(current_hp) / float(max_hp), 0.0, 1.0)
	var hp_width: float = total_width * hp_ratio

	hp_fill.size.x = hp_width
	hp_fill.size.y = bar_root.size.y if bar_root.size.y > 0 else bar_root.custom_minimum_size.y

	var shield_ratio: float = clamp(float(shield_value) / float(max_hp), 0.0, 1.0)
	var shield_width: float = total_width * shield_ratio

	shield_fill.visible = shield_value > 0
	shield_fill.position.x = hp_width
	shield_fill.size.x = shield_width
	shield_fill.size.y = hp_fill.size.y

	if shield_value > 0:
		value_label.text = "%d/%d +%d" % [current_hp, max_hp, shield_value]
	else:
		value_label.text = "%d/%d" % [current_hp, max_hp]
