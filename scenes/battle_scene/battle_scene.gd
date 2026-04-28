extends Node3D
class_name Battle_Scene

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

	
	pass
	#fsm.add_state(BattlePrepareStates.new(States.Prepare,self,fsm))
	#fsm.add_state(BattleLoopStates.new(States.Loop,self,fsm))
	#fsm.add_state(BattleRunawayStates.new(States.Runaway,self,fsm))
	#fsm.add_state(BattleWinStates.new(States.Win,self,fsm))
	#fsm.add_state(BattleLoseStates.new(States.Lose,self,fsm))
	
	#fsm.start_state(States.Prepare)
	

func select_character_weapon(index:int):
	Global_Model.current_character.weapId = index

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fsm.process(delta)
	
func _exit_tree() -> void:
	fsm.clear()
	fsm = null
