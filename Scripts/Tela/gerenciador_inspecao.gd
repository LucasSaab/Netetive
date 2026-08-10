extends Node

signal inspecao_concluida(acertou: bool, trabalho: TrabalhoInspecao)
signal diagnostico_escolhido(opcao: String)
signal encerrar_solicitado

@onready var nova_aba: Control = $NovaAba
@onready var mensagem_modal: Control = $MensagemModal

const GRUPO_ALVOS := "alvo_dinamico"

var trabalho_atual: TrabalhoInspecao
var posicao_do_clique: Vector2 = Vector2.ZERO
var _area_no_popup: AreaAlvo = null
var _algum_alvo_suspeito_encontrado: bool = false


func _ready() -> void:
	if nova_aba != null:
		if nova_aba.has_signal("inspecionar_pressionado"):
			nova_aba.inspecionar_pressionado.connect(_on_botao_inspecionar_pressed)
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


func montar_alvos(trabalho: TrabalhoInspecao) -> void:
	limpar_alvos()
	trabalho_atual = trabalho
	_area_no_popup = null
	_algum_alvo_suspeito_encontrado = false

	if trabalho == null:
		push_warning("GerenciadorInspecao: trabalho nulo em montar_alvos()")
		return

	for dados in trabalho.alvos:
		_criar_area_para_alvo(dados)


func _criar_area_para_alvo(dados: AlvoInspecao) -> void:
	var area := AreaAlvo.new()
	area.dados = dados
	area.position = dados.posicao

	var colisor := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = dados.tamanho
	colisor.shape = forma
	colisor.position = dados.tamanho / 2.0

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
		var dados: AlvoInspecao = area.dados
		if dados == null:
			continue
		var rect := Rect2(area.global_position, dados.tamanho)
		if rect.has_point(pos):
			return area
	return null


func registrar_clique_na_area(posicao_global: Vector2) -> void:
	posicao_do_clique = posicao_global

	var area := _encontrar_area_no_ponto(posicao_global)
	_area_no_popup = area

	var ignorado := area != null and area.ignorado

	# Só trava o Inspecionar quando o ponto é um AreaAlvo NEUTRO já checado.
	# Cliques em espaço vazio (sem AreaAlvo) e alvos SUSPEITOS continuam liberados.
	var inspecionar_disponivel := true
	if area != null and area.dados.tipo == AlvoInspecao.Tipo.NEUTRO and area.ja_inspecionado_negativo:
		inspecionar_disponivel = false

	if nova_aba != null and nova_aba.has_method("mostrar_em"):
		nova_aba.mostrar_em(posicao_do_clique + Vector2(8, 8), _algum_alvo_suspeito_encontrado, ignorado, inspecionar_disponivel)


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
	visual.size = area.dados.tamanho
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(visual)
