extends Node



@onready var contador_fama: Label = $HUD/control/container/container_fama/icone_fama/contador_fama as Label
@onready var contador_dinheiro: Label = $HUD/control/container/container_dinheiro/icone_dinheiro/contador_dinheiro as Label

func _ready():
	contador_fama.text = str(Global.fame)
	contador_dinheiro.text = str(Global.money)
	
