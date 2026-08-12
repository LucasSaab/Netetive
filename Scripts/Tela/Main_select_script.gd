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
	get_tree().change_scene_to_file("res://Scenes/RelatorioDia.tscn")

func _on_btn_abrir_livro_pressed() -> void:
	var instancia_livro = cena_livro.instantiate()
	add_child(instancia_livro)
	instancia_livro.abrir_livro()


func _on_botao_inspecionar_pressed() -> void:
	pass
