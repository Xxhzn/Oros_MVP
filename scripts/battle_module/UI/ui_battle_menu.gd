extends Panel

class_name UIBattleMenu

@onready var menu_item_root: VBoxContainer = $MenuItemRoot
@onready var battle_menu_item_template: Button = $BattleMenuItemTemplate
@onready var title: Label = $title

signal finished

var menu_items:Array[Button] = []

func _ready() -> void:
	battle_menu_item_template.hide()
	title.hide()
	
func open():
	for menu_item in menu_items:
		menu_item.queue_free()
		
	menu_items.clear()
	title.show()
	self.show()

func item(_display_name:String, on_click:Callable)->Button:
	var menu_item = battle_menu_item_template.duplicate() as Button
	menu_item.text = _display_name
	menu_item.pressed.connect(func():
		on_click.call()
		finished.emit()
		Audio.play_menu_item_sfx()
		#self.hide()
	)
	menu_item_root.add_child(menu_item)
	menu_item.show()
	menu_items.append(menu_item)
	return menu_item
	
