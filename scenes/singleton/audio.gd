extends Node2D

const PROTOTYPE_ATTACK = "res://art/audio/sfx/prototype_attack.wav"

const PROTOTYPE_MENU_ITEM = "res://art/audio/sfx/prototype_menu_item.wav"
@onready var sfx_play: AudioStreamPlayer2D = $SfxPlayer

func play_attack_sfx():
	sfx_play.stream = load(PROTOTYPE_ATTACK)
	sfx_play.play()
	
func play_menu_item_sfx():
	sfx_play.stream = load(PROTOTYPE_MENU_ITEM)
	sfx_play.play()
