class_name LivroDicas
extends TextureRect

@onready var label_titulo := $LabelTitulo
@onready var label_problema := $LabelProblema
@onready var label_solucao := $LabelSolucao
@onready var btn_anterior := $BtnAnterior
@onready var btn_proximo := $BtnProximo

var lista_paginas: Array = []
var pagina_atual: int = 0

func _ready() -> void:
	# Pega o tamanho exato da tela do jogador (como 100vw e 100vh no CSS)
	var tamanho_tela = get_viewport_rect().size
	
	# Define o tamanho mínimo do livro para ser 80% do tamanho da tela
	custom_minimum_size = tamanho_tela * 0.8 
	
	# Deixamos o controle de posicionamento 100% para o CenterContainer do botão
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Carrega o arquivo com o texto dos capítulos
	var script = load("res://Scripts/conteudo_livro.gd")
	
	if script == null:
		print("ERRO: arquivo conteudo_livro.gd não encontrado!")
		return
		
	var instancia = script.new()
	lista_paginas = instancia.PAGINAS

	# Conecta os botões internos de avançar e voltar página
	if btn_anterior:
		btn_anterior.pressed.connect(_on_anterior_pressed)
	if btn_proximo:
		btn_proximo.pressed.connect(_on_proximo_pressed)

	atualizar_pagina()

func abrir_livro() -> void:
	pagina_atual = 0
	atualizar_pagina()
	mouse_filter = Control.MOUSE_FILTER_STOP
	show()

func atualizar_pagina() -> void:
	if lista_paginas.is_empty():
		return

	var dados_pagina = lista_paginas[pagina_atual]

	# Atualiza os textos na tela com as informações do capítulo atual
	if label_titulo:
		label_titulo.text = str(dados_pagina.get("titulo", ""))
	if label_problema:
		label_problema.text = str(dados_pagina.get("descricao", ""))
	if label_solucao:
		label_solucao.text = str(dados_pagina.get("solucao", ""))

	# Esconde o botão 'Anterior' se for a primeira página, e o 'Próximo' se for a última
	if btn_anterior:
		btn_anterior.visible = (pagina_atual > 0)
	if btn_proximo:
		btn_proximo.visible = (pagina_atual < lista_paginas.size() - 1)

func _on_anterior_pressed() -> void:
	if pagina_atual > 0:
		pagina_atual -= 1
		atualizar_pagina()

func _on_proximo_pressed() -> void:
	if pagina_atual < lista_paginas.size() - 1:
		pagina_atual += 1
		atualizar_pagina()

func _gui_input(event: InputEvent) -> void:
	# Fecha o livro se o jogador clicar com o botão direito em cima dele
	if visible and event.is_action_pressed("clique_direito"):
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		hide()
		get_viewport().set_input_as_handled()
