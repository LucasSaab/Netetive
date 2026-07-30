extends Node

signal inspecao_concluida(acertou: bool, trabalho: TrabalhoInspecao)

@onready var nova_aba: Control = $NovaAba
@onready var mensagem_modal: Control = $MensagemModal

const GRUPO_ALVOS := "alvo_dinamico"

var trabalho_atual: TrabalhoInspecao
var posicao_do_clique: Vector2 = Vector2.ZERO


func _ready() -> void:
	if nova_aba != null and nova_aba.has_signal("inspecionar_pressionado"):
		nova_aba.inspecionar_pressionado.connect(_on_botao_inspecionar_pressed)


# ---------------------------------------------------------------------
# MONTAGEM DOS ALVOS (sistema dinâmico restaurado)
# ---------------------------------------------------------------------
# Chamado por Main_select_script.gd quando um trabalho é montado/aceito.
# Substitui o antigo $Alvo1 fixo por N alvos criados a partir de
# trabalho.alvos (Array[AlvoInspecao]).
func montar_alvos(trabalho: TrabalhoInspecao) -> void:
	limpar_alvos()
	trabalho_atual = trabalho

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


# ---------------------------------------------------------------------
# POPUPS (nomes preservados — area_clique_inspecao.gd já chama estes)
# ---------------------------------------------------------------------
func esta_com_popup_aberto() -> bool:
	return (nova_aba != null and nova_aba.visible) or (mensagem_modal != null and mensagem_modal.visible)


func registrar_clique_na_area(posicao_global: Vector2) -> void:
	posicao_do_clique = posicao_global
	if nova_aba != null:
		if nova_aba.has_method("mostrar_em"):
			nova_aba.mostrar_em(posicao_do_clique + Vector2(8, 8))
		else:
			nova_aba.global_position = posicao_do_clique
			nova_aba.show()


func fechar_todos_os_popups() -> void:
	if nova_aba != null:
		nova_aba.hide()
	if mensagem_modal != null:
		mensagem_modal.hide()


# ---------------------------------------------------------------------
# VERIFICAÇÃO DO CLIQUE (agora percorre todos os alvos dinâmicos)
# ---------------------------------------------------------------------
func verificar_clique(pos: Vector2) -> Dictionary:
	for area in get_tree().get_nodes_in_group(GRUPO_ALVOS):
		if not (area is AreaAlvo):
			continue

		var dados: AlvoInspecao = area.dados
		if dados == null:
			continue

		var rect := Rect2(area.global_position, dados.tamanho)
		if rect.has_point(pos):
			return {
				"encontrou_alvo": true,
				"acertou": dados.tipo == AlvoInspecao.Tipo.SUSPEITO,
				"capitulo": dados.capitulo_relacionado,
				"area": area,
			}

	return {"encontrou_alvo": false, "acertou": false, "capitulo": -1, "area": null}


# ---------------------------------------------------------------------
# FLUXO PRINCIPAL — mesmo timing que já estava no arquivo real (4s travado)
# ---------------------------------------------------------------------
func _on_botao_inspecionar_pressed() -> void:
	if nova_aba != null:
		nova_aba.hide()

	var resultado := verificar_clique(posicao_do_clique)

	if mensagem_modal != null and mensagem_modal.has_method("mostrar"):
		mensagem_modal.mostrar(resultado.acertou)

	# Durante o "Verificando..." a área continua travada (mesma lógica
	# que já existia: esta_com_popup_aberto() segura os cliques).
	await get_tree().create_timer(4.0).timeout

	if resultado.acertou:
		_revelar_alvo(resultado.area)


func _revelar_alvo(area: AreaAlvo) -> void:
	if area == null:
		return
	var visual := ColorRect.new()
	visual.color = Color(0, 1, 0, 0.5)  # mantido igual ao arquivo real (verde)
	visual.size = area.dados.tamanho
	area.add_child(visual)
