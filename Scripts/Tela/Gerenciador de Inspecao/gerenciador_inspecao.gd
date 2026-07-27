extends Node

# =====================================================================
# GerenciadorInspecao
# ---------------------------------------------------------------------
# Responsável por:
#   1. Montar os alvos (AreaAlvo) de um TrabalhoInspecao em tempo de execução
#   2. Coordenar a abertura da NovaAba quando o jogador clica na tela
#   3. Verificar se o clique acertou um alvo suspeito ou neutro
#   4. Acionar o MensagemModal com o resultado
#
# Depende de:
#   - AlvoInspecao   (res://Scripts/alvo_inspecao.gd)
#   - TrabalhoInspecao (res://Scripts/trabalho_inspecao.gd)
#   - AreaAlvo        (res://Scripts/area_alvo.gd)
# =====================================================================

@export var nova_aba: TextureRect       # nó NovaAba já existente na cena
@export var mensagem_modal: Control     # nó MensagemModal já existente na cena

const GRUPO_ALVOS := "alvo_dinamico"

var trabalho_atual: TrabalhoInspecao
var posicao_clique_atual: Vector2 = Vector2.ZERO


func _ready() -> void:
	if nova_aba != null:
		nova_aba.hide()
		if nova_aba.has_signal("inspecionar_pressionado"):
			nova_aba.inspecionar_pressionado.connect(_on_botao_inspecionar_pressed)
	if mensagem_modal != null:
		mensagem_modal.hide()


# ---------------------------------------------------------------------
# MONTAGEM DOS ALVOS
# ---------------------------------------------------------------------
# Chamado pelo GerenciadorTrabalho quando o jogador aceita um trabalho.
# Recebe o TrabalhoInspecao inteiro (imagem do site + lista de alvos).
func montar_alvos(trabalho: TrabalhoInspecao) -> void:
	limpar_alvos()
	trabalho_atual = trabalho

	if trabalho == null:
		push_warning("GerenciadorInspecao: trabalho nulo em montar_alvos()")
		return

	print("montar_alvos: criando ", trabalho.alvos.size(), " alvos")
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
	# Area2D usa o centro da shape como origem; ajustamos para que
	# `posicao` represente o canto superior esquerdo do alvo.
	colisor.position = dados.tamanho / 2.0

	area.add_child(colisor)
	area.add_to_group(GRUPO_ALVOS)
	add_child(area)
	print("alvo criado: tipo=", dados.tipo, " global_position=", area.global_position, " tamanho=", dados.tamanho)


func limpar_alvos() -> void:
	for filho in get_tree().get_nodes_in_group(GRUPO_ALVOS):
		if filho.get_parent() == self:
			filho.queue_free()


# ---------------------------------------------------------------------
# ABERTURA DA NOVA ABA (chamado pelo AreaCliqueInspecao)
# ---------------------------------------------------------------------
func registrar_clique_na_area(pos: Vector2) -> void:
	posicao_clique_atual = pos
	if nova_aba == null:
		return
	nova_aba.global_position = pos
	nova_aba.show()


func fechar_todos_os_popups() -> void:
	if nova_aba != null:
		nova_aba.hide()
	if mensagem_modal != null:
		mensagem_modal.hide()


func esta_com_popup_aberto() -> bool:
	if nova_aba != null and nova_aba.visible:
		return true
	if mensagem_modal != null and mensagem_modal.visible:
		return true
	return false


# ---------------------------------------------------------------------
# VERIFICAÇÃO DO CLIQUE
# ---------------------------------------------------------------------
func verificar_clique(pos: Vector2) -> Dictionary:
	print("verificar_clique: pos recebida = ", pos)
	for area in get_tree().get_nodes_in_group(GRUPO_ALVOS):
		if not (area is AreaAlvo):
			continue

		var dados: AlvoInspecao = area.dados
		if dados == null:
			continue

		var rect := Rect2(area.global_position, dados.tamanho)
		print("  comparando com rect ", rect, " -> contém? ", rect.has_point(pos))
		if rect.has_point(pos):
			return {
				"encontrou_alvo": true,
				"acertou": dados.tipo == AlvoInspecao.Tipo.SUSPEITO,
				"capitulo": dados.capitulo_relacionado,
				"area": area,
			}

	return {
		"encontrou_alvo": false,
		"acertou": false,
		"capitulo": -1,
		"area": null,
	}


# ---------------------------------------------------------------------
# FLUXO PRINCIPAL: jogador clica em "Inspecionar" na NovaAba
# ---------------------------------------------------------------------
func _on_botao_inspecionar_pressed() -> void:
	fechar_todos_os_popups()

	var resultado := verificar_clique(posicao_clique_atual)

	if mensagem_modal != null and mensagem_modal.has_method("mostrar"):
		await mensagem_modal.mostrar(resultado.acertou)

	if resultado.acertou:
		_revelar_alvo(resultado.area)
		# Ponto de extensão futuro: abrir LivroDicas direto no capítulo certo
		# usando resultado.capitulo (ver seção 3.3 da documentação).


func _revelar_alvo(area: AreaAlvo) -> void:
	if area == null:
		return
	var visual := ColorRect.new()
	visual.color = Color(1, 0, 0, 0.35)
	visual.size = area.dados.tamanho
	area.add_child(visual)
