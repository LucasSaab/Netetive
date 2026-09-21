extends Node

# =====================================================================
# GerenciadorTrabalho
# ---------------------------------------------------------------------
# Menu de trabalhos: lista de Disponíveis (aparecem conforme
# GerenciadorExpediente os libera) e lista de Ativos (já aceitos).
#
# Cartões mostram badges dos modificadores sorteados, instanciando a
# cena BadgeModificador.tscn (ícone + nível sobreposto no canto
# inferior-direito, sem moldura). O modificador Desconhecido oculta
# título/descrição/recompensa SÓ enquanto o trabalho está em
# Disponíveis — uma vez aceito, o cartão de Ativos mostra tudo normalmente.
#
# Trabalhos com o modificador Tempo Limitado ganham hora_limite no
# momento do aceite, monitorado por _process() — se estourar sem
# diagnóstico feito, emite prazo_expirado. Esses trabalhos nunca voltam
# pra Disponíveis se interrompidos — CoordenadorTrabalho fecha direto.
# =====================================================================

signal trabalho_selecionado(agendado: TrabalhoAgendado)
signal delegar_solicitado(agendado: TrabalhoAgendado)
signal encerrar_ativo_solicitado(agendado: TrabalhoAgendado)
signal prazo_expirado(agendado: TrabalhoAgendado)

const CENA_BADGE_MODIFICADOR := preload("res://Scenes/UI/BadgeModificador.tscn")

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


func _hora_atual() -> float:
	if gerenciador_expediente != null and "hora_atual" in gerenciador_expediente:
		return gerenciador_expediente.hora_atual
	return 0.0


# ---------------------------------------------------------------------
# MONITORAMENTO DE PRAZO (Tempo Limitado)
# ---------------------------------------------------------------------
func _process(_delta: float) -> void:
	if gerenciador_expediente == null or _agendados_ativos.is_empty():
		return

	var hora_atual := _hora_atual()
	var expirados: Array[TrabalhoAgendado] = []

	for agendado in _agendados_ativos:
		if agendado.hora_limite >= 0.0 and hora_atual >= agendado.hora_limite:
			expirados.append(agendado)

	for agendado in expirados:
		prazo_expirado.emit(agendado)


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
# Desconhecido: título vira "???", valor vira "R$ ???", descrição some.
# ---------------------------------------------------------------------
func _adicionar_item_disponivel(agendado: TrabalhoAgendado) -> void:
	if vbox_disponiveis == null:
		push_warning("GerenciadorTrabalho: vbox_disponiveis não atribuído no Inspetor.")
		return

	var eh_desconhecido := CalculadoraModificadores.tem_modificador(agendado.modificadores, ModificadorAtivo.Tipo.DESCONHECIDO)

	var cartao := VBoxContainer.new()
	var linha1 := HBoxContainer.new()

	var label_titulo := Label.new()
	label_titulo.text = "???" if eh_desconhecido else agendado.trabalho.titulo
	label_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha1.add_child(label_titulo)

	linha1.add_child(VSeparator.new())

	var label_valor := Label.new()
	label_valor.text = "R$ ???" if eh_desconhecido else ("R$ %d" % agendado.recompensa_dinheiro)
	linha1.add_child(label_valor)

	linha1.add_child(VSeparator.new())

	var btn_aceitar := Button.new()
	btn_aceitar.text = "Aceitar"
	btn_aceitar.pressed.connect(_on_disponivel_pressionado.bind(agendado, cartao))
	linha1.add_child(btn_aceitar)

	if _assistente_disponivel():
		linha1.add_child(VSeparator.new())
		var btn_delegar := Button.new()
		btn_delegar.text = "Delegar"
		btn_delegar.pressed.connect(_on_delegar_disponivel_pressionado.bind(agendado, cartao))
		linha1.add_child(btn_delegar)

	cartao.add_child(linha1)

	if not eh_desconhecido:
		var linha2 := HBoxContainer.new()
		var label_descricao := Label.new()
		label_descricao.text = agendado.trabalho.descricao
		label_descricao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label_descricao.autowrap_mode = TextServer.AUTOWRAP_WORD
		linha2.add_child(label_descricao)
		cartao.add_child(linha2)

	_adicionar_badges_se_houver(cartao, agendado)
	cartao.add_child(HSeparator.new())

	vbox_disponiveis.add_child(cartao)


# ---------------------------------------------------------------------
# BADGES DE MODIFICADOR — instancia BadgeModificador.tscn (ícone +
# nível sobreposto no canto inferior-direito), um por modificador ativo.
# ---------------------------------------------------------------------
func _adicionar_badges_se_houver(cartao: VBoxContainer, agendado: TrabalhoAgendado) -> void:
	if agendado.modificadores.is_empty():
		return

	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 6)

	for mod in agendado.modificadores:
		linha.add_child(_criar_badge_modificador(mod))

	cartao.add_child(linha)


func _criar_badge_modificador(mod: ModificadorAtivo) -> Control:
	var badge: BadgeModificador = CENA_BADGE_MODIFICADOR.instantiate()
	badge.configurar(mod)
	return badge


func _assistente_disponivel() -> bool:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_QUANTIDADE)
	return linha != null and linha.tier_atual >= 1


