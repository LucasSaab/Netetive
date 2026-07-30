extends Node
# Banco de dados global do jogo — agora usando TrabalhoInspecao em vez de
# Dictionary solto, pra carregar junto imagem do site e lista de alvos.

var banco_de_trabalhos: Array[TrabalhoInspecao] = []

var dinheiro_jogador: int = 0

# ---------------------------------------------------------------------
# Sistema de expediente (agenda do dia) — usado por gerenciador_expediente.gd
# ---------------------------------------------------------------------
const HORA_INICIO_EXPEDIENTE: float = 8.0   # 08:00 — ajustar se o design pedir outro horário
const HORA_FIM_EXPEDIENTE: float = 17.0     # 17:00 — ajustar se o design pedir outro horário

var trabalhos_do_dia: Array[TrabalhoAgendado] = []
var trabalhos_concluidos_hoje: int = 0


func _ready() -> void:
	banco_de_trabalhos = [
		_criar_trabalho_cavalo_de_troia(),
		_criar_trabalho_limpeza_disco(),
		_criar_trabalho_otimizar_inicializacao(),
		_criar_trabalho_atualizar_drivers(),
		_criar_trabalho_pasta_termica(),
	]


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
# Cada função monta 1 TrabalhoInspecao completo: textos + imagem + alvos.
# TODO: trocar "imagem_site" por preload da arte real quando estiver pronta.
# TODO: ajustar posicao/tamanho dos alvos conforme a arte final de cada site.
# ---------------------------------------------------------------------

func _criar_trabalho_cavalo_de_troia() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Remover Cavalo de Tróia"
	trabalho.descricao = "O usuário baixou um ativador falso e agora o computador está travando muito."
	trabalho.recompensa_base = 150
	trabalho.imagem_site = preload("res://Sprites/site_falso_1.png")

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.posicao = Vector2(170, 44)
	suspeito.tamanho = Vector2(298, 59)
	suspeito.capitulo_relacionado = 3  # Ransomware, por exemplo

	var neutro1 := AlvoInspecao.new()
	neutro1.tipo = AlvoInspecao.Tipo.NEUTRO
	neutro1.posicao = Vector2(80, 60)
	neutro1.tamanho = Vector2(120, 30)

	trabalho.alvos = [suspeito, neutro1]
	return trabalho


func _criar_trabalho_limpeza_disco() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Limpeza de Disco"
	trabalho.descricao = "O armazenamento está 100% cheio com arquivos temporários e lixo eletrônico."
	trabalho.recompensa_base = 60

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.posicao = Vector2(250, 200)
	suspeito.tamanho = Vector2(140, 40)
	suspeito.capitulo_relacionado = 6  # Atualização Ignorada, por exemplo

	trabalho.alvos = [suspeito]
	return trabalho


func _criar_trabalho_otimizar_inicializacao() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Otimizar Inicialização"
	trabalho.descricao = "Existem mais de 40 programas abrindo junto com o sistema. Deixe o boot mais rápido."
	trabalho.recompensa_base = 80

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.posicao = Vector2(180, 120)
	suspeito.tamanho = Vector2(150, 35)
	suspeito.capitulo_relacionado = 8  # Permissões Excessivas, por exemplo

	trabalho.alvos = [suspeito]
	return trabalho


func _criar_trabalho_atualizar_drivers() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Atualizar Drivers de Vídeo"
	trabalho.descricao = "A placa de vídeo está dando tela azul por falta de atualizações críticas."
	trabalho.recompensa_base = 110

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.posicao = Vector2(400, 250)
	suspeito.tamanho = Vector2(130, 30)
	suspeito.capitulo_relacionado = 7  # Wi-Fi Público, por exemplo

	trabalho.alvos = [suspeito]
	return trabalho


func _criar_trabalho_pasta_termica() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Substituir Pasta Térmica"
	trabalho.descricao = "O processador está atingindo 95°C em tarefas básicas. Manutenção urgente."
	trabalho.recompensa_base = 130

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.posicao = Vector2(220, 180)
	suspeito.tamanho = Vector2(140, 40)
	suspeito.capitulo_relacionado = 4  # Engenharia Social, por exemplo

	trabalho.alvos = [suspeito]
	return trabalho
