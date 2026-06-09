extends Node2D

var cena_livro = preload("res://Scenes/LivroInstrucao.tscn")

func _ready() -> void:
	print("Cena iniciada. Os gerenciadores estão cuidando de tudo!")

func _on_btn_abrir_livro_pressed() -> void:
	# 1. Cria o livro na memória
	var instancia_livro = cena_livro.instantiate()
	
	# 2. Adiciona ele na tela como filho do Node2D
	add_child(instancia_livro)
	
	# 3. Chama a função dele para aparecer e carregar o texto
	instancia_livro.abrir_livro()


func _on_botao_inspecionar_pressed() -> void:
	pass # Replace with function body.
