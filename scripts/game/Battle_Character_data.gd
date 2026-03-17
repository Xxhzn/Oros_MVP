
class_name Battle_Character_Data

var CharacterArr:Array[Battle_Character]
var WeaponArr:Dictionary[int, weapon] = {}

var playerAden = Battle_Character.new()
var enemyProtecter = Battle_Character.new()
var enemyShooter = Battle_Character.new()

func _ready() -> void:
	pass
	
func InitCharacter():
	InitBattleCharacter()
	InitWeapon()
	InitAblities()
		
func InitBattleCharacter():
	# 玩家
	playerAden.texture_path = "res://art/sprite/prototype_player.png"
	playerAden.hp = 100
	playerAden.speed = 10
	playerAden.display_name = "艾登"
	playerAden.control = true
	CharacterArr.append(playerAden)
	
	# 敌人1
	enemyProtecter.texture_path = "res://art/sprite/prototype_enemy.png"
	enemyProtecter.hp = 100
	enemyProtecter.dmg = 15
	enemyProtecter.speed = 5
	enemyProtecter.display_name = "铁壁卫士"
	enemyProtecter.control = false
	CharacterArr.append(enemyProtecter)
	
	# 敌人2
	enemyShooter.texture_path = "res://art/sprite/Idle0.png"
	enemyShooter.hp = 100
	enemyShooter.dmg = 10
	enemyShooter.speed = 8
	enemyShooter.display_name = "帝国射手"
	enemyShooter.control = false
	CharacterArr.append(enemyShooter)
	
	
func InitWeapon():
	# 器灵1
	var weaponCies = weapon.new()
	weaponCies.displayName = "西斯"
	weaponCies.index = 0
	weaponCies.dmg = 10
	WeaponArr.set(weaponCies.index, weaponCies)
	
	# 器灵2
	var weaponYaden = weapon.new()
	weaponYaden.displayName = "亚顿"
	weaponYaden.dmg = 15
	weaponYaden.index = 1
	WeaponArr.set(weaponYaden.index, weaponYaden)
	
func InitAblities():
	# 技能1射击
	var shoot = ablities_data.new()
	shoot.abCooldown = 0
	shoot.dmg = 10
	shoot.attackCount = 1
	shoot.index = 0
	shoot.status = 0
	shoot.displayname = "射击"
	
	# 技能2快速射击
	var quickShoot = ablities_data.new()
	quickShoot.abCooldown = 1
	quickShoot.dmg = 10
	quickShoot.attackCount = 3
	quickShoot.index = 1
	quickShoot.status = 1
	quickShoot.displayname = "快速射击"
	
	# 技能3震弦射击
	var stringShoot = ablities_data.new()
	stringShoot.abCooldown = 1
	stringShoot.dmg = 5
	stringShoot.attackCount = 1
	stringShoot.index = 2
	stringShoot.status = 2
	stringShoot.displayname = "震弦射击"
	
	# 从 WeaponArr 中找到 weaponCies
	var weaponCies = WeaponArr[0]
	if weaponCies:
		weaponCies.ablities.set(shoot.index,shoot)
		weaponCies.ablities.set(quickShoot.index, quickShoot)
		weaponCies.ablities.set(stringShoot.index, stringShoot)
	
	# 技能4盾击
	var shield = ablities_data.new()
	shield.abCooldown = 0
	shield.dmg = 15
	shield.attackCount = 1
	shield.index = 3
	shield.status = 0
	shield.displayname = "盾击"
	
	# 技能5盾牌守护
	var guardianShield = ablities_data.new()
	guardianShield.abCooldown = 1
	guardianShield.dmg = 0
	guardianShield.attackCount = 1
	guardianShield.index = 4
	guardianShield.status = 3
	guardianShield.target = true
	guardianShield.displayname = "盾牌守护"
	
	# 技能6守势回稳
	var defensive = ablities_data.new()
	defensive.abCooldown = 1
	defensive.dmg = 0
	defensive.attackCount = 1
	defensive.index = 5
	defensive.status = 4
	defensive.target = true
	defensive.displayname = "守势回稳"
	
	# 从 WeaponArr 中找到 weaponYaden
	var weaponYaden = WeaponArr[1]

	if weaponYaden:
		weaponYaden.ablities.set(shield.index, shield)
		weaponYaden.ablities.set(guardianShield.index, guardianShield)
		weaponYaden.ablities.set(defensive.index, defensive)
	
	# 敌人技能
	# 技能1射击
	var enemyShoot = ablities_data.new()
	enemyShoot.abCooldown = 0
	enemyShoot.dmg = 10
	enemyShoot.attackCount = 1
	enemyShoot.index = 0
	enemyShoot.status = 0
	enemyShoot.displayname = "射击"
	enemyShooter.ablities.set(enemyShoot.index, enemyShoot)
	
	# 技能2瞄准射击
	var targetedShoot = ablities_data.new()
	targetedShoot.abCooldown = 1
	targetedShoot.dmg = 20
	targetedShoot.attackCount = 1
	targetedShoot.index = 1
	targetedShoot.status = 1
	targetedShoot.displayname = "瞄准射击"
	enemyShooter.ablities.set(targetedShoot.index, targetedShoot)
	
	# 技能1盾牌冲锋
	var enemyShield = ablities_data.new()
	enemyShield.abCooldown = 0
	enemyShield.dmg = 15
	enemyShield.attackCount = 1
	enemyShield.index = 0
	enemyShield.status = 0
	enemyShield.displayname = "盾牌冲锋"
	enemyProtecter.ablities.set(enemyShield.index, enemyShield)
	
	# 技能2盾击
	var shieldAttack = ablities_data.new()
	shieldAttack.abCooldown = 1
	shieldAttack.dmg = 20
	shieldAttack.attackCount = 1
	shieldAttack.index = 1
	shieldAttack.status = 2
	shieldAttack.displayname = "盾击"
	enemyShooter.ablities.set(shieldAttack.index, shieldAttack)
	
	
	
	
	
	
