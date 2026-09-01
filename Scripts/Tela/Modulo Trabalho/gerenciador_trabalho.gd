extends Node

# =====================================================================
# GerenciadorTrabalho
# ---------------------------------------------------------------------
# Menu de trabalhos: lista de Disponíveis (aparecem conforme
# GerenciadorExpediente os libera) e lista de Ativos (já aceitos).
#
# Cada item é um "cartão" de 2 linhas:
#   Disponíveis: [título + ganho | Aceitar] / [descrição | Delegar*]
#     * Delegar só aparece se o Assistente já tiver Treinamento tier 1
#       comprado — se não, a linha 2 fica só com a descrição, sem botão.
#   Ativos:      [título + ganho | Iniciar] / [descrição | Encerrar]
#
# Delegar não existe mais em Ativos — a decisão de delegar é tomada
# ANTES de começar a trabalhar nele (ainda em Disponíveis). Uma vez que
# o jogador clicou Iniciar, a única saída é Encerrar (mesma função do
# botão Encerrar dentro do popup NovaAba).
# =====================================================================

signal trabalho_selecionado(agendado: TrabalhoAgendado)
signal delegar_solicitado(agendado: TrabalhoAgendado)
signal encerrar_ativo_solicitado(agendado: TrabalhoAgendado)

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
var _itens_ativos: Dictionary = {}   # TrabalhoAgendado -> Control (cartão)


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
			var cartao_recem_criado := vbox_disponiveis.get_child(vbox_disponiveis.get_child_count() - 1)
			_on_disponivel_pressionado(agendado, cartao_recem_criado)


# ---------------------------------------------------------------------
# DISPONÍVEIS — cartão com Título | Valor | Aceitar | Delegar
# ---------------------------------------------------------------------
func _adicionar_item_disponivel(agendado: TrabalhoAgendado) -> void:
	if vbox_disponiveis == null:
		push_warning("GerenciadorTrabalho: vbox_disponiveis não atribuído no Inspetor.")
		return

	var cartao := VBoxContainer.new()

	# --- LINHA 1 --- 
	# Formato: Nome Site | Valor Ganho | Botão Aceitar | Botão Delegar
	var linha1 := HBoxContainer.new()

	# 1. Nome do Site (expande para empurrar os próximos itens para a direita)
	var label_titulo := Label.new()
	label_titulo.text = agendado.trabalho.titulo
	label_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha1.add_child(label_titulo)

	# Adiciona a barra divisória "|"
	linha1.add_child(VSeparator.new())

	# 2. Valor Ganho
	var label_valor := Label.new()
	label_valor.text = "R$ %d" % agendado.recompensa_dinheiro
	linha1.add_child(label_valor)

	# Adiciona a barra divisória "|"
	linha1.add_child(VSeparator.new())

	# 3. Botão Aceitar
	var btn_aceitar := Button.new()
	btn_aceitar.text = "Aceitar"
	btn_aceitar.pressed.connect(_on_disponivel_pressionado.bind(agendado, cartao))
	linha1.add_child(btn_aceitar)

	# 4. Botão Delegar (Condicional)
	if _assistente_disponivel():
		linha1.add_child(VSeparator.new()) # Barra divisória antes de Delegar
		var btn_delegar := Button.new()
		btn_delegar.text = "Delegar"
		btn_delegar.pressed.connect(_on_delegar_disponivel_pressionado.bind(agendado, cartao))
		linha1.add_child(btn_delegar)

	cartao.add_child(linha1)

	# --- LINHA 2 ---
	# Formato: Descrição do trabalho (Livre para ocupar o espaço de baixo)
	var linha2 := HBoxContainer.new()

	var label_descricao := Label.new()
	label_descricao.text = agendado.trabalho.descricao
	label_descricao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_descricao.autowrap_mode = TextServer.AUTOWRAP_WORD
	linha2.add_child(label_descricao)

	cartao.add_child(linha2)
	
	# Separador horizontal para dividir de outros cartões de trabalho
	cartao.add_child(HSeparator.new())

	vbox_disponiveis.add_child(cartao)

# Lê a linha de upgrade direto (mesmo padrão de gerenciador_assistente.gd)
# só pra decidir se o botão Delegar é criado — não guarda cópia do
# estado, então itens já montados antes da compra não ganham o botão
# retroativamente (aceitável: reabrir o menu já resolve).
func _assistente_disponivel() -> bool:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_QUANTIDADE)
	return linha != null and linha.tier_atual >= 1


