extends Node2D

var cena_livro = preload("res://Scenes/LivroInstrucao.tscn")

@onready var gerenciador_expediente: Node = $ModuloTrabalho/GerenciadorExpediente


func _ready() -> void:
	print("Cena iniciada. Os gerenciadores estão cuidando de tudo!")

	if gerenciador_expediente != null and gerenciador_expediente.has_method("iniciar_expediente"):
		gerenciador_expediente.iniciar_expediente()
		if gerenciador_expediente.has_signal("expediente_encerrado"):
			gerenciador_expediente.expediente_encerrado.connect(_on_expediente_encerrado)
	else:
		push_warning("Main_select_script: gerenciador_expediente não encontrado ou sem iniciar_expediente().")


# Som de clique global — toca em QUALQUER clique esquerdo do mouse
# enquanto Tela.tscn estiver ativa (botões, menus, site, lista de
# trabalhos, tudo). Usa _input() em vez de _unhandled_input() pra não
# depender de nenhum outro script "deixar passar" o evento primeiro.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		GerenciadorMusica.tocar_som_clique_menu()


func _on_expediente_encerrado() -> void:
	var hora_fim := 0.0
	if gerenciador_expediente != null and "hora_atual" in gerenciador_expediente:
		hora_fim = gerenciador_expediente.hora_atual
	GerenciadorIANoturna.processar_noite(hora_fim)

	GerenciadorMusica.tocar_musica_relatorio()

	get_tree().change_scene_to_file("res://Scenes/RelatorioDia.tscn")


func _on_btn_abrir_livro_pressed() -> void:
	var instancia_livro = cena_livro.instantiate()
	add_child(instancia_livro)
	instancia_livro.abrir_livro()


func _on_botao_inspecionar_pressed() -> void:
	pass
