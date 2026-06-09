extends Node

@onready var nova_aba: Control = $NovaAba
@onready var mensagem_modal: Control = $MensagemModal
@onready var alvo_1: ColorRect = $Alvo1

var posicao_do_clique: Vector2 = Vector2.ZERO

func _ready() -> void:
	if nova_aba != null and nova_aba.has_signal("inspecionar_pressionado"):
		nova_aba.inspecionar_pressionado.connect(_on_botao_inspecionar_pressed)

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

func _on_botao_inspecionar_pressed() -> void:
	if nova_aba != null:
		nova_aba.hide()

	if alvo_1 != null and mensagem_modal != null:
		var clicou_no_alvo: bool = alvo_1.get_global_rect().has_point(posicao_do_clique)

		if mensagem_modal.has_method("mostrar"):
			mensagem_modal.mostrar(clicou_no_alvo)

		# Durante o "Verificando..." a área continua travada (STOP já estava ativo)
		await get_tree().create_timer(4.0).timeout

		# Só após confirmar: muda cor e libera o mouse
		if clicou_no_alvo:
			alvo_1.color = Color(0, 1, 0, 0.5)

		var area = get_parent().get_parent()
		if area != null and area is Control:
			area.mouse_filter = Control.MOUSE_FILTER_IGNORE
