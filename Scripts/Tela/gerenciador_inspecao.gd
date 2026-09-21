extends Node

signal inspecao_concluida(acertou: bool, trabalho: TrabalhoInspecao)
signal diagnostico_escolhido(opcao: String)
signal encerrar_solicitado
signal investigar_usado

const COLUNAS_PADRAO := 3
const LINHAS_PADRAO := 5
const MINIMO_GRID := 3
const GRUPO_ALVOS := "alvo_dinamico"

@onready var nova_aba: Control = $NovaAba
@onready var mensagem_modal: Control = $MensagemModal

@export var area_referencia: Control
@export var site_textura: TextureRect

var trabalho_atual: TrabalhoInspecao
var agendado_atual: TrabalhoAgendado = null
var posicao_do_clique: Vector2 = Vector2.ZERO
var _area_no_popup: AreaAlvo = null
var _algum_alvo_suspeito_encontrado: bool = false
var _investigar_disponivel: bool = true
var _bloqueado_por_armadilha: bool = false


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


func definir_investigar_disponivel(disponivel: bool) -> void:
	_investigar_disponivel = disponivel


func montar_alvos(trabalho: TrabalhoInspecao, agendado: TrabalhoAgendado = null) -> void:
	await get_tree().process_frame

	limpar_alvos()
	trabalho_atual = trabalho
	agendado_atual = agendado
	_area_no_popup = null
	_algum_alvo_suspeito_encontrado = false
	_bloqueado_por_armadilha = false

	if trabalho == null:
		push_warning("GerenciadorInspecao: trabalho nulo em montar_alvos()")
		return

	var linhas_configuradas: int = trabalho.linhas_grid if trabalho.linhas_grid > 0 else LINHAS_PADRAO
	var colunas_configuradas: int = trabalho.colunas_grid if trabalho.colunas_grid > 0 else COLUNAS_PADRAO
	var linhas: int = max(MINIMO_GRID, linhas_configuradas)
	var colunas: int = max(MINIMO_GRID, colunas_configuradas)

	if linhas_configuradas < MINIMO_GRID:
		push_warning("GerenciadorInspecao: linhas_grid (%d) abaixo do mínimo — usando %d." % [linhas_configuradas, MINIMO_GRID])
	if colunas_configuradas < MINIMO_GRID:
		push_warning("GerenciadorInspecao: colunas_grid (%d) abaixo do mínimo — usando %d." % [colunas_configuradas, MINIMO_GRID])

	var rect_ref: Rect2
	if area_referencia != null:
		rect_ref = area_referencia.get_global_rect()
	else:
		rect_ref = get_viewport().get_visible_rect()

	var origem := rect_ref.position
	var tamanho_area := rect_ref.size
	var largura_coluna := tamanho_area.x / float(colunas)
	var altura_linha := tamanho_area.y / float(linhas)

	var mapa_alvos: Dictionary = {}
	for alvo in trabalho.alvos:
		for q in alvo.quadrantes:
			if mapa_alvos.has(q):
				push_warning("GerenciadorInspecao: quadrante %d já tem alvo atribuído — ignorando duplicata." % q)
				continue
			mapa_alvos[q] = alvo

	var espelhado := agendado != null and CalculadoraModificadores.tem_modificador(agendado.modificadores, ModificadorAtivo.Tipo.AO_CONTRARIO)
	_aplicar_espelhamento_visual(espelhado)

	var areas_criadas: Array[AreaAlvo] = []

	for l in range(linhas):
		for c in range(colunas):
			var indice := l * colunas + c
			var dados: AlvoInspecao

			if mapa_alvos.has(indice):
				dados = mapa_alvos[indice]
			else:
				dados = AlvoInspecao.new()
				dados.quadrantes = [indice]
				dados.tipo = AlvoInspecao.Tipo.NEUTRO

			var coluna_fisica := (colunas - 1 - c) if espelhado else c
			var pos := origem + Vector2(coluna_fisica * largura_coluna, l * altura_linha)
			var tamanho := Vector2(largura_coluna, altura_linha)
			var area := _criar_area_para_alvo(dados, pos, tamanho)
			areas_criadas.append(area)

	if agendado != null:
		_aplicar_armadilha(areas_criadas, agendado)
		_aplicar_misdirecao(areas_criadas, agendado)


func _aplicar_espelhamento_visual(espelhado: bool) -> void:
	if site_textura != null:
		site_textura.flip_h = espelhado


