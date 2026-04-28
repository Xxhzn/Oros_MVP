extends Control

class_name Main_UI
enum States
{
	Prepare,
	Loop,
	Runaway,
	Win,
	Lose
}

var fsm:EasyFSM = EasyFSM.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var util = Util.new()
	var data = util.load_file("res://scripts/resources/battle/config/skills.json")
	print("加载技能配置文件",data)
	
	data = util.load_file("res://scripts/resources/battle/config/skill_effects.json")
	print("加载技能效果配置文件",data)
	
	#fsm.add_state(BattlePrepareStates.new(States.Prepare,self,fsm))
	#fsm.add_state(BattleLoopStates.new(States.Loop,self,fsm))
	#fsm.add_state(BattleRunawayStates.new(States.Runaway,self,fsm))
	#fsm.add_state(BattleWinStates.new(States.Win,self,fsm))
	#fsm.add_state(BattleLoseStates.new(States.Lose,self,fsm))
	#
	#fsm.start_state(States.Prepare)
	

func select_character_weapon(index:int):
	Global_Model.current_character.weapId = index

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fsm.process(delta)
	
func _exit_tree() -> void:
	fsm.clear()
	fsm = null
