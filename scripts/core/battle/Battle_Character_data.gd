
class_name Battle_Character_Data
#
#var CharacterArr:Array[CharacterData]
#var WeaponArr:Dictionary[int, WeaponData] = {}
#
#var playerAden = CharacterData.new()
#var enemyProtecter = CharacterData.new()
#var enemyShooter = CharacterData.new()
#
#func _ready() -> void:
	#pass
	#
#func InitCharacter():
	#InitBattleCharacter()
	#InitWeapon()
	#InitAblities()
		#
#func InitBattleCharacter():
	## 玩家
	#playerAden.texture_path = "res://art/tres/player_aiden.tres"
	#playerAden.index = 0
	#playerAden.max_hp = 200
	#playerAden.hp = 200
	#playerAden.speed = 10
	#playerAden.display_name = "艾登"
	#playerAden.control = true
	#CharacterArr.append(playerAden)
	#
	## 敌人1
	#enemyProtecter.texture_path = "res://art/tres/enemy_protecter.tres"
	#enemyProtecter.index = 1
	#enemyProtecter.max_hp = 100
	#enemyProtecter.hp = 100
	#enemyProtecter.dmg = 15
	#enemyProtecter.speed = 5
	#enemyProtecter.display_name = "铁壁卫士"
	#enemyProtecter.control = false
	#CharacterArr.append(enemyProtecter)
	#
	## 敌人2
	#enemyShooter.texture_path = "res://art/tres/enemy_shooter.tres"
	#enemyShooter.index = 2
	#enemyShooter.max_hp = 100
	#enemyShooter.hp = 100
	#enemyShooter.dmg = 10
	#enemyShooter.speed = 8
	#enemyShooter.display_name = "帝国射手"
	#enemyShooter.control = false
	#CharacterArr.append(enemyShooter)
	#
	#
#func InitWeapon():
	## 器灵1
	#var weaponCies = WeaponData.new()
	#weaponCies.displayName = "西斯"
	#weaponCies.index = 0
	#weaponCies.dmg = 10
	#WeaponArr.set(weaponCies.index, weaponCies)
	#
	## 器灵2
	#var weaponYaden = WeaponData.new()
	#weaponYaden.displayName = "亚顿"
	#weaponYaden.dmg = 15
	#weaponYaden.index = 1
	#WeaponArr.set(weaponYaden.index, weaponYaden)
	#
#func InitAblities():
	## 技能1射击
	#var shoot = SkillData.new()
	#shoot.abCooldown = 0
	#shoot.dmg = 10
	#shoot.attackCount = 1
	#shoot.index = 0
	#shoot.status = 0
	#shoot.countDown = 0
	#shoot.displayname = "射击"
	#
	## 技能2快速射击
	#var quickShoot = SkillData.new()
	#quickShoot.abCooldown = 2
	#quickShoot.dmg = 10
	#quickShoot.attackCount = 3
	#quickShoot.index = 1
	#quickShoot.status = 1
	#quickShoot.countDown = 0
	#quickShoot.displayname = "快速射击"
	#
	## 技能3震弦射击
	#var stringShoot = SkillData.new()
	#stringShoot.abCooldown = 2
	#stringShoot.dmg = 5
	#stringShoot.attackCount = 1
	#stringShoot.index = 2
	#stringShoot.status = 2
	#stringShoot.countDown = 0
	#stringShoot.displayname = "震弦射击"
	#
	## 从 WeaponArr 中找到 weaponCies
	#var weaponCies = WeaponArr[0]
	#if weaponCies:
		#weaponCies.ablities.set(shoot.index,shoot)
		#weaponCies.ablities.set(quickShoot.index, quickShoot)
		#weaponCies.ablities.set(stringShoot.index, stringShoot)
	#
	## 技能4盾击
	#var shield = SkillData.new()
	#shield.abCooldown = 0
	#shield.dmg = 15
	#shield.attackCount = 1
	#shield.index = 3
	#shield.status = 0
	#shield.countDown = 0
	#shield.displayname = "盾击"
	#
	## 技能5盾牌守护
	#var guardianShield = SkillData.new()
	#guardianShield.abCooldown = 2
	#guardianShield.dmg = 0
	#guardianShield.attackCount = 1
	#guardianShield.index = 4
	#guardianShield.status = 3
	#guardianShield.target = true
	#guardianShield.countDown = 0
	#guardianShield.displayname = "盾牌守护"
	#
	## 技能6守势回稳
	#var defensive = SkillData.new()
	#defensive.abCooldown = 2
	#defensive.dmg = 0
	#defensive.attackCount = 1
	#defensive.index = 5
	#defensive.status = 4
	#defensive.target = true
	#defensive.countDown = 0
	#defensive.displayname = "守势回稳"
	#
	## 从 WeaponArr 中找到 weaponYaden
	#var weaponYaden = WeaponArr[1]
#
	#if weaponYaden:
		#weaponYaden.ablities.set(shield.index, shield)
		#weaponYaden.ablities.set(guardianShield.index, guardianShield)
		#weaponYaden.ablities.set(defensive.index, defensive)
	#
	## 敌人技能
	## 技能1射击
	#var enemyShoot = SkillData.new()
	#enemyShoot.abCooldown = 0
	#enemyShoot.dmg = 10
	#enemyShoot.attackCount = 1
	#enemyShoot.index = 0
	#enemyShoot.status = 0
	#enemyShoot.countDown = 0
	#enemyShoot.displayname = "射击"
	#enemyShooter.ablities.set(enemyShoot.index, enemyShoot)
	#
	## 技能2瞄准射击
	#var targetedShoot = SkillData.new()
	#targetedShoot.abCooldown = 2
	#targetedShoot.dmg = 20
	#targetedShoot.attackCount = 1
	#targetedShoot.index = 1
	#targetedShoot.status = 1
	#targetedShoot.countDown = 0
	#targetedShoot.displayname = "瞄准射击"
	#enemyShooter.ablities.set(targetedShoot.index, targetedShoot)
	#
	## 技能1盾牌冲锋
	#var enemyShield = SkillData.new()
	#enemyShield.abCooldown = 0
	#enemyShield.dmg = 15
	#enemyShield.attackCount = 1
	#enemyShield.index = 0
	#enemyShield.status = 0
	#enemyShield.countDown = 0
	#enemyShield.displayname = "盾牌冲锋"
	#enemyProtecter.ablities.set(enemyShield.index, enemyShield)
	#
	## 技能2盾击
	#var shieldAttack = SkillData.new()
	#shieldAttack.abCooldown = 2
	#shieldAttack.dmg = 5
	#shieldAttack.attackCount = 1
	#shieldAttack.index = 1
	#shieldAttack.status = 2
	#shieldAttack.countDown = 0
	#shieldAttack.displayname = "盾击"
	#enemyProtecter.ablities.set(shieldAttack.index, shieldAttack)
	#
	#
	#
	#
	#
	#
