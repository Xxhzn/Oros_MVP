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
	print("创建按钮: ", _display_name, " 时间: ", Time.get_ticks_msec())
	menu_item.pressed.connect(func():
		print("按钮被按下: ", _display_name, " 时间: ", Time.get_ticks_msec())
		on_click.call()
		finished.emit()
		#self.hide()
	)
	menu_item_root.add_child(menu_item)
	menu_item.show()
	print("按钮显示完成: ", _display_name)
	menu_items.append(menu_item)
	return menu_item
	
