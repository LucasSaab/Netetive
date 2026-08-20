extends Node
# Banco de dados global do jogo. A DEFINIÇÃO dos trabalhos (textos,
# imagem, alvos) mora em banco_de_trabalhos.gd; a DEFINIÇÃO dos upgrades
# (preços, efeitos, upkeep) mora em banco_de_upgrades.gd — este arquivo
# cuida só do ESTADO em runtime: dinheiro, agenda do dia, resultados
# pendentes e o progresso do jogador em cada linha de upgrade.

var banco_de_trabalhos: Array[TrabalhoInspecao] = []

var dinheiro_jogador: int = 0
var fama_jogador: int = 0   # cresce com trabalhos concluídos; controla quantidade_trabalhos_dia (ver GerenciadorExpediente + CalculadoraFama)

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

# ---------------------------------------------------------------------
# Sistema de Upgrades (novo) — Dictionary[String, LinhaUpgrade], chaves
# em BancoDeUpgrades (CHAVE_PC, CHAVE_ASSISTENTE_TREINAMENTO, etc).
# Cada LinhaUpgrade guarda seu próprio tier_atual — DadosJogo não
# duplica esse estado, só segura a referência e faz a compra.
# ---------------------------------------------------------------------
var upgrades: Dictionary = {}   # String -> LinhaUpgrade


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
		agendado.recompensa_dinheiro = agendado.trabalho.recompensa_base + randi_range(-15, 25)

		if i < quantidade_trabalhos_iniciais:
			agendado.horario_aparicao = HORA_INICIO_EXPEDIENTE
		else:
			agendado.horario_aparicao = HORA_INICIO_EXPEDIENTE + randf() * duracao_expediente

		lista.append(agendado)

	lista.sort_custom(func(a, b): return a.horario_aparicao < b.horario_aparicao)
	trabalhos_do_dia = lista


# Chamado por gerenciador_expediente.gd quando o horário de um trabalho
# agendado chega. Aqui é só o registro de estado — a criação do post-it
# visual na tela ainda precisa ser conectada (ver observação abaixo).
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
# lista do dia. Retorna o ResultadoTrabalho pra quem chamou decidir o que
# fazer (ex: creditar dinheiro), sem revelar nada na tela.
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


# Acha o alvo SUSPEITO do trabalho e devolve o título do capítulo do
# LivroDicas correspondente ao capitulo_relacionado dele.
func titulo_capitulo_correto(trabalho: TrabalhoInspecao) -> String:
	if trabalho == null:
		return ""
	for alvo in trabalho.alvos:
		if alvo.tipo == AlvoInspecao.Tipo.SUSPEITO:
			var indice: int = alvo.capitulo_relacionado
			if indice >= 0 and indice < ConteudoLivro.PAGINAS.size():
				return ConteudoLivro.PAGINAS[indice].get("titulo", "")
			push_warning("DadosJogo: capitulo_relacionado %d fora do range de ConteudoLivro.PAGINAS." % indice)
			return ""
	push_warning("DadosJogo: trabalho '%s' não tem alvo SUSPEITO." % trabalho.titulo)
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
# SISTEMA DE UPGRADES (novo)
# ---------------------------------------------------------------------
# comprar_upgrade() é a ÚNICA porta de entrada pra avançar uma linha de
# upgrade. Ela só entende preço/pré-requisito/dinheiro — não sabe nada
# sobre o que "Assistente" ou "IA" fazem com o tier depois de comprado.
# Quem interpreta o efeito (tempo, taxa de sucesso, upkeep) são os
# scripts dedicados (gerenciador_assistente.gd, gerenciador_ia_noturna.gd,
# mensagem_modal_scpt.gd pro PC), lendo LinhaUpgrade.valor_efeito_atual()
# na hora de usar, não guardando cópia própria do valor.
# ---------------------------------------------------------------------

# Tenta comprar o próximo tier da linha identificada por `chave` (ver
# constantes CHAVE_* em BancoDeUpgrades). Retorna true se a compra foi
# concluída; false com um push_warning explicando o motivo, se não.
func comprar_upgrade(chave: String) -> bool:
	if not upgrades.has(chave):
		push_warning("DadosJogo: upgrade '%s' não existe em BancoDeUpgrades." % chave)
		return false

	var linha: LinhaUpgrade = upgrades[chave]

	if linha.esta_no_maximo():
		push_warning("DadosJogo: linha '%s' já está no tier máximo." % chave)
		return false

	if linha.chave_pre_requisito != "" and not _pre_requisito_atendido(linha.chave_pre_requisito):
		push_warning("DadosJogo: linha '%s' exige o tier 1 de '%s' primeiro." % [chave, linha.chave_pre_requisito])
		return false

	var tier: TierUpgrade = linha.proximo_tier()

	if dinheiro_jogador < tier.preco:
		push_warning("DadosJogo: dinheiro insuficiente pra comprar '%s' tier %d (precisa de R$ %d, tem R$ %d)." % [chave, linha.tier_atual + 1, tier.preco, dinheiro_jogador])
		return false

	dinheiro_jogador -= tier.preco
	linha.tier_atual += 1
	return true


# Helper de leitura pra UI (painel_upgrades.gd) — evita expor o
# Dictionary `upgrades` diretamente em todo lugar que precisa consultar
# uma linha específica.
func obter_linha_upgrade(chave: String) -> LinhaUpgrade:
	return upgrades.get(chave, null)


func _pre_requisito_atendido(chave_pre_requisito: String) -> bool:
	if not upgrades.has(chave_pre_requisito):
		push_warning("DadosJogo: pré-requisito '%s' referenciado não existe em upgrades." % chave_pre_requisito)
		return false
	var linha_pre: LinhaUpgrade = upgrades[chave_pre_requisito]
	return linha_pre.tier_atual >= 1
