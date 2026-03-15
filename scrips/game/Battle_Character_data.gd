
class_name Battle_Character_Data

var PlayerCharacterArr:Array[Battle_Character]
var EnemyCharacterArr:Array[Battle_Character]

func InitBattleCharacter():
	# 玩家
	var playerAden = Battle_Character.new()
	playerAden.texture_path = "res://art/sprite/prototype_player.png"
	playerAden.hp = 100
	playerAden.speed = 10
	playerAden.display_name = "艾登"
	
	# 敌人1
	var enemyProtecter = Battle_Character.new()
	enemyProtecter.texture_path = "res://art/sprite/prototype_enemy.png"
	enemyProtecter.hp = 100
	enemyProtecter.dmg = 15
	enemyProtecter.speed = 5
	enemyProtecter.display_name = "铁壁卫士"
	
	# 敌人2
	var enemyShooter = Battle_Character.new()
	enemyShooter.texture_path = "res://art/sprite/Idle0.png"
	enemyShooter.hp = 100
	enemyShooter.dmg = 10
	enemyShooter.speed = 8
	enemyShooter.display_name = "帝国射手"
	
