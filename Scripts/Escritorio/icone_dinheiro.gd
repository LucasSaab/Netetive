# icone_dinheiro.gd
extends TextureRect

@export var carteira_de_dinheiro_1: CompressedTexture2D
@export var carteira_de_dinheiro_2: CompressedTexture2D
@export var icone_dinheiro: TextureRect

var _ultimo_dinheiro: int = -1


func _ready() -> void:
	atualizar_aparencia()


func _process(_delta: float) -> void:
	if DadosJogo.dinheiro_jogador != _ultimo_dinheiro:
		_ultimo_dinheiro = DadosJogo.dinheiro_jogador
		atualizar_aparencia()


func atualizar_aparencia() -> void:
	if icone_dinheiro == null:
		push_warning("IconeDinheiro: icone_dinheiro não atribuído no Inspetor.")
		return

	if DadosJogo.dinheiro_jogador > 0:
		icone_dinheiro.texture = carteira_de_dinheiro_2
	else:
		icone_dinheiro.texture = carteira_de_dinheiro_1
