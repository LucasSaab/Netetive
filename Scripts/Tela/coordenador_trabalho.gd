extends Node

# =====================================================================
# CoordenadorTrabalho
# ---------------------------------------------------------------------
# Único responsável por conectar GerenciadorTrabalho (menu de trabalhos)
# com GerenciadorInspecao (alvos/clique/detecção/diagnóstico). Nenhum
# dos dois conhece o outro diretamente — essa é a única função deste
# nó, para manter Main_select_script.gd livre dessa responsabilidade.
#
# NOVO (ciclo do dia): também lê o relógio simulado de
# GerenciadorExpediente para registrar hora_inicio/hora_fim de cada
# ResultadoTrabalho, usados no relatório de fim de expediente.
#
# Fluxo:
#   GerenciadorTrabalho.trabalho_selecionado(agendado)
#           │
#           ▼
#   CoordenadorTrabalho: guarda agendado, troca imagem do site,
#                         chama GerenciadorInspecao.montar_alvos(trabalho),
#                         define_investigar_disponivel(),
#                         abre resultado pendente com hora_inicio
#           │
#   (jogador inspeciona/investiga/diagnostica a tela...)
#           │
#           ├─► GerenciadorInspecao.inspecao_concluida(acertou, trabalho)
#           │        → registra tentativa (certa/errada) no resultado
#           │        → se acertou, marca achou_alvo_correto = true
#           │
#           ├─► GerenciadorInspecao.diagnostico_escolhido(opcao)
#           │        → grava diagnostico_escolhido/diagnostico_correto
#           │
#           ├─► GerenciadorInspecao.investigar_usado
#           │        → persiste agendado.investigar_usado = true
#           │
#           └─► GerenciadorInspecao.encerrar_solicitado
#                    → abre ConfirmationDialog com o diagnóstico atual
#                    → ao confirmar: finaliza (hora_fim), marca concluído,
#                      limpa tela, mostra toast "Trabalho encerrado."
# =====================================================================

@export var gerenciador_trabalho: Node
@export var gerenciador_inspecao: Node
@export var gerenciador_expediente: Node   # NOVO — pra ler hora_atual do relógio simulado
@export var site_textura: TextureRect

var _agendado_atual: TrabalhoAgendado = null
var _dialogo_confirmacao: ConfirmationDialog = null
var _label_feedback: Label = null


func _ready() -> void:
	if gerenciador_trabalho != null:
		gerenciador_trabalho.trabalho_selecionado.connect(_on_trabalho_selecionado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído no Inspetor.")

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


# ---------------------------------------------------------------------
# Lê a hora simulada atual do GerenciadorExpediente. Retorna 0.0 se o
# nó não estiver atribuído (evita erro; só deixa o relatório sem tempo
# real registrado, avisado uma única vez no _ready()).
# ---------------------------------------------------------------------
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

	# NOVO: abre o resultado pendente aqui (não mais em gerenciador_trabalho.gd),
	# já com hora_inicio marcada — garante que o relógio bate mesmo se o
	# jogador ficar um tempo com o menu de trabalhos aberto antes de entrar.
	if DadosJogo.resultados_pendentes.has(agendado):
		return  # já tem um resultado pendente pra esse agendado (reentrada), não recria
	DadosJogo.iniciar_resultado_pendente(agendado, _hora_atual())


func _on_inspecao_concluida(acertou: bool, trabalho: TrabalhoInspecao) -> void:
	if _agendado_atual == null or _agendado_atual.trabalho != trabalho:
		push_warning("CoordenadorTrabalho: inspecao_concluida não bate com o agendado atual.")
		return

	# NOVO: registra a tentativa (certa/errada) pro relatório detalhado,
	# independente de já ter achado o alvo suspeito antes.
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

	var diagnostico := ""
	if DadosJogo.resultados_pendentes.has(_agendado_atual):
		diagnostico = DadosJogo.resultados_pendentes[_agendado_atual].diagnostico_escolhido

	if diagnostico == "":
		_dialogo_confirmacao.dialog_text = "Você ainda não diagnosticou este problema.\nDeseja mesmo terminar o trabalho assim?"
	else:
		_dialogo_confirmacao.dialog_text = "Você está considerando o problema como:\n\"%s\"\n\nTem certeza que deseja terminar o trabalho?" % diagnostico

	_dialogo_confirmacao.popup_centered()


func _on_confirmar_encerramento() -> void:
	if _agendado_atual == null:
		return

	var titulo_trabalho := _agendado_atual.trabalho.titulo

	# NOVO: passa a hora atual pra fechar hora_fim do resultado.
	DadosJogo.finalizar_trabalho(_agendado_atual, _hora_atual())

	if gerenciador_trabalho != null and gerenciador_trabalho.has_method("marcar_trabalho_concluido"):
		gerenciador_trabalho.marcar_trabalho_concluido(_agendado_atual)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído ou sem marcar_trabalho_concluido().")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_method("limpar_alvos"):
		gerenciador_inspecao.limpar_alvos()

	if site_textura != null:
		site_textura.texture = null

	_agendado_atual = null
	_mostrar_feedback_encerramento(titulo_trabalho)


func _mostrar_feedback_encerramento(titulo_trabalho: String) -> void:
	_label_feedback.text = "Trabalho \"%s\" encerrado." % titulo_trabalho

	var tamanho_tela := get_viewport().get_visible_rect().size
	_label_feedback.size = Vector2(400, 40)
	_label_feedback.position = Vector2((tamanho_tela.x - 400) / 2, tamanho_tela.y - 80)

	_label_feedback.show()
	await get_tree().create_timer(2.0).timeout
	_label_feedback.hide()
