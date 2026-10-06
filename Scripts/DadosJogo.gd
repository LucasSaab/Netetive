extends Node
# Banco de dados global do jogo. A DEFINIÇÃO dos trabalhos (textos,
# imagem, alvos) mora em banco_de_trabalhos.gd — este arquivo cuida só
# do ESTADO em runtime: dinheiro, agenda do dia, resultados pendentes.

var banco_de_trabalhos: Array[TrabalhoInspecao] = []

var dinheiro_jogador: int = 100
var fama_jogador: int = 10000   # cresce com trabalhos concluídos; controla quantidade_trabalhos_dia (ver GerenciadorExpediente + CalculadoraFama)

# ---------------------------------------------------------------------
# Sistema de upgrades (PC, Assistente, IA)
# ---------------------------------------------------------------------
var upgrades: Dictionary = {}   # String -> LinhaUpgrade

# ---------------------------------------------------------------------
# Sistema de expediente (agenda do dia) — usado por gerenciador_expediente.gd
# ---------------------------------------------------------------------
const HORA_INICIO_EXPEDIENTE: float = 8.0   # 08:00 — ajustar se o design pedir outro horário
const HORA_FIM_EXPEDIENTE: float = 17.0     # 17:00 — ajustar se o design pedir outro horário

var trabalhos_do_dia: Array[TrabalhoAgendado] = []
var trabalhos_concluidos_hoje: int = 0

# ---------------------------------------------------------------------
# Sistema de diagnóstico/veredito diferido — resultado só é revelado
# no fim do expediente. Chave = TrabalhoAgendado (não TrabalhoInspecao!),
# porque o mesmo TrabalhoInspecao pode ser sorteado mais de uma vez no
# mesmo dia (pick_random em sortear_agenda_do_dia) e cada ocorrência
# precisa do seu próprio resultado.
# ---------------------------------------------------------------------
var resultados_pendentes: Dictionary = {}   # TrabalhoAgendado -> ResultadoTrabalho
var resultados_do_dia: Array[ResultadoTrabalho] = []


func _ready() -> void:
	banco_de_trabalhos = BancoDeTrabalhos.criar_todos()
	upgrades = BancoDeUpgrades.criar_todas()


# ---------------------------------------------------------------------
# Monta a agenda do dia: sorteia `quantidade_trabalhos_dia` trabalhos do
# banco, deixa os `quantidade_trabalhos_iniciais` primeiros já disponíveis
# no início do expediente, e distribui o restante aleatoriamente ao longo
# do horário de trabalho. Ordenado por horario_aparicao para que
# gerenciador_expediente possa percorrer com um único índice crescente.
# ---------------------------------------------------------------------
func sortear_agenda_do_dia(quantidade_trabalhos_dia: int, quantidade_trabalhos_iniciais: int) -> void:
	trabalhos_do_dia.clear()
	trabalhos_concluidos_hoje = 0
	resetar_resultados_do_dia()

	if banco_de_trabalhos.is_empty():
		push_warning("DadosJogo: banco_de_trabalhos vazio, não há como sortear agenda.")
		return

	var duracao_expediente := HORA_FIM_EXPEDIENTE - HORA_INICIO_EXPEDIENTE
	var lista: Array[TrabalhoAgendado] = []

	for i in range(quantidade_trabalhos_dia):
		var agendado := TrabalhoAgendado.new()
		agendado.trabalho = banco_de_trabalhos.pick_random()

		# Sorteia modificadores de dificuldade com base na fama atual
		agendado.modificadores = 	CalculadoraModificadores.sortear_modificadores(fama_jogador)
		var multiplicador := CalculadoraModificadores.calcular_multiplicador_recompensa(agendado.modificadores)

		var base_dinheiro := agendado.trabalho.recompensa_base + randi_range(-15, 25)
		agendado.recompensa_dinheiro = int(round(base_dinheiro * multiplicador))
		agendado.recompensa_fama = int(round(agendado.trabalho.recompensa_fama * multiplicador))

		if i < quantidade_trabalhos_iniciais:
			agendado.horario_aparicao = HORA_INICIO_EXPEDIENTE
		else:
			agendado.horario_aparicao = HORA_INICIO_EXPEDIENTE + randf() * duracao_expediente

		lista.append(agendado)

	lista.sort_custom(func(a, b): return a.horario_aparicao < b.horario_aparicao)
	trabalhos_do_dia = lista

# Chamado por gerenciador_expediente.gd quando o horário de um trabalho
# agendado chega.
func disponibilizar_trabalho(agendado: TrabalhoAgendado) -> void:
	agendado.apareceu = true


# ---------------------------------------------------------------------
# DIAGNÓSTICO / VEREDITO DIFERIDO
# ---------------------------------------------------------------------

# Chamado por coordenador_trabalho.gd quando o jogador ACEITA um trabalho
# (some de Disponíveis, vai pra Ativos) — abre o resultado pendente daquela
# ocorrência específica.
func iniciar_resultado_pendente(agendado: TrabalhoAgendado, hora_atual: float = 0.0) -> void:
	var resultado := ResultadoTrabalho.new()
	resultado.agendado = agendado
	resultado.hora_inicio = hora_atual
	resultados_pendentes[agendado] = resultado


