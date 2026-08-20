class_name GerenciadorIANoturna
extends RefCounted

# =====================================================================
# GerenciadorIANoturna
# ---------------------------------------------------------------------
# Resolve, uma vez por dia, os trabalhos que "sobraram" na agenda —
# nunca aceitos (apareceu and not aceito) ou aceitos mas nunca
# concluídos (aceito and not concluido, e sem resultado pendente em
# andamento em outro lugar, ex: fila do Assistente) — simulando a IA
# processando-os durante a noite, fora do expediente.
#
# Chamado UMA ÚNICA VEZ, logo após GerenciadorExpediente.expediente_
# encerrado disparar e ANTES da cena RelatorioDia carregar (ver
# Main_select_script._on_expediente_encerrado()), pra que os resultados
# já apareçam no relatório do mesmo jeito que os resolvidos pelo
# jogador ou pelo Assistente.
#
# static func — sem estado próprio, sem Node na árvore. Só entende as
# duas linhas de upgrade da IA (Capacidade e Eficiência), lidas na hora
# via DadosJogo.obter_linha_upgrade() — mesmo padrão de
# gerenciador_assistente.gd com as linhas do Assistente.
# =====================================================================

const TAXA_SUCESSO_IA := 0.75
const EFICIENCIA_BASE := 0.35   # % da recompensa entregue sem nenhum tier de Eficiência comprado


# Ponto de entrada único. Não retorna nada — efeito colateral é popular
# DadosJogo.resultados_do_dia com os trabalhos que a IA processou.
# hora_fim_expediente vem do relógio simulado, só pra preencher
# hora_inicio/hora_fim do ResultadoTrabalho (a IA não "gasta" tempo de
# expediente de verdade, mas os campos existem e o relatório os lê).
static func processar_noite(hora_fim_expediente: float) -> void:
	if not _ia_esta_disponivel():
		return

	var candidatos := _coletar_trabalhos_sobrados()
	if candidatos.is_empty():
		return

	candidatos.shuffle()   # trabalhos sobrados não têm prioridade entre si — tratados como pilha da noite

	var capacidade := _capacidade_atual()
	var processados := 0

	for agendado in candidatos:
		if processados >= capacidade:
			break
		_resolver_trabalho(agendado, hora_fim_expediente)
		processados += 1


static func _ia_esta_disponivel() -> bool:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_IA_CAPACIDADE)
	return linha != null and linha.tier_atual >= 1


static func _capacidade_atual() -> int:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_IA_CAPACIDADE)
	if linha == null or linha.tier_atual <= 0:
		return 0
	return int(linha.valor_efeito_atual())


static func _eficiencia_atual() -> float:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_IA_EFICIENCIA)
	if linha == null:
		return EFICIENCIA_BASE
	return linha.valor_efeito_atual(EFICIENCIA_BASE)


# Trabalhos "sobrados": apareceram na agenda mas nunca foram aceitos, OU
# foram aceitos e nunca concluídos. Ignora qualquer agendado que já
# tenha um ResultadoTrabalho pendente em outro lugar (ex: ainda na fila
# do Assistente) — a IA não deve "roubar" um trabalho que já está sendo
# tratado por outro sistema. Trabalhos que nunca apareceram (fora do
# horário do relógio) também ficam de fora — a IA só limpa o que já
# estava disponível e foi ignorado, não adianta a agenda.
static func _coletar_trabalhos_sobrados() -> Array[TrabalhoAgendado]:
	var sobrados: Array[TrabalhoAgendado] = []
	for agendado in DadosJogo.trabalhos_do_dia:
		if agendado.concluido:
			continue
		if DadosJogo.resultados_pendentes.has(agendado):
			continue
		if agendado.apareceu:
			sobrados.append(agendado)
	return sobrados


# Resolve um trabalho sorteando acerto pela taxa fixa da IA, aplicando
# a % de eficiência sobre a recompensa normal, e gravando o
# ResultadoTrabalho direto em resultados_do_dia (sem passar por
# resultados_pendentes — não há "hora_inicio" real de expediente, é
# tudo simulado de uma vez, à noite).
static func _resolver_trabalho(agendado: TrabalhoAgendado, hora_fim_expediente: float) -> void:
	var acertou := randf() < TAXA_SUCESSO_IA

	var resultado := ResultadoTrabalho.new()
	resultado.agendado = agendado
	resultado.hora_inicio = hora_fim_expediente
	resultado.hora_fim = hora_fim_expediente
	resultado.achou_alvo_correto = acertou
	resultado.diagnostico_correto = acertou
	resultado.diagnostico_escolhido = "Resolvido pela IA (noturno)"
	resultado.acertou_no_geral = acertou
	resultado.recompensa = int(agendado.recompensa_dinheiro * _eficiencia_atual()) if acertou else 0
	resultado.fama_ganha = int(agendado.trabalho.recompensa_fama * _eficiencia_atual()) if acertou else 0

	agendado.concluido = true
	DadosJogo.trabalhos_concluidos_hoje += 1
	DadosJogo.resultados_do_dia.append(resultado)
