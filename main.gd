extends Control

class_name Main

@onready var player_pos_1: TextureRect = $PlayerPos1
@onready var player_pos_2: TextureRect = $PlayerPos2
@onready var player_pos_3: TextureRect = $PlayerPos3
@onready var enemy_pos_1: TextureRect = $EnemyPos1
@onready var enemy_pos_2: TextureRect = $EnemyPos2
@onready var enemy_pos_3: TextureRect = $EnemyPos3

@onready var battle_character_template: BattleCharacter = $BattleCharacterTemplate

var player_positions:Array[Control] = []
var enemy_positions:Array[Control] = []


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
	
	_enter_battle()

func _enter_battle():
	#console_label.push_text("进入战斗")
	_start_player_a()

func _start_player_a():
	#console_label.push_text( "轮到 主角A")
	_player_a_select_action()
	
func _player_a_select_action():
	#key_input_label.text = "请选择动作 ： 1 攻击"
	#var act = await key_input 
	#
	#if act == 1:
		#console_label.push_text("主角A 选择了 攻击")
		_player_a_select_target()
		
func _player_a_select_target():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
