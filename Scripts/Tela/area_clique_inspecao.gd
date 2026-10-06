extends Control

@onready var gerenciador_inspecao: Node = $GerenciadorInspecao
@export var cursor_virtual: Node   # GerenciadorCursorVirtual — opcional


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE


func _unhandled_input(event: InputEvent) -> void:
	if gerenciador_inspecao != null and gerenciador_inspecao.esta_com_popup_aberto():
		return

	if event.is_action_pressed("clique_direito"):
		if gerenciador_inspecao != null:
			gerenciador_inspecao.fechar_todos_os_popups()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var posicao: Vector2 = event.global_position

		if cursor_virtual != null and cursor_virtual.has_method("obter_posicao_clique"):
			posicao = cursor_virtual.obter_posicao_clique()

		if gerenciador_inspecao != null:
			gerenciador_inspecao.registrar_clique_na_area(posicao)
		get_viewport().set_input_as_handled()