func _aplicar_armadilha(areas: Array[AreaAlvo], agendado: TrabalhoAgendado) -> void:
	var nivel := CalculadoraModificadores.obter_nivel(agendado.modificadores, ModificadorAtivo.Tipo.ARMADILHA)
	if nivel <= 0:
		return

	var quantidade := CalculadoraModificadores.calcular_quantidade_armadilhas(nivel)
	var candidatas: Array = areas.filter(func(a): return is_instance_valid(a) and a.dados.tipo == AlvoInspecao.Tipo.NEUTRO and not a.eh_chamariz)
	candidatas.shuffle()

	for i in range(min(quantidade, candidatas.size())):
		if is_instance_valid(candidatas[i]):
			candidatas[i].eh_armadilha = true


func _aplicar_misdirecao(areas: Array[AreaAlvo], agendado: TrabalhoAgendado) -> void:
	var nivel := CalculadoraModificadores.obter_nivel(agendado.modificadores, ModificadorAtivo.Tipo.MISDIRECAO)
	if nivel <= 0:
		return

	var quantidade := CalculadoraModificadores.calcular_quantidade_chamarizes(nivel)
	var candidatas: Array = areas.filter(func(a): return is_instance_valid(a) and a.dados.tipo == AlvoInspecao.Tipo.NEUTRO and not a.eh_armadilha)
	candidatas.shuffle()

	for i in range(min(quantidade, candidatas.size())):
		if is_instance_valid(candidatas[i]):
			candidatas[i].eh_chamariz = true


func _criar_area_para_alvo(dados: AlvoInspecao, pos: Vector2, tamanho: Vector2) -> AreaAlvo:
	var area := AreaAlvo.new()
	area.dados = dados
	area.tamanho_quadrante = tamanho

	var colisor := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = tamanho
	colisor.position = tamanho / 2.0

	area.add_child(colisor)
	area.add_to_group(GRUPO_ALVOS)
	add_child(area)

	area.global_position = pos
	return area


func limpar_alvos() -> void:
	_area_no_popup = null
	for filho in get_tree().get_nodes_in_group(GRUPO_ALVOS):
		if is_instance_valid(filho) and filho.get_parent() == self:
			filho.queue_free()


func esta_com_popup_aberto() -> bool:
	if is_instance_valid(nova_aba) and nova_aba.visible:
		return true
	if is_instance_valid(mensagem_modal) and mensagem_modal.visible:
		return true
	for no in get_tree().get_nodes_in_group("popups"):
		if is_instance_valid(no) and no.visible:
			return true
	return false


func _encontrar_area_no_ponto(pos: Vector2) -> AreaAlvo:
	for area in get_tree().get_nodes_in_group(GRUPO_ALVOS):
		if not is_instance_valid(area) or not (area is AreaAlvo):
			continue
		var rect := Rect2(area.global_position, area.tamanho_quadrante)
		if rect.has_point(pos):
			return area
	return null


func registrar_clique_na_area(posicao_global: Vector2) -> void:
	if _bloqueado_por_armadilha:
		return

	posicao_do_clique = posicao_global

	var area := _encontrar_area_no_ponto(posicao_global)
	_area_no_popup = area

	var ignorado := is_instance_valid(area) and area.ignorado

	var inspecionar_disponivel := true
	if is_instance_valid(area) and area.dados.tipo == AlvoInspecao.Tipo.NEUTRO and area.ja_inspecionado_negativo:
		inspecionar_disponivel = false

	if is_instance_valid(nova_aba):
		nova_aba.move_to_front()
		if nova_aba.has_method("mostrar_em"):
			nova_aba.mostrar_em(posicao_do_clique + Vector2(8, 8), _algum_alvo_suspeito_encontrado, ignorado, inspecionar_disponivel, _investigar_disponivel)


func fechar_todos_os_popups() -> void:
	if is_instance_valid(nova_aba):
		nova_aba.hide()
	if is_instance_valid(mensagem_modal):
		mensagem_modal.hide()


func verificar_clique(pos: Vector2) -> Dictionary:
	var area := _encontrar_area_no_ponto(pos)
	if is_instance_valid(area):
		return {
			"encontrou_alvo": true,
			"acertou": area.dados.tipo == AlvoInspecao.Tipo.SUSPEITO,
			"capitulo": area.dados.capitulo_relacionado,
			"area": area,
		}
	return {"encontrou_alvo": false, "acertou": false, "capitulo": -1, "area": null}


