extends Node

# =====================================================================
# GerenciadorTrabalho
# ---------------------------------------------------------------------
# Menu de trabalhos: uma lista de trabalhos Disponíveis (aparecem
# conforme GerenciadorExpediente os libera) e uma lista de Ativos (já
# aceitos, aguardando o jogador inspecionar/diagnosticar/terminar).
#
# O diagnóstico NÃO acontece mais aqui — passou a viver dentro da
# NovaAba, no popup de clique do GerenciadorInspecao. Este arquivo só
# expõe habilitar_botao_terminar(), chamado externamente pelo
# CoordenadorTrabalho assim que o jogador diagnostica corretamente.
# =====================================================================

signal trabalho_selecionado(agendado: TrabalhoAgendado)

@export var auto_aceitar_para_teste: bool = true
@export var titulo_trabalho_teste: String = "Remover Cavalo de Tróia"
var _ja_auto_aceitou: bool = false

@export var btn_abrir_menu: TextureButton
@export var menu_trabalhos: Panel
@export var vbox_disponiveis: VBoxContainer
@export var vbox_ativos: VBoxContainer
@export var gerenciador_expediente: Node

var _agendados_disponiveis: Array[TrabalhoAgendado] = []
var _agendados_ativos: Array[TrabalhoAgendado] = []
var _itens_ativos: Dictionary = {}      # TrabalhoAgendado -> HBoxContainer
var _botoes_terminar: Dictionary = {}   # TrabalhoAgendado -> Button


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


func _on_trabalho_disponibilizado(agendado: TrabalhoAgendado) -> void:
	_agendados_disponiveis.append(agendado)
	_adicionar_item_disponivel(agendado)

	var eh_o_trabalho_de_teste := agendado.trabalho.titulo == titulo_trabalho_teste
	if auto_aceitar_para_teste and eh_o_trabalho_de_teste and not _ja_auto_aceitou:
		_ja_auto_aceitou = true
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


func _on_disponivel_pressionado(agendado: TrabalhoAgendado, botao_origem: Button) -> void:
	agendado.aceito = true

	botao_origem.queue_free()
	_agendados_disponiveis.erase(agendado)

	_agendados_ativos.append(agendado)
	_adicionar_item_ativo(agendado)

	DadosJogo.iniciar_resultado_pendente(agendado)


# ---------------------------------------------------------------------
# Cada trabalho ativo agora tem 2 controles: selecionar (inspecionar)
# e terminar (só habilita depois do diagnóstico, feito no popup de clique).
# ---------------------------------------------------------------------
func _adicionar_item_ativo(agendado: TrabalhoAgendado) -> void:
	if vbox_ativos == null:
		push_warning("GerenciadorTrabalho: vbox_ativos não atribuído no Inspetor.")
		return

	var linha := HBoxContainer.new()

	var btn_titulo := Button.new()
	btn_titulo.text = agendado.trabalho.titulo
	btn_titulo.pressed.connect(_on_ativo_pressionado.bind(agendado))
	linha.add_child(btn_titulo)

	var btn_terminar := Button.new()
	btn_terminar.text = "Terminar trabalho"
	btn_terminar.disabled = true
	btn_terminar.pressed.connect(_on_terminar_pressionado.bind(agendado))
	linha.add_child(btn_terminar)

	vbox_ativos.add_child(linha)
	_itens_ativos[agendado] = linha
	_botoes_terminar[agendado] = btn_terminar


func _on_ativo_pressionado(agendado: TrabalhoAgendado) -> void:
	trabalho_selecionado.emit(agendado)
	if menu_trabalhos != null:
		menu_trabalhos.hide()


func habilitar_botao_terminar(agendado: TrabalhoAgendado) -> void:
	if _botoes_terminar.has(agendado):
		_botoes_terminar[agendado].disabled = false


func _on_terminar_pressionado(agendado: TrabalhoAgendado) -> void:
	DadosJogo.finalizar_trabalho(agendado)
	marcar_trabalho_concluido(agendado)


func marcar_trabalho_concluido(agendado: TrabalhoAgendado) -> void:
	if agendado == null:
		return
	agendado.concluido = true
	DadosJogo.trabalhos_concluidos_hoje += 1

	if _itens_ativos.has(agendado):
		_itens_ativos[agendado].queue_free()
		_itens_ativos.erase(agendado)
	_botoes_terminar.erase(agendado)
	_agendados_ativos.erase(agendado)
