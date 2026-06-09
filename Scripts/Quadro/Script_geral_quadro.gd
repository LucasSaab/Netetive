extends Node2D

@export var botao_tutorial: TextureButton
@export var layer_tutorial: CanvasLayer

func _ready() -> void:
	if layer_tutorial != null:
		layer_tutorial.hide()
		
	if botao_tutorial != null and not botao_tutorial.pressed.is_connected(_on_botao_tutorial_pressionado):
		botao_tutorial.pressed.connect(_on_botao_tutorial_pressionado)

func _on_botao_tutorial_pressionado() -> void:
	print("SUCESSO: O botão foi clicado e o tutorial abriu!")
	if layer_tutorial != null:
		layer_tutorial.show()

# APENAS UM _input AQUI:
func _input(event: InputEvent) -> void:
	
	# TESTE DO TECLADO: Aperte a Barra de Espaço!
	if event.is_action_pressed("ui_accept"): 
		print("TECLADO: Mandou abrir o tutorial!")
		if layer_tutorial != null:
			layer_tutorial.show()
			
	# O SEU CLIQUE DIREITO NORMAL:
	if event.is_action_pressed("clique_direito"):
		if layer_tutorial != null and layer_tutorial.visible:
			print("Fechando tutorial com botão direito...")
			layer_tutorial.hide()
			get_viewport().set_input_as_handled()
		else:
			print("Voltando para o escritório...")
			voltar_para_escritorio()

func voltar_para_escritorio() -> void:
	get_tree().change_scene_to_file("res://Scenes/Escritorio.tscn")
