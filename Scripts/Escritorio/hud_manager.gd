# hud_manager.gd
extends Node

@onready var contador_dinheiro: Label = $control/container_dinheiro/icone_dinheiro/contador_dinheiro
@onready var contador_fama: Label = $control/container_fama/icone_fama/contador_fama

# DadosJogo (Autoload) não emite sinal quando dinheiro_jogador/fama_jogador
# mudam — o crédito só acontece uma vez, no fim do expediente, dentro de
# RelatorioDia.montar_relatorio(). Por isso o HUD lê os valores por
# polling em _process(), em vez de escutar Global.altered_money/fame_received
# como na versão antiga.
var _ultimo_dinheiro: int = -1
var _ultima_fama: int = -1


func _ready() -> void:
	if contador_dinheiro == null:
		push_warning("HudManager: nó 'contador_dinheiro' não encontrado — confira a estrutura da cena.")
	if contador_fama == null:
		push_warning("HudManager: nó 'contador_fama' não encontrado — confira a estrutura da cena.")

	_atualizar_se_mudou()


func _process(_delta: float) -> void:
	_atualizar_se_mudou()


func _atualizar_se_mudou() -> void:
	if DadosJogo.dinheiro_jogador != _ultimo_dinheiro:
		_ultimo_dinheiro = DadosJogo.dinheiro_jogador
		atualizar_dinheiro(_ultimo_dinheiro)

	if DadosJogo.fama_jogador != _ultima_fama:
		_ultima_fama = DadosJogo.fama_jogador
		atualizar_fama(_ultima_fama)


func atualizar_fama(nova_fama: int) -> void:
	if contador_fama != null:
		contador_fama.text = str(nova_fama)


func atualizar_dinheiro(novo_dinheiro: int) -> void:
	if contador_dinheiro != null:
		contador_dinheiro.text = "R$ %d" % novo_dinheiro
