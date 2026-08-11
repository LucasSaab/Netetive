extends Node
# Banco de dados global do jogo. A DEFINIÇÃO dos trabalhos (textos,
# imagem, alvos) mora em banco_de_trabalhos.gd — este arquivo cuida só
# do ESTADO em runtime: dinheiro, agenda do dia, resultados pendentes.

var banco_de_trabalhos: Array[TrabalhoInspecao] = []

var dinheiro_jogador: int = 0

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

# Chamado por gerenciador_trabalho.gd quando o jogador ACEITA um trabalho
# (some de Disponíveis, vai pra Ativos) — abre o resultado pendente daquela
# ocorrência específica.
func iniciar_resultado_pendente(agendado: TrabalhoAgendado) -> void:
	var resultado := ResultadoTrabalho.new()
	resultado.agendado = agendado
	resultados_pendentes[agendado] = resultado


# Chamado quando o jogador confirma "Encerrar" no popup. Fecha o resultado
# pendente (calcula acertou_no_geral/recompensa) e move pra lista do dia.
# Retorna o ResultadoTrabalho pra quem chamou decidir o que fazer (ex:
# creditar dinheiro), sem revelar nada na tela.
func finalizar_trabalho(agendado: TrabalhoAgendado) -> ResultadoTrabalho:
	if not resultados_pendentes.has(agendado):
		push_warning("DadosJogo: finalizar_trabalho chamado sem resultado pendente para esse agendado.")
		return null

	var resultado: ResultadoTrabalho = resultados_pendentes[agendado]
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
