extends Node2D # <-- Essa linha resolve TODOS os erros de uma vez!

@onready var modal = $Modal
@onready var mensagem_modal = $Modal/MensagemModal
@onready var alvo_1 = $Alvo1

# Esta é a função que o botão "Inspecionar" (dentro do menu) vai chamar
func _on_botao_inspecionar_pressed() -> void:
	# 1. Esconde o menu de opções
	$NovaAba.hide()
	
	# 2. Pega as áreas (retângulos) da caixa de seleção e do alvo
	var area_selecionada = caixa_selecao.get_global_rect()
	var area_do_alvo = alvo_1.get_global_rect()
	
	# 3. VERIFICAÇÃO MÁGICA: A seleção encostou no alvo?
	if area_selecionada.intersects(area_do_alvo):
		mensagem_modal.text = "Sucesso! Você encontrou dados criptografados nesta pasta."
	else:
		mensagem_modal.text = "Nada de interessante aqui... Apenas arquivos de sistema inúteis."
	
	# 4. Mostra a modal com a mensagem
	modal.show()

# Não esqueça de conectar o botão "OK" da modal para fechar ela!
func _on_botao_ok_modal_pressed() -> void:
	modal.hide()
	caixa_selecao.hide() # Opcional: esconde a caixa azul após terminar
