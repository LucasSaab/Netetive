extends Node

signal inspecao_concluida(acertou: bool, trabalho: TrabalhoInspecao)
signal diagnostico_escolhido(opcao: String)
signal encerrar_solicitado
signal investigar_usado

const COLUNAS_GRID := 3
const LINHAS_PADRAO := 5
const GRUPO_ALVOS := "alvo_dinamico"

@onready var nova_aba: Control = $NovaAba
@onready var mensagem_modal: Control = $MensagemModal

@export var area_referencia: Control

var trabalho_atual: TrabalhoInspecao
var posicao_do_clique: Vector2 = Vector2.ZERO
var _area_no_popup: AreaAlvo = null
var _algum_alvo_suspeito_encontrado: bool = false
var _investigar_disponivel: bool = true


func _ready() -> void:
	if nova_aba != null:
		if nova_aba.has_signal("inspecionar_pressionado"):
			nova_aba.inspecionar_pressionado.connect(_on_botao_inspecionar_pressed)
		if nova_aba.has_signal("investigar_pressionado"):
			nova_aba.investigar_pressionado.connect(_on_investigar_pressionado)
		if nova_aba.has_signal("diagnostico_pressionado"):
			nova_aba.diagnostico_pressionado.connect(_on_diagnosticar_pressionado)
		if nova_aba.has_signal("diagnostico_escolhido"):
			nova_aba.diagnostico_escolhido.connect(_on_diagnostico_no_popup)
		if nova_aba.has_signal("ignorar_pressionado"):
			nova_aba.ignorar_pressionado.connect(_on_ignorar_pressionado)
		if nova_aba.has_signal("designorar_pressionado"):
			nova_aba.designorar_pressionado.connect(_on_designorar_pressionado)
		if nova_aba.has_signal("encerrar_pressionado"):
			nova_aba.encerrar_pressionado.connect(_on_encerrar_pressionado)


# Chamado pelo CoordenadorTrabalho logo após montar_alvos(), lendo o
# estado real do TrabalhoAgendado (agendado.investigar_usado).
func definir_investigar_disponivel(disponivel: bool) -> void:
	_investigar_disponivel = disponivel


func montar_alvos(trabalho: TrabalhoInspecao) -> void:
	limpar_alvos()
	trabalho_atual = trabalho
	_area_no_popup = null
	_algum_alvo_suspeito_encontrado = false

	if trabalho == null:
		push_warning("GerenciadorInspecao: trabalho nulo em montar_alvos()")
		return

	var linhas := trabalho.linhas_grid if trabalho.linhas_grid > 0 else LINHAS_PADRAO
	var tamanho_area := area_referencia.size if area_referencia != null else get_viewport().get_visible_rect().size
	var origem := area_referencia.global_position if area_referencia != null else Vector2.ZERO
	var largura_coluna := tamanho_area.x / float(COLUNAS_GRID)

	var mapa_alvos: Dictionary = {}
	for alvo in trabalho.alvos:
		if mapa_alvos.has(alvo.quadrante):
			push_warning("GerenciadorInspecao: quadrante %d já tem alvo atribuído — ignorando duplicata." % alvo.quadrante)
			continue
		mapa_alvos[alvo.quadrante] = alvo

	var alturas_linha: Array[float] = []
	alturas_linha.resize(linhas)

	var linhas_fixas: Dictionary = {}
	for indice in mapa_alvos.keys():
		@warning_ignore("integer_division")
		var linha: int = int(indice) / COLUNAS_GRID
		var alvo: AlvoInspecao = mapa_alvos[indice]
		if alvo.altura_real > 0.0:
			if linhas_fixas.has(linha) and linhas_fixas[linha] != alvo.altura_real:
				push_warning("GerenciadorInspecao: linha %d já tem altura fixa diferente (%.1f); mantendo a primeira." % [linha, linhas_fixas[linha]])
			else:
				linhas_fixas[linha] = alvo.altura_real

	var soma_fixa := 0.0
	for altura in linhas_fixas.values():
		soma_fixa += altura

	var linhas_livres := linhas - linhas_fixas.size()
	var altura_padrao := 0.0
	if linhas_livres > 0:
		altura_padrao = max(0.0, tamanho_area.y - soma_fixa) / float(linhas_livres)

	if soma_fixa > tamanho_area.y:
		push_warning("GerenciadorInspecao: soma das alturas fixas (%.1f) excede a altura total da área (%.1f)." % [soma_fixa, tamanho_area.y])

	for l in range(linhas):
		alturas_linha[l] = linhas_fixas[l] if linhas_fixas.has(l) else altura_padrao

	var y_atual := 0.0
	for l in range(linhas):
		for c in range(COLUNAS_GRID):
			var indice := l * COLUNAS_GRID + c
			var dados: AlvoInspecao

			if mapa_alvos.has(indice):
				dados = mapa_alvos[indice]
			else:
				dados = AlvoInspecao.new()
				dados.quadrante = indice
				dados.tipo = AlvoInspecao.Tipo.NEUTRO

			var pos := origem + Vector2(c * largura_coluna, y_atual)
			var tamanho := Vector2(largura_coluna, alturas_linha[l])
			_criar_area_para_alvo(dados, pos, tamanho)

		y_atual += alturas_linha[l]


