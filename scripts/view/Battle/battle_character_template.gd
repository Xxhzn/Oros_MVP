extends TextureRect

class_name Battle_Character_View 
#@onready var arrow: ColorRect = $Arrow
#@onready var info: RichTextLabel = $info
#
#var data:CharacterData = null
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#arrow.hide()
	#
#
#func setup_data(_data:CharacterData):
	#data = _data
	#data.on_Change.connect(update_view)
	#data.on_hit.connect(tint)
	#
	#texture = load(data.texture_path)
#
#func _process(delta: float) -> void:
	#pass
#
#func turn_left():
	#flip_h = true;
	#
#func update_view():
	#if not data.died:
		##if Global_Model.current_character == data:
			##arrow.show()
		##else:
			##arrow.hide()
		#info.text = "%s %dHp" % [data.display_name, data.hp]
		#self.show()
	#else:
		#info.text = ""
		#self.hide()
#
#var origin_pos:Vector2
#
#func forward():
	#origin_pos = position
	#var dst_pos = origin_pos
	#if flip_h:
		#dst_pos += Vector2.LEFT * 100
	#else:
		#dst_pos += Vector2.RIGHT * 100
	#
	#var tween = create_tween()
	#tween.tween_property(self, "position", dst_pos, 0.15)
	#
#func backward():
	#var tween = create_tween()
	#tween.tween_property(self, "position", origin_pos, 0.15)
	#
#
#func tint():
	#modulate.a = 0
	#await get_tree().create_timer(0.1).timeout
	#modulate.a = 1
	#await get_tree().create_timer(0.1).timeout
	#modulate.a = 0
	#await get_tree().create_timer(0.1).timeout
	#modulate.a = 1
	#await get_tree().create_timer(0.1).timeout
	#modulate.a = 0
	#await get_tree().create_timer(0.1).timeout
	#modulate.a = 1
	#await get_tree().create_timer(0.1).timeout
	#modulate.a = 0
	#await get_tree().create_timer(0.1).timeout
	#modulate.a = 1
	#await get_tree().create_timer(0.1).timeout
	#modulate.a = 0
	#await get_tree().create_timer(0.1).timeout
	#modulate.a = 1
	#await get_tree().create_timer(0.1).timeout
#
#func _exit_tree() -> void:
	#if data != null:
		#data.on_Change.disconnect(update_view)
		#data.on_hit.disconnect(tint)