func _on_disponivel_pressionado(agendado: TrabalhoAgendado, origem: Node) -> void:
	agendado.aceito = true

	origem.queue_free()
	_agendados_disponiveis.erase(agendado)

	_agendados_ativos.append(agendado)
	_adicionar_item_ativo(agendado)

	# Abre a inspeção direto ao aceitar (correção do clique duplo, v3.2).
	trabalho_selecionado.emit(agendado)
	if menu_trabalhos != null:
		menu_trabalhos.hide()


# Delegar direto de Disponíveis — o trabalho NUNCA passa por Ativos,
# vai direto pro Assistente. Reaproveita o mesmo sinal delegar_solicitado
# que CoordenadorTrabalho já escuta (agora emitido daqui, não mais de
# um botão dentro de Ativos).
func _on_delegar_disponivel_pressionado(agendado: TrabalhoAgendado, origem: Node) -> void:
	agendado.aceito = true

	origem.queue_free()
	_agendados_disponiveis.erase(agendado)

	delegar_solicitado.emit(agendado)


# ---------------------------------------------------------------------
# ATIVOS — cartão com Título | Valor | Encerrar (linha 1) + Descrição (linha 2)
# ---------------------------------------------------------------------
func _adicionar_item_ativo(agendado: TrabalhoAgendado) -> void:
	if vbox_ativos == null:
		push_warning("GerenciadorTrabalho: vbox_ativos não atribuído no Inspetor.")
		return

	var cartao := VBoxContainer.new()

	# --- LINHA 1 --- 
	# Formato: Nome Site | Valor Ganho | Botão Encerrar
	var linha1 := HBoxContainer.new()

	# 1. Nome do Site (expande para empurrar os próximos itens)
	var label_titulo := Label.new()
	label_titulo.text = agendado.trabalho.titulo
	label_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha1.add_child(label_titulo)

	# Barra divisória "|"
	linha1.add_child(VSeparator.new())

	# 2. Valor Ganho
	var label_valor := Label.new()
	label_valor.text = "R$ %d" % agendado.recompensa_dinheiro
	linha1.add_child(label_valor)

	# Barra divisória "|"
	linha1.add_child(VSeparator.new())

	# 3. Botão Encerrar (Único botão na linha 1)
	var btn_encerrar := Button.new()
	btn_encerrar.text = "Encerrar"
	btn_encerrar.pressed.connect(_on_encerrar_ativo_pressionado.bind(agendado))
	linha1.add_child(btn_encerrar)

	cartao.add_child(linha1)

	# --- LINHA 2 ---
	# Formato: Apenas a descrição do trabalho
	var linha2 := HBoxContainer.new()

	var label_descricao := Label.new()
	label_descricao.text = agendado.trabalho.descricao
	label_descricao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_descricao.autowrap_mode = TextServer.AUTOWRAP_WORD
	linha2.add_child(label_descricao)

	cartao.add_child(linha2)
	
	# Separador horizontal para dividir de outros cartões
	cartao.add_child(HSeparator.new())

	vbox_ativos.add_child(cartao)
	_itens_ativos[agendado] = cartao

# Só emite o pedido — CoordenadorTrabalho decide (abre o mesmo
# ConfirmationDialog que o Encerrar do popup NovaAba usa, mas SEM
# depender desse trabalho estar aberto na tela de inspeção no momento
# do clique — ver coordenador_trabalho.gd pra detalhes).
func _on_encerrar_ativo_pressionado(agendado: TrabalhoAgendado) -> void:
	encerrar_ativo_solicitado.emit(agendado)


# Chamado pelo CoordenadorTrabalho ao confirmar o encerramento (tanto
# pelo popup NovaAba quanto pelo botão Encerrar da lista) e quando o
# Assistente termina um trabalho delegado — todos com o mesmo destino
# final: o item some de VBoxAtivos.
func marcar_trabalho_concluido(agendado: TrabalhoAgendado) -> void:
	if agendado == null:
		return
	agendado.concluido = true
	DadosJogo.trabalhos_concluidos_hoje += 1

	if _itens_ativos.has(agendado):
		_itens_ativos[agendado].queue_free()
		_itens_ativos.erase(agendado)
	_agendados_ativos.erase(agendado)
