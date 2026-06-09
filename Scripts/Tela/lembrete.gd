extends TextureButton

# 1. Colocamos o 'lembrete_clicado' lá no final da fila
signal foi_clicado(titulo: String, descricao: String, recompensa: int, lembrete_clicado: TextureButton)

var titulo_trabalho: String = ""
var descricao_trabalho: String = ""
var recompensa: int = 0

func _ready() -> void:
	show()
	z_index = 100
	pressed.connect(_on_pressed)
	sortear_trabalho_aleatorio()

func sortear_trabalho_aleatorio() -> void:
	if DadosJogo.banco_de_trabalhos.size() > 0:
		var trabalho_sorteado: Dictionary = DadosJogo.banco_de_trabalhos.pick_random()
		
		titulo_trabalho = trabalho_sorteado["titulo"]
		descricao_trabalho = trabalho_sorteado["descricao"]
		
		var valor_base: int = trabalho_sorteado["recompensa_base"]
		recompensa = valor_base + randi_range(-15, 25)

func _on_pressed() -> void:
	# 2. Mudamos a ordem de envio: Título, Descrição, Valor e, por último, o botão (self)
	emit_signal("foi_clicado", titulo_trabalho, descricao_trabalho, recompensa, self)

func _gui_input(event: InputEvent) -> void:
	# Se o painel de trabalho estiver aberto e o jogador clicar com o botão direito nele:
	if visible and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		hide() # <--- Mudamos de 'fechar()' para 'hide()', que é nativo do Godot e nunca falha!
		get_viewport().set_input_as_handled()
