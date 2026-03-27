extends PanelContainer

class_name UIStatusChip

@onready var text_label: Label = $TextLabel

# 设置状态标签文字。
func set_text(value: String) -> void:
	text_label.text = value
