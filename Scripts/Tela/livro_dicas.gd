class_name LivroDicas
extends Panel

@onready var label_titulo := $LabelTitulo
@onready var label_problema := $LabelProblema
@onready var label_solucao := $LabelSolucao
@onready var btn_anterior := $BtnAnterior
@onready var btn_proximo := $BtnProximo

var lista_paginas: Array = []
var pagina_atual: int = 0


func _ready() -> void:
	# Sem isso, o Panel nasce sem tamanho definido — dentro de um
	# CenterContainer (que centraliza os filhos no tamanho MÍNIMO deles,
	# sem esticar), isso faz o painel renderizar em ~0x0, deixando as
	# Labels "sumidas" mesmo com texto certo (não tem espaço pra
	# desenhar). Essa linha existia na versão antiga (raiz TextureRect)
	# e precisa continuar existindo aqui.
	custom_minimum_size = get_viewport_rect().size * 0.8
	hide()

	# Carrega as páginas do arquivo de conteúdo
	var script = load("res://Scripts/conteudo_livro.gd")
	if script != null:
		var instancia = script.new()
		if "PAGINAS" in instancia:
			lista_paginas = instancia.PAGINAS
			print("--- PÁGINAS CARREGADAS --- Total: ", lista_paginas.size())
			if not lista_paginas.is_empty():
				print("Conteúdo da Página 0: ", lista_paginas[0])
		else:
			print("ERRO: A variável 'PAGINAS' não existe dentro de conteudo_livro.gd")
	else:
		print("ERRO: Arquivo res://Scripts/conteudo_livro.gd NÃO encontrado! Verifique a pasta.")

	if btn_anterior != null:
		btn_anterior.pressed.connect(_on_anterior_pressed)
	if btn_proximo != null:
		btn_proximo.pressed.connect(_on_proximo_pressed)

	atualizar_pagina()


func abrir_livro() -> void:
	pagina_atual = 0
	atualizar_pagina()
	show()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		hide()
		get_viewport().set_input_as_handled()


func atualizar_pagina() -> void:
	if lista_paginas.is_empty():
		print("AVISO: lista_paginas está vazia!")
		return

	var dados_pagina = lista_paginas[pagina_atual]

	if label_titulo != null:
		label_titulo.text = str(dados_pagina.get("titulo", dados_pagina.get("title", "")))
	if label_problema != null:
		label_problema.text = str(dados_pagina.get("descricao", dados_pagina.get("problema", "")))
	if label_solucao != null:
		label_solucao.text = str(dados_pagina.get("solucao", ""))
	if btn_anterior != null:
		btn_anterior.visible = (pagina_atual > 0)
	if btn_proximo != null:
		btn_proximo.visible = (pagina_atual < lista_paginas.size() - 1)


func _on_anterior_pressed() -> void:
	if pagina_atual > 0:
		pagina_atual -= 1
		atualizar_pagina()


func _on_proximo_pressed() -> void:
	if pagina_atual < lista_paginas.size() - 1:
		pagina_atual += 1
		atualizar_pagina()
