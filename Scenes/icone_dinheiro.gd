extends TextureRect

@export var carteira_de_dinheiro_1: CompressedTexture2D
@export var carteira_de_dinheiro_2: CompressedTexture2D

@export var icone_dinheiro: TextureRect

func _ready():
	# Força chamar a função assim que o nó entra na cena
	atualizar_aparencia()

func atualizar_aparencia():
	print("Testando! Valor atual do dinheiro: ", Global.money)
	
	if Global.money > 0:
		icone_dinheiro.texture = carteira_de_dinheiro_2
	else:
		icone_dinheiro.texture = carteira_de_dinheiro_1