func _criar_area_para_alvo(dados: AlvoInspecao, pos: Vector2, tamanho: Vector2) -> void:
	var area := AreaAlvo.new()
	area.dados = dados
	area.tamanho_quadrante = tamanho
	area.position = pos

	var colisor := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = tamanho
	colisor.shape = forma
	colisor.position = tamanho / 2.0

	area.add_child(colisor)
	area.add_to_group(GRUPO_ALVOS)
	add_child(area)


func limpar_alvos() -> void:
	for filho in get_tree().get_nodes_in_group(GRUPO_ALVOS):
		if filho.get_parent() == self:
			filho.queue_free()


func esta_com_popup_aberto() -> bool:
	return (nova_aba != null and nova_aba.visible) or (mensagem_modal != null and mensagem_modal.visible)


func _encontrar_area_no_ponto(pos: Vector2) -> AreaAlvo:
	for area in get_tree().get_nodes_in_group(GRUPO_ALVOS):
		if not (area is AreaAlvo):
			continue
		var rect := Rect2(area.global_position, area.tamanho_quadrante)
		if rect.has_point(pos):
			return area
	return null


func registrar_clique_na_area(posicao_global: Vector2) -> void:
	posicao_do_clique = posicao_global

	var area := _encontrar_area_no_ponto(posicao_global)
	_area_no_popup = area

	var ignorado := area != null and area.ignorado

	var inspecionar_disponivel := true
	if area != null and area.dados.tipo == AlvoInspecao.Tipo.NEUTRO and area.ja_inspecionado_negativo:
		inspecionar_disponivel = false

	if nova_aba != null and nova_aba.has_method("mostrar_em"):
		nova_aba.mostrar_em(posicao_do_clique + Vector2(8, 8), _algum_alvo_suspeito_encontrado, ignorado, inspecionar_disponivel, _investigar_disponivel)


func fechar_todos_os_popups() -> void:
	if nova_aba != null:
		nova_aba.hide()
	if mensagem_modal != null:
		mensagem_modal.hide()


func verificar_clique(pos: Vector2) -> Dictionary:
	var area := _encontrar_area_no_ponto(pos)
	if area != null:
		return {
			"encontrou_alvo": true,
			"acertou": area.dados.tipo == AlvoInspecao.Tipo.SUSPEITO,
			"capitulo": area.dados.capitulo_relacionado,
			"area": area,
		}
	return {"encontrou_alvo": false, "acertou": false, "capitulo": -1, "area": null}


func _on_botao_inspecionar_pressed() -> void:
	if nova_aba != null:
		nova_aba.hide()

	var resultado := verificar_clique(posicao_do_clique)

	if mensagem_modal != null and mensagem_modal.has_method("mostrar"):
		mensagem_modal.mostrar(resultado.acertou)

	await get_tree().create_timer(4.0).timeout

	if resultado.acertou:
		var area: AreaAlvo = resultado.area
		area.foi_encontrado = true
		_algum_alvo_suspeito_encontrado = true
		_revelar_alvo(area)
	elif resultado.encontrou_alvo:
		var area: AreaAlvo = resultado.area
		area.ja_inspecionado_negativo = true

	inspecao_concluida.emit(resultado.acertou, trabalho_atual)


# ---------------------------------------------------------------------
# INVESTIGAR — dá dica textual sobre o quadrante clicado, com 3 respostas
# possíveis dependendo do estado daquele quadrante específico.
# ---------------------------------------------------------------------
func _on_investigar_pressionado() -> void:
	if _area_no_popup == null:
		return

	var area := _area_no_popup
	var texto := ""
	var revelou_dica := false

	if area.dados.tipo == AlvoInspecao.Tipo.SUSPEITO and area.foi_encontrado:
		texto = area.dados.dica if area.dados.dica != "" else "Não há dica disponível pra este problema."
		revelou_dica = true
	elif area.dados.tipo == AlvoInspecao.Tipo.NEUTRO and area.ja_inspecionado_negativo:
		texto = "Nada de interessante nesta parte."
	else:
		texto = "Preciso investigar."

	if mensagem_modal != null and mensagem_modal.has_method("mostrar_texto"):
		mensagem_modal.mostrar_texto(texto)

	if revelou_dica:
		_investigar_disponivel = false
		investigar_usado.emit()


func _on_diagnosticar_pressionado() -> void:
	if nova_aba != null and nova_aba.has_method("mostrar_diagnostico"):
		nova_aba.mostrar_diagnostico(DadosJogo.gerar_opcoes_diagnostico(trabalho_atual))


func _on_diagnostico_no_popup(opcao: String) -> void:
	diagnostico_escolhido.emit(opcao)


func _on_ignorar_pressionado() -> void:
	if _area_no_popup != null:
		_area_no_popup.ignorado = true


func _on_designorar_pressionado() -> void:
	if _area_no_popup != null:
		_area_no_popup.ignorado = false


func _on_encerrar_pressionado() -> void:
	encerrar_solicitado.emit()


func _revelar_alvo(area: AreaAlvo) -> void:
	if area == null:
		return
	var visual := ColorRect.new()
	visual.color = Color(1, 0, 0, 0.5)
	visual.size = area.tamanho_quadrante
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(visual)
