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


func _on_expediente_encerrado() -> void:
	# Novo: resolve os trabalhos sobrados via IA ANTES de trocar de cena,
	# pra que os resultados dela já estejam em DadosJogo.resultados_do_dia
	# quando RelatorioDia.montar_relatorio() rodar.
	var hora_fim := 0.0
	if gerenciador_expediente != null and "hora_atual" in gerenciador_expediente:
		hora_fim = gerenciador_expediente.hora_atual
	GerenciadorIANoturna.processar_noite(hora_fim)

	get_tree().change_scene_to_file("res://Scenes/RelatorioDia.tscn")


func _on_btn_abrir_livro_pressed() -> void:
	var instancia_livro = cena_livro.instantiate()
	add_child(instancia_livro)
	instancia_livro.abrir_livro()


func _on_botao_inspecionar_pressed() -> void:
	pass
