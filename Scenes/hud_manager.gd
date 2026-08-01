extends Node

@onready var contador_dinheiro: Label = $control/container/container_dinheiro/icone_dinheiro/contador_dinheiro
@onready var contador_fama: Label = $control/container/container_fama/icone_fama/contador_fama

func _ready() -> void:
	# 1. Conecta os sinais do Global
	Global.fame_received.connect(atualizar_fama)
	Global.altered_money.connect(atualizar_dinheiro)
	
	# 2. Atualiza com os valores atuais
	atualizar_fama(Global.fame)
	atualizar_dinheiro(Global.money)
	
	# 3. TESTE: Adiciona dinheiro/fama para forçar o sinal no início
	Global.add_money(250.75)
	print(Global.money)
	Global.add_fame(15)
	print(Global.fame)

func atualizar_fama(nova_fama: int) -> void:
	contador_fama.text = str(nova_fama)

func atualizar_dinheiro(novo_dinheiro: float) -> void:
	contador_dinheiro.text = "R$ " + String.num(novo_dinheiro, 2) 