func _on_botao_inspecionar_pressed() -> void:
	if _bloqueado_por_armadilha:
		return

	if is_instance_valid(nova_aba):
		nova_aba.hide()

	var resultado := verificar_clique(posicao_do_clique)
	var area_alvo: AreaAlvo = resultado.area if is_instance_valid(resultado.area) else null
	var eh_chamariz: bool = resultado.encontrou_alvo and is_instance_valid(area_alvo) and area_alvo.eh_chamariz

	GerenciadorMusica.tocar_som_verificacao()

	if is_instance_valid(mensagem_modal) and mensagem_modal.has_method("mostrar"):
		mensagem_modal.mostrar(resultado.acertou or eh_chamariz)

	var tempo := _tempo_verificacao_atual()
	if tempo > 0.0:
		await get_tree().create_timer(tempo).timeout

	if not is_inside_tree():
		return

	if resultado.acertou:
		if is_instance_valid(area_alvo):
			area_alvo.foi_encontrado = true
			_algum_alvo_suspeito_encontrado = true
			_revelar_alvo(area_alvo)
	elif resultado.encontrou_alvo:
		if is_instance_valid(area_alvo):
			area_alvo.ja_inspecionado_negativo = true
			if area_alvo.eh_armadilha:
				_acionar_armadilha()

	inspecao_concluida.emit(resultado.acertou, trabalho_atual)


func _acionar_armadilha() -> void:
	_bloqueado_por_armadilha = true
	if is_instance_valid(mensagem_modal) and mensagem_modal.has_method("mostrar_texto"):
		mensagem_modal.mostrar_texto("Armadilha! O mouse travou.")
	await get_tree().create_timer(CalculadoraModificadores.DURACAO_ARMADILHA_SEGUNDOS).timeout
	_bloqueado_por_armadilha = false


func _tempo_verificacao_atual() -> float:
	var tempo_base := 4.0
	if is_instance_valid(mensagem_modal) and mensagem_modal.has_method("tempo_total_atual"):
		tempo_base = mensagem_modal.tempo_total_atual()
	else:
		var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_PC)
		tempo_base = linha.valor_efeito_atual(4.0) if linha != null else 4.0

	var segundos_extra := 0.0
	if agendado_atual != null:
		var nivel := CalculadoraModificadores.obter_nivel(agendado_atual.modificadores, ModificadorAtivo.Tipo.CONEXAO_LENTA)
		segundos_extra = CalculadoraModificadores.calcular_segundos_conexao_lenta(nivel)

	return tempo_base + segundos_extra


func _on_investigar_pressionado() -> void:
	if not is_instance_valid(_area_no_popup):
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

	if is_instance_valid(mensagem_modal) and mensagem_modal.has_method("mostrar_texto"):
		mensagem_modal.mostrar_texto(texto)

	if revelou_dica:
		_investigar_disponivel = false
		investigar_usado.emit()


func _on_diagnosticar_pressionado() -> void:
	if not is_instance_valid(nova_aba) or not nova_aba.has_method("mostrar_diagnostico"):
		return

	var quantidade := CalculadoraModificadores.QUANTIDADE_DIAGNOSTICO_BASE
	if agendado_atual != null:
		var nivel := CalculadoraModificadores.obter_nivel(agendado_atual.modificadores, ModificadorAtivo.Tipo.MAIS_OPCOES)
		quantidade = CalculadoraModificadores.calcular_quantidade_diagnostico(nivel)

	nova_aba.mostrar_diagnostico(DadosJogo.gerar_opcoes_diagnostico(trabalho_atual, quantidade))


func _on_diagnostico_no_popup(opcao: String) -> void:
	diagnostico_escolhido.emit(opcao)


func _on_ignorar_pressionado() -> void:
	if is_instance_valid(_area_no_popup):
		_area_no_popup.ignorado = true


func _on_designorar_pressionado() -> void:
	if is_instance_valid(_area_no_popup):
		_area_no_popup.ignorado = false


func _on_encerrar_pressionado() -> void:
	encerrar_solicitado.emit()


func _revelar_alvo(area: AreaAlvo) -> void:
	if not is_instance_valid(area):
		return
	var visual := ColorRect.new()
	visual.color = Color(2, 0, 0, 0.5)
	visual.size = area.tamanho_quadrante
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(visual)
