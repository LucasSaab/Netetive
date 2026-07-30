extends Node

# =====================================================================
# GerenciadorTrabalho
# ---------------------------------------------------------------------
# Substitui o antigo fluxo de post-it (Lembrete/PainelTrabalho, hoje
# não mais usados) pelo novo menu de trabalhos: uma lista de trabalhos
# Disponíveis (aparecem conforme GerenciadorExpediente os libera) e uma
# lista de Ativos (já aceitos, aguardando o jogador escolher qual
# inspecionar agora).
#
# Fluxo:
#   GerenciadorExpediente.trabalho_disponibilizado(agendado)
#           │
#           ▼
#   item aparece em VBoxDisponiveis
#           │  jogador clica (aceita direto, sem confirmação)
#           ▼
#   item some de Disponíveis, aparece em VBoxAtivos
#           │  jogador clica no item ativo
#           ▼
#   trabalho_selecionado(agendado) — Main_select_script.gd escuta isso
#   e monta a inspeção (imagem do site + alvos) daquele trabalho
# =====================================================================

signal trabalho_selecionado(agendado: TrabalhoAgendado)

# TEMPORÁRIO: auto-aceita um trabalho específico assim que ele aparecer, pra
# já cair em "Ativos" sem precisar abrir o menu — útil enquanto só esse
# trabalho tem alvo/imagem calibrados. Trocar/desligar quando mais
# trabalhos estiverem prontos ou ao testar o fluxo manual do menu.
@export var auto_aceitar_para_teste: bool = true
@export var titulo_trabalho_teste: String = "Remover Cavalo de Tróia"
var _ja_auto_aceitou: bool = false

@export var btn_abrir_menu: TextureButton
@export var menu_trabalhos: Panel
@export var vbox_disponiveis: VBoxContainer
@export var vbox_ativos: VBoxContainer
@export var gerenciador_expediente: Node  # arraste o nó GerenciadorExpediente aqui

var _agendados_disponiveis: Array[TrabalhoAgendado] = []
var _agendados_ativos: Array[TrabalhoAgendado] = []


func _ready() -> void:
	if menu_trabalhos != null:
		menu_trabalhos.hide()

	if btn_abrir_menu != null:
		btn_abrir_menu.pressed.connect(_on_btn_abrir_menu_pressed)
	else:
		push_warning("GerenciadorTrabalho: btn_abrir_menu não atribuído no Inspetor.")

	if gerenciador_expediente != null and gerenciador_expediente.has_signal("trabalho_disponibilizado"):
		gerenciador_expediente.trabalho_disponibilizado.connect(_on_trabalho_disponibilizado)
	else:
		push_warning("GerenciadorTrabalho: gerenciador_expediente não atribuído (ou sem o sinal trabalho_disponibilizado).")


func _on_btn_abrir_menu_pressed() -> void:
	if menu_trabalhos != null:
		menu_trabalhos.visible = not menu_trabalhos.visible


# ---------------------------------------------------------------------
# NOVO TRABALHO DISPONÍVEL (chegou a hora dele no expediente)
# ---------------------------------------------------------------------
func _on_trabalho_disponibilizado(agendado: TrabalhoAgendado) -> void:
	_agendados_disponiveis.append(agendado)
	_adicionar_item_disponivel(agendado)

	var eh_o_trabalho_de_teste := agendado.trabalho.titulo == titulo_trabalho_teste
	if auto_aceitar_para_teste and eh_o_trabalho_de_teste and not _ja_auto_aceitou:
		_ja_auto_aceitou = true
		# Acha o botão recém-criado (último filho de vbox_disponiveis) e
		# simula o clique nele, reaproveitando o mesmo caminho de aceite.
		if vbox_disponiveis != null and vbox_disponiveis.get_child_count() > 0:
			var botao_recem_criado := vbox_disponiveis.get_child(vbox_disponiveis.get_child_count() - 1)
			_on_disponivel_pressionado(agendado, botao_recem_criado)


func _adicionar_item_disponivel(agendado: TrabalhoAgendado) -> void:
	if vbox_disponiveis == null:
		push_warning("GerenciadorTrabalho: vbox_disponiveis não atribuído no Inspetor.")
		return

	var botao := Button.new()
	botao.text = "%s — R$ %d" % [agendado.trabalho.titulo, agendado.recompensa_dinheiro]
	botao.pressed.connect(_on_disponivel_pressionado.bind(agendado, botao))
	vbox_disponiveis.add_child(botao)


# Clique em um trabalho disponível ACEITA DIRETO (sem painel de confirmação).
func _on_disponivel_pressionado(agendado: TrabalhoAgendado, botao_origem: Button) -> void:
	agendado.aceito = true

	botao_origem.queue_free()
	_agendados_disponiveis.erase(agendado)

	_agendados_ativos.append(agendado)
	_adicionar_item_ativo(agendado)


func _adicionar_item_ativo(agendado: TrabalhoAgendado) -> void:
	if vbox_ativos == null:
		push_warning("GerenciadorTrabalho: vbox_ativos não atribuído no Inspetor.")
		return

	var botao := Button.new()
	botao.text = agendado.trabalho.titulo
	botao.pressed.connect(_on_ativo_pressionado.bind(agendado))
	vbox_ativos.add_child(botao)

func _on_ativo_pressionado(agendado: TrabalhoAgendado) -> void:
	trabalho_selecionado.emit(agendado)
	if menu_trabalhos != null:
		menu_trabalhos.hide()

func marcar_trabalho_concluido(agendado: TrabalhoAgendado) -> void:
	if agendado == null:
		return
	agendado.concluido = true
	DadosJogo.trabalhos_concluidos_hoje += 1
	DadosJogo.dinheiro_jogador += agendado.recompensa_dinheiro

	for filho in vbox_ativos.get_children():
		if filho is Button and filho.text == agendado.trabalho.titulo:
			filho.queue_free()
	_agendados_ativos.erase(agendado)
