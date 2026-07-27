extends TextureButton

# O sinal agora carrega o TrabalhoInspecao inteiro (título, descrição, imagem
# e alvos) além dos campos que o PainelTrabalho já usava, pra não quebrar
# quem escuta esse sinal. O trabalho será necessário depois para chamar
# GerenciadorInspecao.montar_alvos(trabalho) quando o jogador aceitar.
signal foi_clicado(trabalho: TrabalhoInspecao, titulo: String, descricao: String, recompensa: int, lembrete_clicado: TextureButton)

var trabalho_sorteado: TrabalhoInspecao
var recompensa: int = 0


func _ready() -> void:
	show()
	z_index = 100
	pressed.connect(_on_pressed)
	gui_input.connect(_on_gui_input)
	sortear_trabalho_aleatorio()


func sortear_trabalho_aleatorio() -> void:
	if DadosJogo.banco_de_trabalhos.size() > 0:
		trabalho_sorteado = DadosJogo.banco_de_trabalhos.pick_random()

		# Não sobrescrevemos trabalho_sorteado.recompensa_base — isso mudaria
		# o valor pra todo mundo, já que Resources são compartilhados por
		# referência. A variação aleatória fica só nesta instância do post-it.
		recompensa = trabalho_sorteado.recompensa_base + randi_range(-15, 25)


func _on_pressed() -> void:
	emit_signal(
		"foi_clicado",
		trabalho_sorteado,
		trabalho_sorteado.titulo,
		trabalho_sorteado.descricao,
		recompensa,
		self
	)


func _on_gui_input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		hide()
		get_viewport().set_input_as_handled()
