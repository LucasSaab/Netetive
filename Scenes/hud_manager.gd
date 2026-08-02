extends Node

@onready var contador_dinheiro: Label = $control/container/container_dinheiro/icone_dinheiro/contador_dinheiro
@onready var contador_fama: Label = $control/container/container_fama/icone_fama/contador_fama

func _ready() -> void:
	# 1. Conecta os sinais do Autoload Global
	Global.fame_received.connect(atualizar_fama)
	Global.altered_money.connect(atualizar_dinheiro)
	
	# 2. Atualiza a UI com os valores atuais ao iniciar
	atualizar_fama(Global.fame)
	atualizar_dinheiro(Global.money)

func atualizar_fama(nova_fama: int) -> void:
	contador_fama.text = str(nova_fama)

func atualizar_dinheiro(novo_dinheiro: float) -> void:
	contador_dinheiro.text = "R$ " + String.num(novo_dinheiro, 2)
