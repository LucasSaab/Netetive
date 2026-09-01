extends Node
class_name GerenciadorAssistente

# =====================================================================
# GerenciadorAssistente
# ---------------------------------------------------------------------
# Fila de trabalhos delegados pelo jogador ao(s) Assistente(s). Só
# entende DUAS linhas de upgrade (lidas via DadosJogo.obter_linha_upgrade,
# nunca copiadas pra variável própria — sempre lê o tier atual na hora):
#
#   Assistente — Treinamento  → tempo simulado por trabalho (minutos) e
#                                 taxa de sucesso. tier_atual == 0 aqui
#                                 significa "nenhum assistente contratado
#                                 ainda" — delegar() recusa nesse caso.
#   Assistente — Quantidade   → quantos trabalhos processam em PARALELO
#                                 (capacidade). Base = 1 assistente assim
#                                 que Treinamento tier 1 é comprado, mesmo
#                                 sem nenhum tier de Quantidade ainda.
#
# Trabalhos além da capacidade esperam numa fila FIFO (_fila_espera) e
# só começam a contar tempo quando um "slot" abre.
#
# Não sabe nada sobre a UI da lista de trabalhos (VBoxAtivos) — só emite
# trabalho_assistente_concluido, que quem coordena (coordenador_trabalho.gd)
# escuta pra remover o item da lista e mostrar feedback, do mesmo jeito
# que já faz para "Encerrar" manual.
# =====================================================================

signal trabalho_assistente_concluido(agendado: TrabalhoAgendado, acertou: bool)

@export var gerenciador_expediente: Node

var _fila_espera: Array[TrabalhoAgendado] = []
var _em_andamento: Dictionary = {}   # TrabalhoAgendado -> hora_conclusao_prevista (float)


func _ready() -> void:
	if gerenciador_expediente == null:
		push_warning("GerenciadorAssistente: gerenciador_expediente não atribuído no Inspetor.")


# ---------------------------------------------------------------------
# CONSULTAS DE ESTADO — usadas pelo botão "Delegar" (gerenciador_trabalho.gd)
# pra decidir se mostra/habilita a opção antes mesmo de tentar delegar.
# ---------------------------------------------------------------------

func esta_disponivel() -> bool:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_TREINAMENTO)
	return linha != null and linha.tier_atual >= 1


func trabalho_esta_na_fila_ou_andamento(agendado: TrabalhoAgendado) -> bool:
	return _em_andamento.has(agendado) or _fila_espera.has(agendado)


# ---------------------------------------------------------------------
# DELEGAR — chamado externamente quando o jogador clica em "Delegar".
# Retorna false (com push_warning) se não há assistente contratado ou
# se o trabalho já está na fila/em andamento.
# ---------------------------------------------------------------------
func delegar(agendado: TrabalhoAgendado) -> bool:
	if not esta_disponivel():
		push_warning("GerenciadorAssistente: nenhum assistente contratado ainda (compre Assistente — Treinamento tier 1).")
		return false

	if agendado == null or trabalho_esta_na_fila_ou_andamento(agendado):
		return false

	# Garante que existe um ResultadoTrabalho pendente pra essa ocorrência,
	# mesmo que o jogador nunca tenha aberto a tela de inspeção pra esse
	# trabalho (delegar direto da lista de Ativos é um caminho válido).
	if not DadosJogo.resultados_pendentes.has(agendado):
		DadosJogo.iniciar_resultado_pendente(agendado, _hora_atual())

	if _em_andamento.size() < _capacidade_atual():
		_iniciar_processamento(agendado)
	else:
		_fila_espera.append(agendado)

	return true


func _iniciar_processamento(agendado: TrabalhoAgendado) -> void:
	var minutos := _tempo_por_trabalho_minutos()
	_em_andamento[agendado] = _hora_atual() + (minutos / 60.0)


func _puxar_proximo_da_fila() -> void:
	if _fila_espera.is_empty() or _em_andamento.size() >= _capacidade_atual():
		return
	var proximo: TrabalhoAgendado = _fila_espera.pop_front()
	_iniciar_processamento(proximo)


# ---------------------------------------------------------------------
# TICK — checa a cada frame se algum trabalho em andamento já venceu o
# horário simulado de conclusão. Barato mesmo rodando todo frame porque
# _em_andamento normalmente tem só 1-5 itens (capacidade máxima é 5).
# ---------------------------------------------------------------------
func _process(_delta: float) -> void:
	if _em_andamento.is_empty():
		return

	var hora_atual := _hora_atual()
	var concluidos: Array[TrabalhoAgendado] = []

	for agendado in _em_andamento.keys():
		if hora_atual >= _em_andamento[agendado]:
			concluidos.append(agendado)

	for agendado in concluidos:
		_em_andamento.erase(agendado)
		_resolver_trabalho(agendado, hora_atual)
		_puxar_proximo_da_fila()


# ---------------------------------------------------------------------
# RESOLUÇÃO — sorteia acerto/erro pela taxa de sucesso atual do
# Treinamento e fecha o ResultadoTrabalho direto, sem passar pela
# NovaAba (o Assistente não "acha alvo" nem "escolhe diagnóstico" de
# verdade — o veredito combinado é decidido de uma vez, igual já é
# permitido em ResultadoTrabalho.finalizar()).
# ---------------------------------------------------------------------
func _resolver_trabalho(agendado: TrabalhoAgendado, hora_atual: float) -> void:
	var acertou := randf() < _taxa_sucesso_atual()

	if DadosJogo.resultados_pendentes.has(agendado):
		var resultado: ResultadoTrabalho = DadosJogo.resultados_pendentes[agendado]
		resultado.achou_alvo_correto = acertou
		resultado.diagnostico_correto = acertou
		if resultado.diagnostico_escolhido == "":
			resultado.diagnostico_escolhido = "Resolvido pelo Assistente"

	DadosJogo.finalizar_trabalho(agendado, hora_atual)
	trabalho_assistente_concluido.emit(agendado, acertou)


# ---------------------------------------------------------------------
# HELPERS — leem as linhas de upgrade sob demanda, nunca guardam cópia.
# ---------------------------------------------------------------------
func _capacidade_atual() -> int:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_QUANTIDADE)
	if linha == null:
		return 1   # fallback de segurança; Treinamento tier 1 já garante 1 assistente
	return int(linha.valor_efeito_atual(1.0))   # base 1.0 = só o assistente do Treinamento, sem nenhum tier de Quantidade


func _tempo_por_trabalho_minutos() -> float:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_TREINAMENTO)
	if linha == null or linha.tier_atual <= 0:
		return 0.0
	return linha.valor_efeito_atual()


func _taxa_sucesso_atual() -> float:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_TREINAMENTO)
	if linha == null or linha.tier_atual <= 0:
		return 0.0
	return linha.valor_efeito_secundario_atual()


func _hora_atual() -> float:
	if gerenciador_expediente != null and "hora_atual" in gerenciador_expediente:
		return gerenciador_expediente.hora_atual
	return 0.0
