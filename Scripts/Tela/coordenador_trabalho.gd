extends Node

@export var gerenciador_trabalho: Node
@export var gerenciador_inspecao: Node
@export var gerenciador_expediente: Node
@export var gerenciador_assistente: Node
@export var site_textura: TextureRect

@onready var dialogo_confirmacao: ConfirmationDialog = $DialogoConfirmacao
@onready var label_feedback: Label = $LabelFeedback
@onready var painel_diagnostico: Panel = $PainelDiagnostico
@onready var label_diagnostico: Label = $PainelDiagnostico/LabelDiagnostico

var _agendado_atual: TrabalhoAgendado = null
var _agendado_pendente_encerramento: TrabalhoAgendado = null


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

	if gerenciador_trabalho != null and gerenciador_trabalho.has_signal("prazo_expirado"):
		gerenciador_trabalho.prazo_expirado.connect(_on_prazo_expirado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído (ou sem o sinal prazo_expirado).")

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

	if dialogo_confirmacao != null:
		dialogo_confirmacao.confirmed.connect(_on_confirmar_encerramento)
		dialogo_confirmacao.add_to_group("popups")   # sem isso, o cursor virtual não sabe que esse popup está aberto
	else:
		push_warning("CoordenadorTrabalho: nó 'DialogoConfirmacao' não encontrado — confira a estrutura da cena.")

	if label_feedback != null:
		label_feedback.hide()
	else:
		push_warning("CoordenadorTrabalho: nó 'LabelFeedback' não encontrado — confira a estrutura da cena.")

	if painel_diagnostico != null:
		painel_diagnostico.hide()
	else:
		push_warning("CoordenadorTrabalho: nó 'PainelDiagnostico' não encontrado — confira a estrutura da cena.")

	if label_diagnostico == null:
		push_warning("CoordenadorTrabalho: nó 'PainelDiagnostico/LabelDiagnostico' não encontrado — confira a estrutura da cena.")


func _hora_atual() -> float:
	if gerenciador_expediente != null and "hora_atual" in gerenciador_expediente:
		return gerenciador_expediente.hora_atual
	return 0.0


func _on_trabalho_selecionado(agendado: TrabalhoAgendado) -> void:
	if agendado == null or agendado.trabalho == null:
		push_warning("CoordenadorTrabalho: trabalho_selecionado chegou com agendado/trabalho nulo.")
		return

	if _agendado_atual != null and _agendado_atual != agendado and not _agendado_atual.concluido:
		var tem_tempo_limitado := CalculadoraModificadores.tem_modificador(_agendado_atual.modificadores, ModificadorAtivo.Tipo.TEMPO_LIMITADO)

		if tem_tempo_limitado:
			_encerrar_por_interrupcao(_agendado_atual)
		elif gerenciador_trabalho != null and gerenciador_trabalho.has_method("devolver_para_disponiveis"):
			gerenciador_trabalho.devolver_para_disponiveis(_agendado_atual)

	_agendado_atual = agendado
	var trabalho: TrabalhoInspecao = agendado.trabalho
	print("Inspecionando agora: ", trabalho.titulo)

	if site_textura != null and trabalho.imagem_site != null:
		site_textura.texture = trabalho.imagem_site

	if gerenciador_inspecao != null and gerenciador_inspecao.has_method("montar_alvos"):
		await gerenciador_inspecao.montar_alvos(trabalho, agendado)
		gerenciador_inspecao.definir_investigar_disponivel(not agendado.investigar_usado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído ou sem montar_alvos().")

	GerenciadorCursorVirtual.configurar_para_trabalho(agendado.modificadores, gerenciador_inspecao)
	# Sempre reconfigura o cursor pro trabalho novo — isso já reseta a
	# escala do Mouse Grande sozinho se o próximo trabalho não tiver esse
	# modificador. Mas ainda precisamos limpar explicitamente nos pontos
	# de ENCERRAMENTO (abaixo), pra não ficar dependendo só disso.
	GerenciadorCursorVirtual.configurar_para_trabalho(agendado.modificadores, gerenciador_inspecao)

	if DadosJogo.resultados_pendentes.has(agendado):
		return
	DadosJogo.iniciar_resultado_pendente(agendado, _hora_atual())


func _encerrar_por_interrupcao(agendado: TrabalhoAgendado) -> void:
	var titulo_trabalho := agendado.trabalho.titulo
	DadosJogo.finalizar_trabalho(agendado, _hora_atual())

	if gerenciador_trabalho != null and gerenciador_trabalho.has_method("marcar_trabalho_concluido"):
		gerenciador_trabalho.marcar_trabalho_concluido(agendado)

	_mostrar_feedback("Trabalho \"%s\" encerrado (Tempo Limitado interrompido)." % titulo_trabalho)


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
		GerenciadorCursorVirtual.limpar_modificadores_de_trabalho()
		_agendado_atual = null


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

	_mostrar_feedback_diagnostico(opcao)


func _on_investigar_usado() -> void:
	if _agendado_atual != null:
		_agendado_atual.investigar_usado = true


func _on_encerrar_solicitado() -> void:
	if _agendado_atual == null:
		push_warning("CoordenadorTrabalho: encerrar solicitado sem agendado atual.")
		return
	_abrir_confirmacao_encerramento(_agendado_atual)


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
		dialogo_confirmacao.dialog_text = "Você ainda não diagnosticou este problema.\nDeseja mesmo terminar o trabalho assim?"
	else:
		dialogo_confirmacao.dialog_text = "Você está considerando o problema como:\n\"%s\"\n\nTem certeza que deseja terminar o trabalho?" % diagnostico

	dialogo_confirmacao.popup_centered()


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

	if _agendado_atual == agendado:
		if gerenciador_inspecao != null and gerenciador_inspecao.has_method("limpar_alvos"):
			gerenciador_inspecao.limpar_alvos()
		if site_textura != null:
			site_textura.texture = null
		GerenciadorCursorVirtual.limpar_modificadores_de_trabalho()
		_agendado_atual = null

	_agendado_pendente_encerramento = null
	_mostrar_feedback("Trabalho \"%s\" encerrado." % titulo_trabalho)


func _on_prazo_expirado(agendado: TrabalhoAgendado) -> void:
	if agendado == null:
		return

	var ja_diagnosticado := false
	if DadosJogo.resultados_pendentes.has(agendado):
		ja_diagnosticado = DadosJogo.resultados_pendentes[agendado].diagnostico_escolhido != ""

	if ja_diagnosticado:
		return

	var titulo_trabalho := agendado.trabalho.titulo
	DadosJogo.finalizar_trabalho(agendado, _hora_atual())

	if gerenciador_trabalho != null and gerenciador_trabalho.has_method("marcar_trabalho_concluido"):
		gerenciador_trabalho.marcar_trabalho_concluido(agendado)

	if _agendado_atual == agendado:
		if gerenciador_inspecao != null and gerenciador_inspecao.has_method("limpar_alvos"):
			gerenciador_inspecao.limpar_alvos()
		if site_textura != null:
			site_textura.texture = null
		GerenciadorCursorVirtual.limpar_modificadores_de_trabalho()
		_agendado_atual = null

	if _agendado_pendente_encerramento == agendado:
		_agendado_pendente_encerramento = null

	_mostrar_feedback("Trabalho \"%s\" expirou." % titulo_trabalho)


func _mostrar_feedback_assistente(titulo_trabalho: String, acertou: bool) -> void:
	var resultado_texto := "concluído com sucesso" if acertou else "concluído, mas com erro"
	_mostrar_feedback("Assistente: \"%s\" %s." % [titulo_trabalho, resultado_texto])


func _mostrar_feedback(texto: String) -> void:
	if label_feedback == null:
		return
	label_feedback.text = texto
	label_feedback.show()
	await get_tree().create_timer(2.0).timeout
	label_feedback.hide()


func _mostrar_feedback_diagnostico(opcao: String) -> void:
	if painel_diagnostico == null or label_diagnostico == null:
		return
	label_diagnostico.text = "Trabalho diagnosticado como \"%s\"." % opcao
	painel_diagnostico.show()
	await get_tree().create_timer(2.0).timeout
	painel_diagnostico.hide()
