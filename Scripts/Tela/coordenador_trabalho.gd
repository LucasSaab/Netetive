extends Node

@export var gerenciador_trabalho: Node
@export var gerenciador_inspecao: Node
@export var gerenciador_expediente: Node   # v3.2 — lê hora_atual pro relatório
@export var gerenciador_assistente: Node   # novo — fila de trabalhos delegados
@export var site_textura: TextureRect

var _agendado_atual: TrabalhoAgendado = null
var _agendado_pendente_encerramento: TrabalhoAgendado = null
var _dialogo_confirmacao: ConfirmationDialog = null
var _label_feedback: Label = null


func _ready() -> void:
	if gerenciador_trabalho != null:
		gerenciador_trabalho.trabalho_selecionado.connect(_on_trabalho_selecionado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído no Inspetor.")

	if gerenciador_trabalho != null and gerenciador_trabalho.has_signal("delegar_solicitado"):
		gerenciador_trabalho.delegar_solicitado.connect(_on_delegar_solicitado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído (ou sem o sinal delegar_solicitado).")

	if gerenciador_trabalho != null and gerenciador_trabalho.has_signal("encerrar_ativo_solicitado"):
		gerenciador_trabalho.encerrar_ativo_solicitado.connect(_on_encerrar_ativo_solicitado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído (ou sem o sinal encerrar_ativo_solicitado).")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_signal("inspecao_concluida"):
		gerenciador_inspecao.inspecao_concluida.connect(_on_inspecao_concluida)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído (ou sem o sinal inspecao_concluida).")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_signal("diagnostico_escolhido"):
		gerenciador_inspecao.diagnostico_escolhido.connect(_on_diagnostico_escolhido)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído (ou sem o sinal diagnostico_escolhido).")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_signal("encerrar_solicitado"):
		gerenciador_inspecao.encerrar_solicitado.connect(_on_encerrar_solicitado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído (ou sem o sinal encerrar_solicitado).")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_signal("investigar_usado"):
		gerenciador_inspecao.investigar_usado.connect(_on_investigar_usado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído (ou sem o sinal investigar_usado).")

	if gerenciador_assistente != null and gerenciador_assistente.has_signal("trabalho_assistente_concluido"):
		gerenciador_assistente.trabalho_assistente_concluido.connect(_on_assistente_concluido)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_assistente não atribuído (ou sem o sinal trabalho_assistente_concluido) — delegar ficará indisponível.")

	if gerenciador_expediente == null:
		push_warning("CoordenadorTrabalho: gerenciador_expediente não atribuído — horários do relatório ficarão zerados (0.0).")

	_dialogo_confirmacao = ConfirmationDialog.new()
	_dialogo_confirmacao.confirmed.connect(_on_confirmar_encerramento)
	add_child(_dialogo_confirmacao)

	_label_feedback = Label.new()
	_label_feedback.add_theme_font_size_override("font_size", 20)
	_label_feedback.add_theme_color_override("font_color", Color.WHITE)
	_label_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_feedback.hide()
	_label_feedback.z_index = 200
	add_child(_label_feedback)


func _hora_atual() -> float:
	if gerenciador_expediente != null and "hora_atual" in gerenciador_expediente:
		return gerenciador_expediente.hora_atual
	return 0.0


func _on_trabalho_selecionado(agendado: TrabalhoAgendado) -> void:
	if agendado == null or agendado.trabalho == null:
		push_warning("CoordenadorTrabalho: trabalho_selecionado chegou com agendado/trabalho nulo.")
		return

	_agendado_atual = agendado
	var trabalho: TrabalhoInspecao = agendado.trabalho
	print("Inspecionando agora: ", trabalho.titulo)

	if site_textura != null and trabalho.imagem_site != null:
		site_textura.texture = trabalho.imagem_site

	if gerenciador_inspecao != null and gerenciador_inspecao.has_method("montar_alvos"):
		gerenciador_inspecao.montar_alvos(trabalho)
		gerenciador_inspecao.definir_investigar_disponivel(not agendado.investigar_usado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído ou sem montar_alvos().")

	# v3.2: abre o resultado pendente aqui, com hora_inicio real do
	# relógio simulado. Guarda contra recriar se o jogador reentra no
	# mesmo trabalho ativo mais de uma vez.
	if DadosJogo.resultados_pendentes.has(agendado):
		return
	DadosJogo.iniciar_resultado_pendente(agendado, _hora_atual())


# ---------------------------------------------------------------------
# DELEGAR AO ASSISTENTE (novo)
# ---------------------------------------------------------------------
# GerenciadorTrabalho só emite o pedido; aqui é onde de fato se decide
# se aceita (via GerenciadorAssistente.delegar()) e se limpa a tela caso
# o trabalho delegado fosse o que estava aberto na inspeção no momento.
func _on_delegar_solicitado(agendado: TrabalhoAgendado) -> void:
	if gerenciador_assistente == null:
		push_warning("CoordenadorTrabalho: delegar solicitado, mas gerenciador_assistente não está atribuído.")
		return

	var aceito: bool = gerenciador_assistente.delegar(agendado)
	if not aceito:
		push_warning("CoordenadorTrabalho: GerenciadorAssistente recusou delegar '%s'." % agendado.trabalho.titulo)
		return

	if _agendado_atual == agendado:
		if gerenciador_inspecao != null and gerenciador_inspecao.has_method("limpar_alvos"):
			gerenciador_inspecao.limpar_alvos()
		if site_textura != null:
			site_textura.texture = null
		_agendado_atual = null


# Chamado quando o Assistente termina um trabalho da fila (sucesso ou
# erro). Mesmo destino final de "Encerrar" manual: remove da lista de
# Ativos e mostra um toast — mas com texto próprio, deixando claro que
# foi o Assistente quem resolveu, não o jogador.
func _on_assistente_concluido(agendado: TrabalhoAgendado, acertou: bool) -> void:
	if gerenciador_trabalho != null and gerenciador_trabalho.has_method("marcar_trabalho_concluido"):
		gerenciador_trabalho.marcar_trabalho_concluido(agendado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído ou sem marcar_trabalho_concluido().")

	_mostrar_feedback_assistente(agendado.trabalho.titulo, acertou)


func _on_inspecao_concluida(acertou: bool, trabalho: TrabalhoInspecao) -> void:
	if _agendado_atual == null or _agendado_atual.trabalho != trabalho:
		push_warning("CoordenadorTrabalho: inspecao_concluida não bate com o agendado atual.")
		return

	DadosJogo.registrar_tentativa_inspecao(_agendado_atual, acertou)

	if acertou and DadosJogo.resultados_pendentes.has(_agendado_atual):
		DadosJogo.resultados_pendentes[_agendado_atual].achou_alvo_correto = true


func _on_diagnostico_escolhido(opcao: String) -> void:
	if _agendado_atual == null or not DadosJogo.resultados_pendentes.has(_agendado_atual):
		return

	var resultado: ResultadoTrabalho = DadosJogo.resultados_pendentes[_agendado_atual]
	resultado.diagnostico_escolhido = opcao
	resultado.diagnostico_correto = (opcao == DadosJogo.titulo_capitulo_correto(_agendado_atual.trabalho))


func _on_investigar_usado() -> void:
	if _agendado_atual != null:
		_agendado_atual.investigar_usado = true


func _on_encerrar_solicitado() -> void:
	if _agendado_atual == null:
		push_warning("CoordenadorTrabalho: encerrar solicitado sem agendado atual.")
		return

	_abrir_confirmacao_encerramento(_agendado_atual)


# Encerrar disparado pelo botão da LISTA de Ativos (não pelo popup
# NovaAba) — precisa funcionar mesmo se `agendado` não for o trabalho
# atualmente aberto na tela de inspeção. Por isso usa
# _agendado_pendente_encerramento em vez de _agendado_atual: encerrar
# um item da lista não deve mexer na inspeção de outro trabalho que
# porventura esteja aberta no momento.
func _on_encerrar_ativo_solicitado(agendado: TrabalhoAgendado) -> void:
	if agendado == null:
		push_warning("CoordenadorTrabalho: encerrar_ativo_solicitado chegou com agendado nulo.")
		return

	_abrir_confirmacao_encerramento(agendado)


func _abrir_confirmacao_encerramento(agendado: TrabalhoAgendado) -> void:
	_agendado_pendente_encerramento = agendado

	var diagnostico := ""
	if DadosJogo.resultados_pendentes.has(agendado):
		diagnostico = DadosJogo.resultados_pendentes[agendado].diagnostico_escolhido

	if diagnostico == "":
		_dialogo_confirmacao.dialog_text = "Você ainda não diagnosticou este problema.\nDeseja mesmo terminar o trabalho assim?"
	else:
		_dialogo_confirmacao.dialog_text = "Você está considerando o problema como:\n\"%s\"\n\nTem certeza que deseja terminar o trabalho?" % diagnostico

	_dialogo_confirmacao.popup_centered()


func _on_confirmar_encerramento() -> void:
	if _agendado_pendente_encerramento == null:
		return

	var agendado := _agendado_pendente_encerramento
	var titulo_trabalho := agendado.trabalho.titulo
	DadosJogo.finalizar_trabalho(agendado, _hora_atual())

	if gerenciador_trabalho != null and gerenciador_trabalho.has_method("marcar_trabalho_concluido"):
		gerenciador_trabalho.marcar_trabalho_concluido(agendado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído ou sem marcar_trabalho_concluido().")

	# Só limpa a tela de inspeção se o trabalho encerrado era o que
	# estava aberto nela — encerrar via lista não deve afetar a
	# inspeção de um trabalho diferente que porventura esteja aberta.
	if _agendado_atual == agendado:
		if gerenciador_inspecao != null and gerenciador_inspecao.has_method("limpar_alvos"):
			gerenciador_inspecao.limpar_alvos()
		if site_textura != null:
			site_textura.texture = null
		_agendado_atual = null

	_agendado_pendente_encerramento = null
	_mostrar_feedback("Trabalho \"%s\" encerrado." % titulo_trabalho)


# ---------------------------------------------------------------------
# TOAST DE FEEDBACK — função base compartilhada; encerramento manual e
# conclusão pelo Assistente só variam o texto exibido.
# ---------------------------------------------------------------------
func _mostrar_feedback_assistente(titulo_trabalho: String, acertou: bool) -> void:
	var resultado_texto := "concluído com sucesso" if acertou else "concluído, mas com erro"
	_mostrar_feedback("Assistente: \"%s\" %s." % [titulo_trabalho, resultado_texto])


func _mostrar_feedback(texto: String) -> void:
	_label_feedback.text = texto

	var tamanho_tela := get_viewport().get_visible_rect().size
	_label_feedback.size = Vector2(400, 40)
	_label_feedback.position = Vector2((tamanho_tela.x - 400) / 2, tamanho_tela.y - 80)

	_label_feedback.show()
	await get_tree().create_timer(2.0).timeout
	_label_feedback.hide()