# Chamado por CoordenadorTrabalho a cada inspeção concluída (acerto ou erro),
# pra alimentar tentativas_certas/tentativas_erradas do relatório detalhado.
func registrar_tentativa_inspecao(agendado: TrabalhoAgendado, acertou: bool) -> void:
	if resultados_pendentes.has(agendado):
		resultados_pendentes[agendado].registrar_tentativa(acertou)


# Chamado quando o jogador confirma "Encerrar" no popup. Fecha o resultado
# pendente (calcula acertou_no_geral/recompensa, grava hora_fim) e move pra
# lista do dia.
func finalizar_trabalho(agendado: TrabalhoAgendado, hora_atual: float = 0.0) -> ResultadoTrabalho:
	if not resultados_pendentes.has(agendado):
		push_warning("DadosJogo: finalizar_trabalho chamado sem resultado pendente para esse agendado.")
		return null

	var resultado: ResultadoTrabalho = resultados_pendentes[agendado]
	resultado.hora_fim = hora_atual
	resultado.finalizar()
	resultados_do_dia.append(resultado)
	resultados_pendentes.erase(agendado)
	return resultado


func resetar_resultados_do_dia() -> void:
	resultados_pendentes.clear()
	resultados_do_dia.clear()


# Percorre TODOS os alvos SUSPEITO do trabalho (pode haver mais de um,
# desde que compartilhem o mesmo tema/capítulo) e devolve o título do
# capítulo do LivroDicas correspondente. Se dois alvos suspeitos do
# mesmo trabalho apontarem pra capítulos diferentes — erro de calibração,
# já que o design fecha "1 problema só por trabalho" — avisa no editor
# em vez de escolher silenciosamente um dos dois.
func titulo_capitulo_correto(trabalho: TrabalhoInspecao) -> String:
	if trabalho == null:
		return ""

	var indice_encontrado: int = -1
	for alvo in trabalho.alvos:
		if alvo.tipo != AlvoInspecao.Tipo.SUSPEITO:
			continue
		if indice_encontrado == -1:
			indice_encontrado = alvo.capitulo_relacionado
		elif alvo.capitulo_relacionado != indice_encontrado:
			push_warning("DadosJogo: trabalho '%s' tem alvos SUSPEITO com capitulo_relacionado diferentes (%d e %d) — todos deveriam ser do mesmo tema." % [trabalho.titulo, indice_encontrado, alvo.capitulo_relacionado])

	if indice_encontrado == -1:
		push_warning("DadosJogo: trabalho '%s' não tem alvo SUSPEITO." % trabalho.titulo)
		return ""

	if indice_encontrado >= 0 and indice_encontrado < ConteudoLivro.PAGINAS.size():
		return ConteudoLivro.PAGINAS[indice_encontrado].get("titulo", "")

	push_warning("DadosJogo: capitulo_relacionado %d fora do range de ConteudoLivro.PAGINAS." % indice_encontrado)
	return ""


# Monta as opções de múltipla escolha do diagnóstico: a correta + distratores
# aleatórios tirados dos outros capítulos do livro.
func gerar_opcoes_diagnostico(trabalho: TrabalhoInspecao, quantidade: int = 3) -> Array[String]:
	var correta := titulo_capitulo_correto(trabalho)
	var opcoes: Array[String] = []
	if correta != "":
		opcoes.append(correta)

	var titulos_disponiveis: Array[String] = []
	for pagina in ConteudoLivro.PAGINAS:
		var titulo: String = pagina.get("titulo", "")
		if titulo != "" and titulo != correta:
			titulos_disponiveis.append(titulo)

	titulos_disponiveis.shuffle()
	for titulo in titulos_disponiveis:
		if opcoes.size() >= quantidade:
			break
		opcoes.append(titulo)

	opcoes.shuffle()
	return opcoes


# ---------------------------------------------------------------------
# SISTEMA DE UPGRADES
# ---------------------------------------------------------------------
func obter_linha_upgrade(chave: String) -> LinhaUpgrade:
	return upgrades.get(chave, null)


func comprar_upgrade(chave: String) -> bool:
	var linha: LinhaUpgrade = upgrades.get(chave, null)
	if linha == null:
		push_warning("DadosJogo: comprar_upgrade chamado com chave inexistente: '%s'." % chave)
		return false

	if linha.esta_no_maximo():
		push_warning("DadosJogo: linha '%s' já está no tier máximo." % chave)
		return false

	if linha.chave_pre_requisito != "":
		var linha_pre: LinhaUpgrade = upgrades.get(linha.chave_pre_requisito, null)
		if linha_pre == null or linha_pre.tier_atual < 1:
			push_warning("DadosJogo: pré-requisito '%s' não atendido pra comprar '%s'." % [linha.chave_pre_requisito, chave])
			return false

	var tier: TierUpgrade = linha.proximo_tier()
	if dinheiro_jogador < tier.preco:
		push_warning("DadosJogo: saldo insuficiente pra comprar tier de '%s' (precisa de R$ %d)." % [chave, tier.preco])
		return false

	dinheiro_jogador -= tier.preco
	linha.tier_atual += 1
	return true
