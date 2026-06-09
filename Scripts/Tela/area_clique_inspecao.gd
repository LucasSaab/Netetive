extends Control

@onready var gerenciador_inspecao: Node = $GerenciadorInspecao

func _gui_input(event: InputEvent) -> void:
	# Se popup aberto, NÃO chama set_input_as_handled — deixa o clique passar
	if gerenciador_inspecao != null and gerenciador_inspecao.esta_com_popup_aberto():
		return

	if event.is_action_pressed("clique_direito"):
		if gerenciador_inspecao != null:
			gerenciador_inspecao.fechar_todos_os_popups()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if gerenciador_inspecao != null:
			gerenciador_inspecao.registrar_clique_na_area(event.global_position)
		get_viewport().set_input_as_handled()
