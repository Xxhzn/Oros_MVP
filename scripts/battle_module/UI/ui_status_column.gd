extends VBoxContainer

class_name UIStatusColumn

const STATUS_CHIP_SCENE := preload("res://scenes/battle/ui/status_chip.tscn")

# 用一列显示最多 3 个状态标签。
func set_status_texts(status_texts: Array[String]) -> void:
	for child in get_children():
		child.queue_free()

	for i in range(min(status_texts.size(), 3)):
		var chip := STATUS_CHIP_SCENE.instantiate() as UIStatusChip
		add_child(chip)
		chip.set_text(status_texts[i])
