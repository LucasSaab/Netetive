class_name TrabalhoInspecao
extends Resource

@export var titulo: String
@export var descricao: String
@export var recompensa_base: int = 0

@export var dificuldade: int = 1
@export var recompensa_fama: int = 10

@export var imagem_site: Texture2D
@export var alvos: Array[AlvoInspecao] = []

@export var categoria_correta: String = ""
@export var opcoes_diagnostico: Array[String] = []
