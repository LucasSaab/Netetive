extends Panel

# @onready garante que o código espere o Label carregar antes de tentar usá-lo
@onready var label_texto = $Label 

func _ready():
	hide() # Começa o jogo escondido

func exibir_resultado(texto: String):
	# 1. Atualiza a mensagem
	label_texto.text = texto
	
	# 2. Calcula a posição (Parte inferior central)
	var tamanho_janela = get_viewport_rect().size
	var x_centralizado = (tamanho_janela.x - size.x) / 2
	var y_no_rodape = tamanho_janela.y - size.y - 20
	
	global_position = Vector2(x_centralizado, y_no_rodape)
	
	# 3. Garante que ele apareça na frente de tudo
	z_index = 100
	show()

# Conecte o sinal 'pressed' do botão que está DENTRO do modal aqui
func _on_button_pressed():
	hide()
