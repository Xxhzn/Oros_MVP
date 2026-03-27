extends HBoxContainer

class_name UIStatusStack

const STATUS_COLUMN_SCENE := preload("res://scenes/battle/ui/status_column.tscn")

# 按每列最多 3 个标签的规则重建状态列。
func set_status_texts(status_texts: Array[String]) -> void:
	for child in get_children():
		child.queue_free()

	for start_index in range(0, status_texts.size(), 3):
		var column := STATUS_COLUMN_SCENE.instantiate() as UIStatusColumn
		add_child(column)

		var column_texts: Array[String] = []
		for i in range(start_index, min(start_index + 3, status_texts.size())):
			column_texts.append(status_texts[i])

		column.set_status_texts(column_texts)