func _on_disponivel_pressionado(agendado: TrabalhoAgendado, origem: Node) -> void:
	agendado.aceito = true
	origem.queue_free()
	_agendados_disponiveis.erase(agendado)

	_definir_prazo_se_houver_relogio(agendado)

	_agendados_ativos.append(agendado)
	_adicionar_item_ativo(agendado)

	trabalho_selecionado.emit(agendado)
	if menu_trabalhos != null:
		menu_trabalhos.hide()


func _on_delegar_disponivel_pressionado(agendado: TrabalhoAgendado, origem: Node) -> void:
	agendado.aceito = true
	origem.queue_free()
	_agendados_disponiveis.erase(agendado)
	# Trabalhos delegados não entram em _agendados_ativos, então não são
	# monitorados pelo prazo aqui — o Assistente tem seu próprio tempo.
	delegar_solicitado.emit(agendado)


func _definir_prazo_se_houver_relogio(agendado: TrabalhoAgendado) -> void:
	var nivel := CalculadoraModificadores.obter_nivel(agendado.modificadores, ModificadorAtivo.Tipo.TEMPO_LIMITADO)
	if nivel <= 0:
		return
	var horas := CalculadoraModificadores.calcular_horas_prazo(nivel)
	agendado.hora_limite = _hora_atual() + horas


# ---------------------------------------------------------------------
# ATIVOS — cartão com Título | Valor | Encerrar (linha 1) + Descrição
# (linha 2). Sempre mostra tudo, mesmo se era Desconhecido.
# ---------------------------------------------------------------------
func _adicionar_item_ativo(agendado: TrabalhoAgendado) -> void:
	if vbox_ativos == null:
		push_warning("GerenciadorTrabalho: vbox_ativos não atribuído no Inspetor.")
		return

	var cartao := VBoxContainer.new()
	var linha1 := HBoxContainer.new()

	var label_titulo := Label.new()
	label_titulo.text = agendado.trabalho.titulo
	label_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha1.add_child(label_titulo)

	linha1.add_child(VSeparator.new())

	var label_valor := Label.new()
	label_valor.text = "R$ %d" % agendado.recompensa_dinheiro
	linha1.add_child(label_valor)

	linha1.add_child(VSeparator.new())

	var btn_encerrar := Button.new()
	btn_encerrar.text = "Encerrar"
	btn_encerrar.pressed.connect(_on_encerrar_ativo_pressionado.bind(agendado))
	linha1.add_child(btn_encerrar)

	cartao.add_child(linha1)

	var linha2 := HBoxContainer.new()
	var label_descricao := Label.new()
	label_descricao.text = agendado.trabalho.descricao
	label_descricao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_descricao.autowrap_mode = TextServer.AUTOWRAP_WORD
	linha2.add_child(label_descricao)
	cartao.add_child(linha2)

	_adicionar_badges_se_houver(cartao, agendado)
	cartao.add_child(HSeparator.new())

	vbox_ativos.add_child(cartao)
	_itens_ativos[agendado] = cartao


func _on_encerrar_ativo_pressionado(agendado: TrabalhoAgendado) -> void:
	encerrar_ativo_solicitado.emit(agendado)


func marcar_trabalho_concluido(agendado: TrabalhoAgendado) -> void:
	if agendado == null:
		return
	agendado.concluido = true
	DadosJogo.trabalhos_concluidos_hoje += 1

	if _itens_ativos.has(agendado):
		_itens_ativos[agendado].queue_free()
		_itens_ativos.erase(agendado)
	_agendados_ativos.erase(agendado)


# ---------------------------------------------------------------------
# DEVOLVER PRA DISPONÍVEIS (v3.7) — a cópia mantém os mesmos
# modificadores sorteados (não sorteia de novo). Trabalhos com Tempo
# Limitado nunca chegam aqui — CoordenadorTrabalho os intercepta antes
# e fecha direto como interrompido.
# ---------------------------------------------------------------------
func devolver_para_disponiveis(agendado_antigo: TrabalhoAgendado) -> void:
	if agendado_antigo == null:
		return

	if _itens_ativos.has(agendado_antigo):
		_itens_ativos[agendado_antigo].queue_free()
		_itens_ativos.erase(agendado_antigo)
	_agendados_ativos.erase(agendado_antigo)

	DadosJogo.resultados_pendentes.erase(agendado_antigo)

	var copia := TrabalhoAgendado.new()
	copia.trabalho = agendado_antigo.trabalho
	copia.horario_aparicao = agendado_antigo.horario_aparicao
	copia.recompensa_dinheiro = agendado_antigo.recompensa_dinheiro
	copia.recompensa_fama = agendado_antigo.recompensa_fama
	copia.modificadores = agendado_antigo.modificadores
	copia.apareceu = true
	# hora_limite fica -1 — trabalhos com Tempo Limitado nunca chegam
	# aqui (CoordenadorTrabalho intercepta antes e fecha direto).

	var indice := DadosJogo.trabalhos_do_dia.find(agendado_antigo)
	if indice != -1:
		DadosJogo.trabalhos_do_dia[indice] = copia

	_agendados_disponiveis.append(copia)
	_adicionar_item_disponivel(copia)
