extends PanelContainer

class_name UITurnOrderItem

@onready var name_label: Label = $Content/LayoutRoot/NameLabel
@onready var portrait: TextureRect = $Content/LayoutRoot/Portrait
@onready var content: MarginContainer = $Content

var entry_id: String = ""
var is_player: bool = false
var is_highlighted: bool = false
var base_minimum_size: Vector2 = Vector2(120, 72)
var portrait_size: Vector2 = Vector2(48, 48)

func set_entry_id(value: String) -> void:
	entry_id = value

func set_is_player(value: bool) -> void:
	is_player = value
	_apply_visual_state()

func set_portrait(texture: Texture2D) -> void:
	portrait.texture = texture
	portrait.visible = texture != null

func set_display_name(display_name: String) -> void:
	name_label.text = display_name

func set_lowered(_is_lowered: bool) -> void:
	pass

func set_highlighted(value: bool) -> void:
	is_highlighted = value
	_apply_visual_state()

func _apply_visual_state() -> void:
	custom_minimum_size = base_minimum_size
	portrait.custom_minimum_size = portrait_size
	content.add_theme_constant_override("margin_top", 6)
	modulate = Color(1, 1, 1, 1)

	var panel := StyleBoxFlat.new()
	panel.corner_radius_top_left = 10
	panel.corner_radius_top_right = 10
	panel.corner_radius_bottom_left = 10
	panel.corner_radius_bottom_right = 10
	panel.border_width_left = 2
	panel.border_width_top = 2
	panel.border_width_right = 2
	panel.border_width_bottom = 2

	if is_player:
		if is_highlighted:
			panel.bg_color = Color(0.96, 0.99, 1.0, 1.0)
			panel.border_color = Color(0.10, 0.62, 1.0, 1.0)
			name_label.modulate = Color(0.02, 0.10, 0.22, 1.0)
		else:
			panel.bg_color = Color(0.42, 0.60, 0.76, 1.0)
			panel.border_color = Color(0.24, 0.40, 0.56, 1.0)
			name_label.modulate = Color(0.96, 0.99, 1.0, 1.0)
	else:
		if is_highlighted:
			panel.bg_color = Color(1.0, 0.94, 0.94, 1.0)
			panel.border_color = Color(1.0, 0.22, 0.22, 1.0)
			name_label.modulate = Color(0.30, 0.04, 0.04, 1.0)
		else:
			panel.bg_color = Color(0.72, 0.50, 0.50, 1.0)
			panel.border_color = Color(0.50, 0.22, 0.22, 1.0)
			name_label.modulate = Color(1.0, 0.96, 0.96, 1.0)

	add_theme_stylebox_override("panel", panel)
