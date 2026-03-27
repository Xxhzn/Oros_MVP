extends Control

class_name Main

@onready var player_pos_1: TextureRect = $PlayerPos1
@onready var player_pos_2: TextureRect = $PlayerPos2
@onready var player_pos_3: TextureRect = $PlayerPos3
@onready var enemy_pos_1: TextureRect = $EnemyPos1
@onready var enemy_pos_2: TextureRect = $EnemyPos2
@onready var enemy_pos_3: TextureRect = $EnemyPos3

@onready var battle_character_template: Battle_Character_View = $BattleCharacterTemplate
@onready var battle_menu: UIBattleMenu = $BattleUIRoot/FloatingCommandLayer/BattleMenu
@onready var battle_ui_root: UIBattleRoot = $BattleUIRoot

var player_positions:Array[Control] = []
var enemy_positions:Array[Control] = []

var our_team_character:Dictionary[int,Battle_Character_View] = {}
var enemy_team_character:Dictionary[int,Battle_Character_View] = {}


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
	
	# 添加角色显示位置
	player_positions.append(player_pos_1)
	player_positions.append(player_pos_2)
	player_positions.append(player_pos_3)
	
	# 添加敌人显示位置
	enemy_positions.append(enemy_pos_1)
	enemy_positions.append(enemy_pos_2)
	enemy_positions.append(enemy_pos_3)
	
	fsm.add_state(BattlePrepareStates.new(States.Prepare,self,fsm))
	fsm.add_state(BattleLoopStates.new(States.Loop,self,fsm))
	fsm.add_state(BattleRunawayStates.new(States.Runaway,self,fsm))
	fsm.add_state(BattleWinStates.new(States.Win,self,fsm))
	fsm.add_state(BattleLoseStates.new(States.Lose,self,fsm))
	
	fsm.start_state(States.Prepare)
	

func select_character_weapon(index:int):
	Global_Model.current_character.weapId = index

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fsm.process(delta)
	
func _exit_tree() -> void:
	fsm.clear()
	fsm = null
