
class_name Battle_Character_Data

var PlayerCharacterArr:Array[Battle_Character]
var EnemyCharacterArr:Array[Battle_Character]
var WeaponArr:Array[weapon]

func InitBattleCharacter():
	# 玩家
	var playerAden = Battle_Character.new()
	playerAden.texture_path = "res://art/sprite/prototype_player.png"
	playerAden.hp = 100
	playerAden.speed = 10
	playerAden.display_name = "艾登"
	PlayerCharacterArr.append(playerAden)
	
	# 敌人1
	var enemyProtecter = Battle_Character.new()
	enemyProtecter.texture_path = "res://art/sprite/prototype_enemy.png"
	enemyProtecter.hp = 100
	enemyProtecter.dmg = 15
	enemyProtecter.speed = 5
	enemyProtecter.display_name = "铁壁卫士"
	EnemyCharacterArr.append(enemyProtecter)
	
	# 敌人2
	var enemyShooter = Battle_Character.new()
	enemyShooter.texture_path = "res://art/sprite/Idle0.png"
	enemyShooter.hp = 100
	enemyShooter.dmg = 10
	enemyShooter.speed = 8
	enemyShooter.display_name = "帝国射手"
	EnemyCharacterArr.append(enemyShooter)
	
	
func InitWeapon():
	# 器灵1
	var weaponCies = weapon.new()
	weaponCies.displayName = "西斯"
	weaponCies.index = 0
	weaponCies.dmg = 10
	WeaponArr.append(weaponCies)
	
	# 器灵2
	var weaponYaden = weapon.new()
	weaponYaden.displayName = "亚顿"
	weaponYaden.dmg = 15
	weaponYaden.index = 1
	WeaponArr.append(weaponYaden)
	
func InitAblities():
	# 技能1射击
	var shoot = ablities_data.new()
	shoot.abCooldown = 0
	shoot.dmg = 10
	shoot.attackCount = 1
	shoot.index = 0
	shoot.status = 0
	
	# 技能2快速射击
	var quickShoot = ablities_data.new()
	quickShoot.abCooldown = 1
	quickShoot.dmg = 10
	quickShoot.attackCount = 3
	quickShoot.index = 1
	quickShoot.status = 1
	
	# 技能3震弦射击
	var stringShoot = ablities_data.new()
	stringShoot.abCooldown = 1
	stringShoot.dmg = 5
	stringShoot.attackCount = 1
	stringShoot.index = 2
	stringShoot.status = 2
	
	# 从 WeaponArr 中找到 weaponCies
	var weaponCies = null
	for weapon in WeaponArr:
		if weapon.displayName == "西斯":
			weaponCies = weapon
			break
	
	if weaponCies:
		weaponCies.ablities.append(shoot)
		weaponCies.ablities.append(quickShoot)
		weaponCies.ablities.append(stringShoot)
	
	# 技能4盾击
	var shield = ablities_data.new()
	shield.abCooldown = 0
	shield.dmg = 15
	shield.attackCount = 1
	shield.index = 3
	shield.status = 0
	
	# 技能5盾牌守护
	var guardianShield = ablities_data.new()
	guardianShield.abCooldown = 1
	guardianShield.dmg = 0
	guardianShield.attackCount = 1
	guardianShield.index = 4
	guardianShield.status = 3
	guardianShield.target = true
	
	# 技能6守势回稳
	var defensive = ablities_data.new()
	defensive.abCooldown = 1
	defensive.dmg = 0
	defensive.attackCount = 1
	defensive.index = 5
	defensive.status = 4
	defensive.target = true
	
	# 从 WeaponArr 中找到 weaponYaden
	var weaponYaden = null
	for weapon in WeaponArr:
		if weapon.displayName == "亚顿":
			weaponYaden = weapon
			break
	
	if weaponYaden:
		weaponYaden.ablities.append(shield)
		weaponYaden.ablities.append(guardianShield)
		weaponYaden.ablities.append(defensive)
	
	
	
	
	
	
	
